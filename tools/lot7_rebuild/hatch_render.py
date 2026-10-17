"""Render elevation hatch regions coloured by pattern over the outline lines.

Usage: python -I hatch_render.py <hatch.json> <segs.json> <out.png> x0 x1 y0 y1 scale
"""
import sys, json
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
from PIL import Image, ImageDraw

H = json.load(open(sys.argv[1]))
S = json.load(open(sys.argv[2]))
x0, x1, y0, y1, K = map(float, sys.argv[4:9])
COL = {"PBRICK": (205, 120, 90), "_USER": (150, 190, 230), "GENERAL_TEXTURE": (120, 200, 120), "AR-SAND": (200, 200, 120), "SOLID": (60, 60, 60)}
img = Image.new("RGB", (int((x1 - x0) * K), int((y1 - y0) * K)), "white")
d = ImageDraw.Draw(img, "RGBA")
P = lambda x, y: ((x - x0) * K, (y1 - y) * K)
for h in H:
    c = COL.get(h["pattern"], (255, 0, 255))
    if h["layer"] == "0":
        c = (240, 200, 0)
    for poly in h["polys"]:
        if max(p[0] for p in poly) < x0 or min(p[0] for p in poly) > x1:
            continue
        d.polygon([P(*p) for p in poly], fill=c + (150,), outline=c + (255,))
for s in S:
    if s[4] in ("A-Elev-Otln", "A-Elev-Glaz", "A-Elev-Mbnd") and max(s[0], s[2]) >= x0 and min(s[0], s[2]) <= x1:
        d.line([P(s[0], s[1]), P(s[2], s[3])], fill=(0, 0, 0, 255))
g = (int(y0 // 24) + 1) * 24
while g < y1:
    d.text((2, (y1 - g) * K), "%d (z %.0f)" % (g, g - 1429.31), fill=(100, 100, 100))
    g += 24
img.save(sys.argv[3])
