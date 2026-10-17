"""QA: A-220 roof plan line work (red) over the model's roof plan export, and the model's own roof edges
(envelope cell edges from r01_spec.json, blue) over A-220 (grey).

Usage: python -I roofplan_check.py <work_dir> <export_dir> <prefix>
"""
import sys, os, json
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
from PIL import Image, ImageDraw

W, exp, prefix = sys.argv[1:4]
A = json.load(open(os.path.join(W, "roofplan_segs.json")))
spec = json.load(open(os.path.join(W, "r01_spec.json")))
CX, CY, H = 376.0, 457.0, 1100.0
img = Image.open(os.path.join(exp, "%s_Roof_Plan.png" % prefix)).convert("RGB")
K = img.width / H
P = lambda x, y: (img.width / 2 + (x - CX) * K, img.height / 2 - (y - CY) * K)
d = ImageDraw.Draw(img)
for s in A:
    if (s[0] - s[2]) ** 2 + (s[1] - s[3]) ** 2 > 16:
        d.line([P(s[0], s[1]), P(s[2], s[3])], fill=(230, 0, 0), width=1)
out = os.path.join(exp, "QA_Overlay_vs_Architect_DWG")
os.makedirs(out, exist_ok=True)
img.save(os.path.join(out, "%s_Roof_Plan_vs_A-220.png" % prefix))

# model ridges/hips/valleys over A-220
S = 2.0
x0, x1, y0, y1 = -80, 820, -40, 960
im = Image.new("RGB", (int((x1 - x0) * S), int((y1 - y0) * S)), "white")
d = ImageDraw.Draw(im)
Q = lambda x, y: ((x - x0) * S, (y1 - y) * S)
for s in A:
    d.line([Q(s[0], s[1]), Q(s[2], s[3])], fill=(170, 170, 170), width=1)
for r in spec["roofs"]:
    for f in r["faces"]:
        pts = f["pts"]
        for i in range(len(pts)):
            a, b = pts[i], pts[(i + 1) % len(pts)]
            d.line([Q(a[0], a[1]), Q(b[0], b[1])], fill=(0, 60, 230), width=2)
im.save(os.path.join(out, "%s_Roof_Edges_over_A-220.png" % prefix))
print("written")
