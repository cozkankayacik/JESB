import sys, os, collections
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf
from PIL import Image, ImageDraw
W = sys.argv[1]
doc = ezdxf.readfile(os.path.join(W, 'xelev.dxf')); segs = []; texts = []
def walk(ents, d=0):
    for e in ents:
        t = e.dxftype(); L = e.dxf.layer
        try:
            if t == 'LINE': segs.append((e.dxf.start.x, e.dxf.start.y, e.dxf.end.x, e.dxf.end.y, L))
            elif t in ('LWPOLYLINE',):
                pts = [(p[0], p[1]) for p in e.get_points()]
                if e.closed: pts.append(pts[0])
                for a, b in zip(pts, pts[1:]): segs.append((a[0], a[1], b[0], b[1], L))
            elif t in ('TEXT', 'MTEXT'):
                s = e.dxf.text if t == 'TEXT' else e.text
                texts.append((e.dxf.insert.x, e.dxf.insert.y, L, s[:70].replace('\n', ' ')))
            elif t == 'INSERT' and d < 6:
                walk(list(e.virtual_entities()), d + 1)
        except Exception: pass
walk(doc.modelspace())
print('units', doc.header.get('$INSUNITS'), 'segments', len(segs), 'texts', len(texts))
cnt = collections.Counter(s[4] for s in segs); print(cnt.most_common(30))
for t in texts:
    if any(k in t[3].upper() for k in ('ELEVATION', 'GRADE', 'FLOOR', 'DOOR', 'ENTRY', 'TRANSOM', 'FIX', 'PLATE')): print('  TXT %.0f %.0f %s | %s' % t)
xs = sorted(v for s in segs for v in (s[0], s[2])); ys = sorted(v for s in segs for v in (s[1], s[3]))
q = lambda a, f: a[int(len(a) * f)]
x0, x1, y0, y1 = q(xs, .002), q(xs, .998), q(ys, .002), q(ys, .998)
print('extent x %.0f..%.0f y %.0f..%.0f' % (x0, x1, y0, y1))
S = 2400 / (x1 - x0)
img = Image.new('RGB', (2400, int((y1 - y0) * S) + 20), 'white'); d = ImageDraw.Draw(img)
for s in segs: d.line([((s[0] - x0) * S, (y1 - s[1]) * S + 10), ((s[2] - x0) * S, (y1 - s[3]) * S + 10)], fill=(0, 0, 0))
img.save(os.path.join(W, 'all.png')); print(img.size)
