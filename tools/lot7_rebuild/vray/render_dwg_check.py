"""QA: cross-check the V-Ray elevation renders against the architect's DWG (xelev) and the SketchUp model exports.
1. DWG overlay: xelev lines in red over each render (same mapping as overlay_check.py).
2. Framing check: building silhouette of the render (V-Ray alpha) vs the SketchUp export of the same view; reports
   the bounding boxes and the largest offset in px / inches, so a render that drifted from the drawn geometry is caught.
Usage: python -I render_dwg_check.py <xelev_segs.json> <exports_dir> <renders_dir> <raw_dir> <rev>
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "..", "tmp", "python-libs"))
import numpy as np
from PIL import Image

segs, exp, ren, raw_dir, rev = sys.argv[1:6]
VIEWS = ["Elevation_Front_West", "Elevation_Right_South", "Elevation_Rear_East", "Elevation_Left_North"]
meta = json.load(open(os.path.join(exp, "export_meta.json")))
W, H = meta["w"], meta["h"]
K = H / meta["height"]                       # px per inch
qa = os.path.join(ren, "QA_Render_vs_DWG")
os.makedirs(qa, exist_ok=True)

# 1. DWG overlay (renders padded back to the full export frame; the crop only removed rows at the bottom)
tmp = tempfile.mkdtemp()
shutil.copy2(os.path.join(exp, "export_meta.json"), tmp)
for v in VIEWS:
    im = Image.open(os.path.join(ren, f"JESB_Lot7_{rev}_Render_{v}.png")).convert("RGB")
    full = Image.new("RGB", (W, H), (255, 255, 255))
    full.paste(im, (0, 0))
    full.save(os.path.join(tmp, f"JESB_Lot7_{rev}_Render_{v}.png"))
r = subprocess.run([sys.executable, "-I", os.path.join(HERE, "..", "overlay_check.py"), segs, tmp, qa,
                    f"JESB_Lot7_{rev}_Render"], capture_output=True, text=True)
print(r.stdout.strip(), r.stderr.strip())


# 2. silhouette vs SketchUp export
def bbox(mask):
    ys, xs = np.nonzero(mask)
    return xs.min(), ys.min(), xs.max(), ys.max()


report = []
for v in VIEWS:
    a = np.asarray(Image.open(os.path.join(raw_dir, f"raw_{v}.png")).convert("RGBA"))[:, :, 3] > 128
    e = np.asarray(Image.open(os.path.join(exp, f"JESB_Lot7_{rev}_{v}.png")).convert("RGB")).astype(int)
    m = (np.abs(e - 255).sum(-1) > 30)
    # compare above the grade only (terrain band differs: textured in the render, flat in the export)
    rows = slice(0, 1450)
    ra, rm = a[rows], m[rows]
    ba, bm = bbox(ra), bbox(rm)
    d = max(abs(p - q) for p, q in zip(ba, bm))
    inter = (ra & rm).sum()
    iou = inter / max(1, (ra | rm).sum())
    report.append((v, ba, bm, d, d / K, iou))
    print(f"{v}: render bbox {ba}, export bbox {bm}, max offset {d} px = {d / K:.2f} in, IoU {iou:.4f}")
with open(os.path.join(qa, f"JESB_Lot7_{rev}_Render_Framing_Check.txt"), "w", encoding="utf-8") as fh:
    fh.write("View, render bbox (x0,y0,x1,y1 px), SketchUp export bbox, max offset px, max offset in, silhouette IoU\n")
    for row in report:
        fh.write(f"{row[0]}, {row[1]}, {row[2]}, {row[3]}, {row[4]:.2f}, {row[5]:.4f}\n")
