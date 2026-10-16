import sys, os
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf, json
from PIL import Image, ImageDraw
W = sys.argv[1]
doc = ezdxf.readfile(os.path.join(W, 'xelev.dxf')); segs = []
def walk(ents, d=0):
    for e in ents:
        t = e.dxftype(); L = e.dxf.layer
        try:
            if t == 'LINE': segs.append((e.dxf.start.x, e.dxf.start.y, e.dxf.end.x, e.dxf.end.y, L))
            elif t == 'LWPOLYLINE':
                pts = [(p[0], p[1]) for p in e.get_points()]
                if e.closed: pts.append(pts[0])
                for a, b in zip(pts, pts[1:]): segs.append((a[0], a[1], b[0], b[1], L))
            elif t == 'ARC':
                import math
                c = e.dxf.center; r = e.dxf.radius; a0 = math.radians(e.dxf.start_angle); a1 = math.radians(e.dxf.end_angle)
                if a1 < a0: a1 += 2 * math.pi
                pts = [(c.x + r * math.cos(a0 + (a1 - a0) * i / 8), c.y + r * math.sin(a0 + (a1 - a0) * i / 8)) for i in range(9)]
                for a, b in zip(pts, pts[1:]): segs.append((a[0], a[1], b[0], b[1], L))
            elif t == 'INSERT' and d < 6: walk(list(e.virtual_entities()), d + 1)
        except Exception: pass
walk(doc.modelspace())
json.dump(segs, open(os.path.join(W, 'segs.json'), 'w'))
for i, (x0, x1) in enumerate([(2400, 3850), (3900, 4850), (4900, 6150), (6250, 7700)]):
    y0, y1 = 1290, 1800; S = 1.6
    img = Image.new('RGB', (int((x1 - x0) * S), int((y1 - y0) * S)), 'white'); d = ImageDraw.Draw(img)
    for s in segs:
        if x0 <= min(s[0], s[2]) and max(s[0], s[2]) <= x1 and y0 <= min(s[1], s[3]) and max(s[1], s[3]) <= y1:
            d.line([((s[0] - x0) * S, (y1 - s[1]) * S), ((s[2] - x0) * S, (y1 - s[3]) * S)], fill=(0, 0, 0))
    img.save(os.path.join(W, 'el%d.png' % i))
