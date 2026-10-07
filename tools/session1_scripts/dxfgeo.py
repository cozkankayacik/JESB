import sys, collections
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import ezdxf
sp = sys.argv[1]
doc = ezdxf.readfile(sp + r"\lot2.dxf")
msp = doc.modelspace()

def pts(e):
    t = e.dxftype()
    if t == 'LINE':
        return [(e.dxf.start.x, e.dxf.start.y), (e.dxf.end.x, e.dxf.end.y)]
    if t == 'LWPOLYLINE':
        p = [(x, y) for x, y, *_ in e.get_points()]
        if e.closed and p: p.append(p[0])
        return p
    return []

# 1. inserts of interest
print('--- inserts')
for e in msp.query('INSERT'):
    n = e.dxf.name
    if 'OHDOOR' in n or n.startswith('A$C') or n.startswith('*U'):
        print(n, 'at (%.2f, %.2f)' % (e.dxf.insert.x, e.dxf.insert.y), 'rot', e.dxf.rotation, 'scale', e.dxf.xscale, e.dxf.yscale, 'layer', e.dxf.layer)

# 2. layer extents overall to locate drawings
print('--- layer bboxes (model space)')
bb = collections.defaultdict(lambda: [1e9, 1e9, -1e9, -1e9, 0])
for e in msp:
    for x, y in pts(e):
        b = bb[e.dxf.layer]
        b[0] = min(b[0], x); b[1] = min(b[1], y); b[2] = max(b[2], x); b[3] = max(b[3], y); b[4] += 1
for k in sorted(bb):
    b = bb[k]; print('%-14s n=%5d  x %.1f..%.1f  y %.1f..%.1f' % (k, b[4], b[0], b[2], b[1], b[3]))

# 3. roof plan region dump: everything with y between 1600 and 2300, x 10200..11500
print('--- roof plan region entities (x 10150..11500, y 1580..2300)')
for e in msp:
    p = pts(e)
    if not p: continue
    if all(10150 <= x <= 11500 and 1580 <= y <= 2300 for x, y in p):
        print(e.dxftype(), e.dxf.layer, 'lt=' + str(e.dxf.get('linetype', 'BYLAYER')), ' '.join('(%.2f,%.2f)' % q for q in p))
