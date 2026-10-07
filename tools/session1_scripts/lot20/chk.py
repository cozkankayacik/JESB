import sys, collections
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import ezdxf, pymupdf
w = sys.argv[1]
doc = ezdxf.readfile(w + r"\lot20.dxf"); msp = doc.modelspace()
print("--- front elevation: long horizontal lines, height above ground (y+2280)")
H = collections.defaultdict(float)
for e in msp.query("LINE"):
    a, b = e.dxf.start, e.dxf.end
    if abs(a.y-b.y) < 0.01 and -5020 <= min(a.x,b.x) and max(a.x,b.x) <= -3960 and -2281 <= a.y <= -1860 and e.dxf.layer in ("1-WALL","1-TRIM","1-GUTTERS"):
        H[(round(a.y+2280,1), e.dxf.layer)] += abs(a.x-b.x)
for k in sorted(H, reverse=True):
    if H[k] >= 80: print("  z=%7.1f %-10s total len %.0f" % (k[0], k[1], H[k]))
print("--- front elevation peaks (max y of sloped 1-WALL lines by x)")
for e in msp.query("LINE"):
    a, b = e.dxf.start, e.dxf.end
    if e.dxf.layer == "1-WALL" and abs(a.y-b.y) > 5 and abs(a.x-b.x) > 5 and -5020 <= min(a.x,b.x) and max(a.x,b.x) <= -3960 and a.y > -2281:
        print("  slope (%.0f,%.1f)-(%.0f,%.1f) pitch %.2f:12" % (a.x, a.y+2280, b.x, b.y+2280, abs((b.y-a.y)/(b.x-a.x))*12))
print("--- hatches in elevation band (pattern, layer, bbox)")
for e in msp.query("HATCH"):
    try:
        pts = []
        for p in e.paths:
            if hasattr(p, "vertices"): pts += [(v[0], v[1]) for v in p.vertices]
            else:
                for ed in p.edges:
                    if hasattr(ed, "start"): pts += [(ed.start[0], ed.start[1]), (ed.end[0], ed.end[1])]
        if not pts: continue
        xs=[p[0] for p in pts]; ys=[p[1] for p in pts]
        if max(ys) < -1860 and min(ys) > -2300:
            print("  %-10s %-8s scale %.1f x %.0f..%.0f z %.0f..%.0f" % (e.dxf.pattern_name, e.dxf.layer, e.dxf.get("pattern_scale",0), min(xs), max(xs), min(ys)+2280, max(ys)+2280))
    except Exception as ex:
        print("  hatch err", ex)
d = pymupdf.open(r"C:\Projects\JESB\LOT20\Lot-20-ACC response.pdf")
for name,pg,(x0,y0,x1,y1),dpi in [("front",1,(0.16,0.42,0.92,0.97),105),("rear",2,(0.16,0.25,0.95,0.85),100),("sides",3,(0.0,0.0,0.93,1.0),80)]:
    p=d[pg]; r=p.rect
    p.get_pixmap(dpi=dpi, clip=pymupdf.Rect(r.x0+x0*r.width,r.y0+y0*r.height,r.x0+x1*r.width,r.y0+y1*r.height)).save(w+"\\pdf_%s.jpg"%name, jpg_quality=85)
