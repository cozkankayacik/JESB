import sys
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf, collections, os
from PIL import Image, ImageDraw, ImageFont

W = os.path.dirname(os.path.abspath(__file__))
doc = ezdxf.readfile(os.path.join(W, 'lot20.dxf'))
msp = doc.modelspace()

def segs(layer):
    out = []
    for e in msp:
        if e.dxf.layer != layer:
            continue
        t = e.dxftype()
        if t == 'LINE':
            out.append(((e.dxf.start.x, e.dxf.start.y), (e.dxf.end.x, e.dxf.end.y), t))
        elif t == 'LWPOLYLINE':
            pts = [(p[0], p[1]) for p in e.get_points()]
            if e.closed:
                pts.append(pts[0])
            for a, b in zip(pts, pts[1:]):
                out.append((a, b, t))
        else:
            out.append((None, None, t))
    return out

verts = []
def vid(p):
    for i, q in enumerate(verts):
        if abs(q[0] - p[0]) < 0.3 and abs(q[1] - p[1]) < 0.3:
            return i
    verts.append(p)
    return len(verts) - 1

layers = {'4-ROOF': (0, 0, 0), '4-WALL': (0, 140, 255)}
edges = collections.defaultdict(list)
other = collections.Counter()
for L in layers:
    for a, b, t in segs(L):
        if a is None:
            other[(L, t)] += 1
            continue
        i, j = vid(a), vid(b)
        if i != j:
            edges[L].append((i, j))

X0, Y1 = -4975, 185
S = 3.4
def P(p): return ((p[0] - X0) * S, (Y1 - p[1]) * S)
img = Image.new('RGB', (int(960 * S), int(930 * S)), 'white')
d = ImageDraw.Draw(img)
try:
    f = ImageFont.truetype('arial.ttf', 15)
except Exception:
    f = ImageFont.load_default()
for L, col in layers.items():
    for i, j in edges[L]:
        d.line([P(verts[i]), P(verts[j])], fill=col, width=2 if L == '4-ROOF' else 1)
used_roof = set(i for e in edges['4-ROOF'] for i in e)
for i, v in enumerate(verts):
    if i in used_roof:
        x, y = P(v)
        d.ellipse([x - 3, y - 3, x + 3, y + 3], fill=(220, 0, 0))
        d.text((x + 4, y - 16), str(i), fill=(200, 0, 0), font=f)
img.save(os.path.join(W, 'roof_labeled.png'))

with open(os.path.join(W, 'roofdump.txt'), 'w') as o:
    o.write('other entity types: %s\n' % dict(other))
    o.write('--- vertices (roof-used marked R)\n')
    for i, v in enumerate(verts):
        o.write('%3d %s %9.2f %9.2f\n' % (i, 'R' if i in used_roof else 'w', v[0], v[1]))
    for L in layers:
        o.write('--- edges %s (%d)\n' % (L, len(edges[L])))
        o.write(' '.join('%d-%d' % e for e in edges[L]) + '\n')
print(len(verts), {k: len(v) for k, v in edges.items()}, dict(other))
