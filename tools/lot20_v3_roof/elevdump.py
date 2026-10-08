import sys
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf, collections, os
from PIL import Image, ImageDraw, ImageFont

W = os.path.dirname(os.path.abspath(__file__))
doc = ezdxf.readfile(os.path.join(W, 'lot20.dxf'))
msp = doc.modelspace()
BASE = -2280.0
segs = []
def add(a, b, L):
    segs.append((a[0], a[1] - BASE, b[0], b[1] - BASE, L))
def walk(ents, tf=None):
    for e in ents:
        t = e.dxftype()
        L = e.dxf.layer
        if t == 'LINE':
            add((e.dxf.start.x, e.dxf.start.y), (e.dxf.end.x, e.dxf.end.y), L)
        elif t == 'LWPOLYLINE':
            pts = [(p[0], p[1]) for p in e.get_points()]
            if e.closed: pts.append(pts[0])
            for a, b in zip(pts, pts[1:]): add(a, b, L)
        elif t == 'INSERT':
            try:
                walk(list(e.virtual_entities()))
            except Exception:
                pass
walk(msp)
elev = {'left': (-6560, -5420), 'front': (-5040, -3940), 'right': (-3580, -2440), 'rear': (-2300, -1220)}
lay = collections.Counter()
out = open(os.path.join(W, 'elevdump.txt'), 'w')
try:
    f = ImageFont.truetype('arial.ttf', 13)
except Exception:
    f = ImageFont.load_default()
for name, (x0, x1) in elev.items():
    ss = [s for s in segs if x0 <= min(s[0], s[2]) and max(s[0], s[2]) <= x1 and -130 <= min(s[1], s[3]) and max(s[1], s[3]) <= 420]
    for s in ss: lay[s[4]] += 1
    S = 2.6
    img = Image.new('RGB', (int((x1 - x0) * S), int(560 * S)), 'white')
    d = ImageDraw.Draw(img)
    def P(x, y): return ((x - x0) * S, (425 - y) * S)
    for s in ss:
        col = (200, 0, 0) if s[4] in ('1-ROOF', '4-ROOF') else (0, 0, 0)
        d.line([P(s[0], s[1]), P(s[2], s[3])], fill=col, width=1)
    # horizontal levels above 120
    lev = collections.defaultdict(list)
    slopes = []
    for s in ss:
        if max(s[1], s[3]) < 125: continue
        dx, dy = s[2] - s[0], s[3] - s[1]
        if abs(dy) < 0.05 and abs(dx) > 6:
            lev[round(s[1], 1)].append((min(s[0], s[2]), max(s[0], s[2]), s[4]))
        elif abs(dx) > 3 and abs(dy) > 3:
            slopes.append(s)
    out.write('===== %s  x %d..%d\n' % (name, x0, x1))
    out.write('-- horizontal levels (y above slab): level: [xmin..xmax layer]\n')
    for k in sorted(lev, reverse=True):
        items = sorted(lev[k])
        out.write('%7.1f: %s\n' % (k, ' '.join('[%.1f..%.1f %s]' % it for it in items[:9]) + (' +%d' % (len(items) - 9) if len(items) > 9 else '')))
    out.write('-- sloped (x1,y1)-(x2,y2) slope(in 12) layer, len>20\n')
    for s in sorted(slopes, key=lambda s: min(s[0], s[2])):
        dx, dy = s[2] - s[0], s[3] - s[1]
        if (dx * dx + dy * dy) ** 0.5 < 20: continue
        out.write('  (%.1f,%.1f)-(%.1f,%.1f) %.2f %s\n' % (s[0], s[1], s[2], s[3], abs(dy / dx) * 12, s[4]))
    # grid labels
    for y in range(0, 420, 20):
        d.line([P(x0, y), P(x0 + 8, y)], fill=(0, 0, 255))
        d.text(P(x0 + 10, y + 3), str(y), fill=(0, 0, 255), font=f)
    for x in range(int(x0 // 100 * 100), int(x1), 100):
        d.text(P(x, -112), str(x), fill=(0, 0, 255), font=f)
        d.line([P(x, -100), P(x, -92)], fill=(0, 0, 255))
    img.save(os.path.join(W, 'elev_%s.png' % name))
out.write('layers: %s\n' % dict(lay))
out.close()
print('ok', len(segs))
