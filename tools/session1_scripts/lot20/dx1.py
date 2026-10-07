import sys, collections
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import ezdxf
w = sys.argv[1]
doc = ezdxf.readfile(w + r"\lot20.dxf"); msp = doc.modelspace()
h = doc.header
print("ver", h.get("$ACADVER"), "units", h.get("$INSUNITS"), "extmin", h.get("$EXTMIN"), "extmax", h.get("$EXTMAX"), "lastsaved", h.get("$LASTSAVEDBY"))
print("layouts", [l.name for l in doc.layouts])
cnt = collections.Counter(e.dxftype() for e in msp); print("entities", dict(cnt))
print("--- layers bbox (LINE/LWPOLYLINE)")
bb = collections.defaultdict(lambda: [1e9,1e9,-1e9,-1e9,0])
def pts(e):
    t=e.dxftype()
    if t=="LINE": return [(e.dxf.start.x,e.dxf.start.y),(e.dxf.end.x,e.dxf.end.y)]
    if t=="LWPOLYLINE": return [(x,y) for x,y,*_ in e.get_points()]
    return []
for e in msp:
    for x,y in pts(e):
        b=bb[e.dxf.layer]; b[0]=min(b[0],x); b[1]=min(b[1],y); b[2]=max(b[2],x); b[3]=max(b[3],y); b[4]+=1
for k in sorted(bb):
    b=bb[k]; print("  %-16s n=%5d x %.0f..%.0f y %.0f..%.0f" % (k,b[4],b[0],b[2],b[1],b[3]))
print("--- texts (titles/rooms/areas)")
for e in msp.query("MTEXT TEXT"):
    t = (e.plain_text() if e.dxftype()=="MTEXT" else e.dxf.text).replace("\n"," / ").strip()
    if not t: continue
    L = e.dxf.layer
    if L in ("Data",): continue
    ip = e.dxf.insert
    print("  %-10s (%.0f,%.0f) %s" % (L, ip.x, ip.y, t[:90]))
print("--- inserts")
ic = collections.Counter(); pos = collections.defaultdict(list)
for e in msp.query("INSERT"):
    ic[e.dxf.name]+=1; pos[e.dxf.name].append((round(e.dxf.insert.x),round(e.dxf.insert.y),round(e.dxf.rotation),e.dxf.layer))
for k,v in ic.most_common(): print("  %3d %s %s" % (v,k, pos[k][:4] if ("DOOR" in k.upper() or "WND" in k.upper() or v<=2) else ""))
print("--- revision clouds (polylines with many bulge segments)")
for e in msp.query("LWPOLYLINE"):
    p = list(e.get_points("xyb"))
    nb = sum(1 for q in p if abs(q[2])>0.2)
    if nb >= 8:
        xs=[q[0] for q in p]; ys=[q[1] for q in p]
        print("  layer %-14s n=%3d bbox x %.0f..%.0f y %.0f..%.0f" % (e.dxf.layer, len(p), min(xs),max(xs),min(ys),max(ys)))
