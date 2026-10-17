"""Flatten a DXF into line segments (with layer) and render previews.

Usage: python -I dxf_segments.py <in.dxf> <out_dir> <name> [x0 x1 y0 y1 scale]
Writes <name>_segs.json  [[x0,y0,x1,y1,layer], ...]  (inserts exploded, arcs/circles split)
and, if a window is given, <name>_preview.png.
"""
import sys, os, math, json
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf
from PIL import Image, ImageDraw

src, out, name = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(out, exist_ok=True)
doc = ezdxf.readfile(src)
segs = []


def add_pts(pts, layer):
    for a, b in zip(pts, pts[1:]):
        segs.append((a[0], a[1], b[0], b[1], layer))


def walk(ents, depth=0, parent_layer=None):
    for e in ents:
        t = e.dxftype()
        layer = e.dxf.layer
        if layer == "0" and parent_layer:
            layer = parent_layer
        try:
            if t == "LINE":
                segs.append((e.dxf.start.x, e.dxf.start.y, e.dxf.end.x, e.dxf.end.y, layer))
            elif t in ("LWPOLYLINE", "POLYLINE"):
                pts = [(p[0], p[1]) for p in (e.get_points() if t == "LWPOLYLINE" else e.points())]
                if e.is_closed:
                    pts.append(pts[0])
                add_pts(pts, layer)
            elif t in ("ARC", "CIRCLE"):
                c, r = e.dxf.center, e.dxf.radius
                a0 = math.radians(e.dxf.start_angle) if t == "ARC" else 0.0
                a1 = math.radians(e.dxf.end_angle) if t == "ARC" else 2 * math.pi
                if a1 < a0:
                    a1 += 2 * math.pi
                n = max(4, int((a1 - a0) / (math.pi / 16)))
                add_pts([(c.x + r * math.cos(a0 + (a1 - a0) * i / n), c.y + r * math.sin(a0 + (a1 - a0) * i / n)) for i in range(n + 1)], layer)
            elif t == "INSERT" and depth < 6:
                walk(list(e.virtual_entities()), depth + 1, layer)
        except Exception:
            pass


walk(doc.modelspace())
json.dump(segs, open(os.path.join(out, name + "_segs.json"), "w"))
print(len(segs), "segments")

if len(sys.argv) > 4:
    x0, x1, y0, y1, S = map(float, sys.argv[4:9])
    img = Image.new("RGB", (int((x1 - x0) * S), int((y1 - y0) * S)), "white")
    d = ImageDraw.Draw(img)
    for s in segs:
        if x0 <= min(s[0], s[2]) and max(s[0], s[2]) <= x1 and y0 <= min(s[1], s[3]) and max(s[1], s[3]) <= y1:
            d.line([((s[0] - x0) * S, (y1 - s[1]) * S), ((s[2] - x0) * S, (y1 - s[3]) * S)], fill=(0, 0, 0))
    img.save(os.path.join(out, name + "_preview.png"))
