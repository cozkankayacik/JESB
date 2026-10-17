"""QA: draw the architect's elevation lines (xelev) in red over the model's orthographic exports.

Usage: python -I overlay_check.py <xelev_segs.json> <export_dir> <out_dir> <prefix>
Uses export_meta.json written by build_r01.rb (view centre, ortho height, image size).
Horizontal placement uses the plan-to-elevation mapping of geometry.py; vertical: z = DWG y - 1429.31.
"""
import sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
from PIL import Image, ImageDraw
from geometry import ELEV, Z_DATUM

S = json.load(open(sys.argv[1]))
exp, out, prefix = sys.argv[2], sys.argv[3], sys.argv[4]
os.makedirs(out, exist_ok=True)
meta = json.load(open(os.path.join(exp, "export_meta.json")))
K = meta["h"] / meta["height"]            # px per inch
RANGE = {"front": (6380, 7330), "south": (7440, 8600), "rear": (3550, 4520), "north": (5150, 6200)}
FILES = {"front": "Elevation_Front_West", "rear": "Elevation_Rear_East", "south": "Elevation_Right_South", "north": "Elevation_Left_North"}
LAY = ("A-Elev-Otln", "ARWINDOW", "ARDOOR", "A-Elev-Glaz", "A-Elev-Grad", "A-Elev-Mbnd", "A-Flor-Hral")
for v, (a, b) in RANGE.items():
    img = Image.open(os.path.join(exp, "%s_%s.png" % (prefix, FILES[v]))).convert("RGB")
    d = ImageDraw.Draw(img)
    e = ELEV[v]
    # screen u (right) in plan terms: front: +x, rear: -x, south (viewed from +x): +y, north: -y
    centre = meta["cx"] if e["axis"] == "x" else meta["cy"]
    def P(ex, ey):
        plan = (ex - e["c"]) * e["sign"]
        u = (plan - centre) * e["sign"]
        return (meta["w"] / 2 + u * K, meta["h"] / 2 - (ey - Z_DATUM - meta["cz"]) * K)
    for s in S:
        if s[4] in LAY and a <= min(s[0], s[2]) and max(s[0], s[2]) <= b:
            d.line([P(s[0], s[1]), P(s[2], s[3])], fill=(230, 0, 0), width=1)
    img.save(os.path.join(out, "%s_%s_vs_DWG.png" % (prefix, FILES[v])))
    print("overlay", v)
