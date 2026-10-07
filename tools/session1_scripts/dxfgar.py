import sys
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import ezdxf
sp = sys.argv[1]
doc = ezdxf.readfile(sp + r"\lot2.dxf")
msp = doc.modelspace()
def pts(e):
    t = e.dxftype()
    if t == 'LINE': return [(e.dxf.start.x, e.dxf.start.y), (e.dxf.end.x, e.dxf.end.y)]
    if t == 'LWPOLYLINE':
        p = [(x, y) for x, y, *_ in e.get_points()]
        if e.closed and p: p.append(p[0])
        return p
    return []
print('--- first floor plan, garage west wall strip (x 10600..10660, y 3230..3780)')
for e in msp:
    p = pts(e)
    if p and all(10600 <= x <= 10660 and 3230 <= y <= 3780 for x, y in p):
        print(e.dxftype(), e.dxf.layer, e.dxf.get('linetype','BYLAYER'), ' '.join('(%.2f,%.2f)' % q for q in p))
print('--- texts near garage')
for e in msp.query('MTEXT TEXT'):
    ip = e.dxf.insert
    if 10560 <= ip.x <= 10700 and 3230 <= ip.y <= 3780:
        print(e.dxftype(), e.dxf.layer, '(%.1f,%.1f)' % (ip.x, ip.y), repr(e.plain_text() if e.dxftype()=='MTEXT' else e.dxf.text))
print('--- left elevation: door-ish geometry, layers 1-DOOR/1-FND/1-WALL, x 9400..10150, y 150..360 (LWPOLYLINE + long LINEs)')
for e in msp:
    p = pts(e)
    if not p or e.dxf.layer not in ('1-DOOR','1-FND','1-WALL','1-TRIM','5-REVISIONS','0'): continue
    if all(9400 <= x <= 10150 and 150 <= y <= 360 for x, y in p):
        xs=[q[0] for q in p]; ys=[q[1] for q in p]
        if max(xs)-min(xs) > 60 or max(ys)-min(ys) > 60:
            print(e.dxftype(), e.dxf.layer, ' '.join('(%.2f,%.2f)' % q for q in p[:8]))
print('--- block 16080 OHDOOR 16P extents')
b = doc.blocks.get('16080 OHDOOR 16P')
xs=[];ys=[]
for e in b:
    for x,y in pts(e): xs.append(x); ys.append(y)
print(min(xs),max(xs),min(ys),max(ys), 'n', len(list(b)))
