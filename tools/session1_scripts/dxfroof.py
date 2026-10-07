import sys
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import ezdxf
doc = ezdxf.readfile(sys.argv[1] + r"\lot2.dxf"); msp = doc.modelspace()
print("--- all 4-ROOF / 4-WALL lines, model coords (dx -7873.70, dy +4684.40)")
for e in msp.query("LINE"):
    if e.dxf.layer in ("4-ROOF","4-WALL"):
        a=e.dxf.start; b=e.dxf.end
        print("%s (%.2f,%.2f)-(%.2f,%.2f)  dwg (%.2f,%.2f)-(%.2f,%.2f)" % (e.dxf.layer[2:], a.x-7873.70,a.y+4684.40,b.x-7873.70,b.y+4684.40,a.x,a.y,b.x,b.y))
print("--- first floor plan: garage door openings and west wall ends (3-DOOR / 3-WALL at x 10620..10640)")
for e in msp:
    if e.dxftype() in ("LINE","LWPOLYLINE") and e.dxf.layer in ("3-DOOR","3-WALL","3-STAIR"):
        p = [(e.dxf.start.x,e.dxf.start.y),(e.dxf.end.x,e.dxf.end.y)] if e.dxftype()=="LINE" else [(x,y) for x,y,*_ in e.get_points()]
        if all(10620<=x<=10640 and 3380<=y<=3900 for x,y in p):
            print(e.dxf.layer, " ".join("(%.2f,%.2f)"%q for q in p))
