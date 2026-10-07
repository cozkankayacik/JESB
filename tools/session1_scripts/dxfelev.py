import sys, collections
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import ezdxf, pymupdf
s = sys.argv[1]
doc = ezdxf.readfile(s + r"\lot2.dxf"); msp = doc.modelspace()
regions = {"LEFT":(9380,10180),"FRONT":(10540,11680),"RIGHT":(12180,13000),"REAR":(13280,14320)}
def pts(e):
    t=e.dxftype()
    if t=="LINE": return [(e.dxf.start.x,e.dxf.start.y),(e.dxf.end.x,e.dxf.end.y)]
    if t=="LWPOLYLINE":
        p=[(x,y) for x,y,*_ in e.get_points()]
        if e.closed and p: p.append(p[0])
        return p
    return []
for name,(xa,xb) in regions.items():
    print("=====", name, xa, xb)
    hor = collections.defaultdict(list); other=[]
    for e in msp:
        if e.dxf.layer in ("1-HATCH","3-HATCH","1-WINDOW","3-WIN","1-GUTTERS","1-NOTES","1-TITLE","1-DIM"): continue
        p = pts(e)
        if not p or not all(xa<=x<=xb and 60<=y<=700 for x,y in p): continue
        lt = e.dxf.get("linetype","BYLAYER")
        for a,b in zip(p,p[1:]):
            L = ((a[0]-b[0])**2+(a[1]-b[1])**2)**0.5
            if L < 24: continue
            if abs(a[1]-b[1])<0.01:
                hor[(round(a[1],2), e.dxf.layer, lt)].append((min(a[0],b[0]),max(a[0],b[0])))
            elif abs(a[0]-b[0])>0.01 or (e.dxf.layer in ("0","1-FND","2-WALL","2-FOOT") ):
                other.append((e.dxf.layer, lt, a, b))
    for k in sorted(hor, key=lambda k:-k[0]):
        segs = sorted(hor[k]); print("H y=%8.2f %-8s %-9s %s" % (k[0],k[1],k[2]," ".join("%.1f..%.1f"%q for q in segs[:8]) + (" (+%d)"%(len(segs)-8) if len(segs)>8 else "")))
    for o in other:
        if o[0] in ("0","1-FND","2-WALL","2-FOOT","1-WALL","3-WALL","3-STAIR"):
            print("L %-7s %-9s (%.2f,%.2f)-(%.2f,%.2f)" % (o[0],o[1],o[2][0],o[2][1],o[3][0],o[3][1]))
d = pymupdf.open(r"C:\Projects\JESB\LOT2\Lot 2_revision1.pdf")
for name,pg,(x0,y0,x1,y1),dpi in [("front",1,(0.17,0.44,0.90,0.95),110),("rear",2,(0.22,0.30,0.92,0.82),110),("left",3,(0.25,0.0,0.92,0.50),130),("right",3,(0.25,0.48,0.95,1.0),130),("found",4,(0.22,0.06,0.92,0.90),100)]:
    p=d[pg]; r=p.rect
    pm=p.get_pixmap(dpi=dpi, clip=pymupdf.Rect(r.x0+x0*r.width,r.y0+y0*r.height,r.x0+x1*r.width,r.y0+y1*r.height)); pm.save(s+"\\el_%s.jpg"%name, jpg_quality=85); print(name, pm.width, pm.height)
