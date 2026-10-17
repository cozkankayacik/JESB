"""Extract plan line work from a layered plot PDF (made by plotting the DWG at 1=48,
window lower-left (-200,-150), offset 0,0, portrait 34x44) into DWG inches.

Usage: python -I pdf_plan_extract.py <plot.pdf> <dxf_segs.json> <out_dir> <name>
- converts every path segment to DWG coordinates: X = px/1.5 - 200, Y = (H - py)/1.5 - 150
- checks the transform against a layer present in both the PDF and the DXF (A-Flor-Strs)
- writes <name>_plan_segs.json and <name>_walls.png (A-Wall black, openings/glazing/doors coloured)
"""
import sys, os, json, collections
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import pymupdf
from PIL import Image, ImageDraw

pdf, dxfsegs, out, name = sys.argv[1:5]
page = pymupdf.open(pdf)[0]
H = page.rect.height
K, LLX, LLY = 1.5, -200.0, -150.0


def to_dwg(p):
    return (p.x / K + LLX, (H - p.y) / K + LLY)


segs = []
for d in page.get_drawings():
    layer = d.get("layer") or "?"
    for it in d["items"]:
        if it[0] == "l":
            a, b = to_dwg(it[1]), to_dwg(it[2])
            segs.append((a[0], a[1], b[0], b[1], layer))
        elif it[0] == "re":
            r = it[1]
            pts = [to_dwg(pymupdf.Point(r.x0, r.y0)), to_dwg(pymupdf.Point(r.x1, r.y0)),
                   to_dwg(pymupdf.Point(r.x1, r.y1)), to_dwg(pymupdf.Point(r.x0, r.y1))]
            for i in range(4):
                segs.append((*pts[i], *pts[(i + 1) % 4], layer))
        elif it[0] == "c":  # bezier: keep chord
            a, b = to_dwg(it[1]), to_dwg(it[4])
            segs.append((a[0], a[1], b[0], b[1], layer))

# transform check: nearest-endpoint distances between PDF and DXF stair lines
ref = [s for s in json.load(open(dxfsegs)) if s[4] == "A-Flor-Strs"]
mine = [s for s in segs if s[4] == "A-Flor-Strs"]
if ref and mine:
    import math
    dx = collections.Counter();
    for s in mine[:400]:
        best = min(ref, key=lambda r: (r[0] - s[0]) ** 2 + (r[1] - s[1]) ** 2)
        dx[(round(best[0] - s[0], 1), round(best[1] - s[1], 1))] += 1
    print("offset votes (dwg - pdf):", dx.most_common(3))

json.dump(segs, open(os.path.join(out, name + "_plan_segs.json"), "w"))
cnt = collections.Counter(s[4] for s in segs)
print(name, len(segs), "segments", dict(cnt.most_common(6)))

xs = [v for s in segs if s[4] == "A-Wall" for v in (s[0], s[2])]
ys = [v for s in segs if s[4] == "A-Wall" for v in (s[1], s[3])]
x0, x1, y0, y1 = min(xs) - 30, max(xs) + 30, min(ys) - 30, max(ys) + 30
S = 2.0
img = Image.new("RGB", (int((x1 - x0) * S), int((y1 - y0) * S)), "white")
dr = ImageDraw.Draw(img)
col = {"A-Wall": (0, 0, 0), "A-Glaz": (0, 120, 255), "A-Door": (220, 0, 0), "A-Wall-Open": (0, 170, 0),
       "A-Roof-Wall": (200, 120, 0), "A-Wall-brickledge": (160, 0, 160)}
for s in segs:
    if s[4] in col:
        dr.line([((s[0] - x0) * S, (y1 - s[1]) * S), ((s[2] - x0) * S, (y1 - s[3]) * S)], fill=col[s[4]])
img.save(os.path.join(out, name + "_walls.png"))
print("bounds A-Wall", round(min(xs), 1), round(max(xs), 1), round(min(ys), 1), round(max(ys), 1))
