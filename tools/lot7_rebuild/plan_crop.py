"""Render a crop of extracted plan segments with a labelled grid (DWG inches) for reading coordinates.

Usage: python -I plan_crop.py <plan_segs.json> <out.png> x0 x1 y0 y1 [px_per_in=6] [grid=12] [layers=A-Wall,A-Glaz,A-Door,A-Wall-Open]
"""
import sys, json
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
from PIL import Image, ImageDraw, ImageFont

segs = json.load(open(sys.argv[1]))
x0, x1, y0, y1 = map(float, sys.argv[3:7])
S = float(sys.argv[7]) if len(sys.argv) > 7 else 6.0
G = float(sys.argv[8]) if len(sys.argv) > 8 else 12.0
layers = sys.argv[9].split(",") if len(sys.argv) > 9 else ["A-Wall", "A-Glaz", "A-Door", "A-Wall-Open"]
col = {"A-Wall": (0, 0, 0), "A-Glaz": (0, 110, 255), "A-Door": (220, 0, 0), "A-Wall-Open": (0, 160, 0),
       "A-Roof-Wall": (210, 120, 0), "A-Wall-brickledge": (170, 0, 170), "A-Wall-Abov": (120, 120, 0)}
img = Image.new("RGB", (int((x1 - x0) * S), int((y1 - y0) * S)), "white")
d = ImageDraw.Draw(img)
f = ImageFont.load_default()
g = (int(x0 // G) + 1) * G
while g < x1:
    X = (g - x0) * S
    d.line([(X, 0), (X, img.height)], fill=(225, 225, 225))
    d.text((X + 2, 2), str(int(g)), fill=(120, 120, 120), font=f)
    g += G
g = (int(y0 // G) + 1) * G
while g < y1:
    Y = (y1 - g) * S
    d.line([(0, Y), (img.width, Y)], fill=(225, 225, 225))
    d.text((2, Y + 2), str(int(g)), fill=(120, 120, 120), font=f)
    g += G
for s in segs:
    if s[4] in layers and max(s[0], s[2]) >= x0 and min(s[0], s[2]) <= x1 and max(s[1], s[3]) >= y0 and min(s[1], s[3]) <= y1:
        d.line([((s[0] - x0) * S, (y1 - s[1]) * S), ((s[2] - x0) * S, (y1 - s[3]) * S)], fill=col.get(s[4], (128, 128, 128)))
img.save(sys.argv[2])
