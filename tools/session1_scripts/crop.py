import sys
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import pymupdf
sp = sys.argv[1]
d = pymupdf.open(r"C:\Projects\JESB\LOT2\Lot 2_revision1.pdf")
# (name, page, fractional rect of the displayed (rotated) page x0,y0,x1,y1, dpi)
jobs = [("roofplan",1,(0.52,0.02,0.88,0.46),150),("front_right",1,(0.50,0.44,0.90,0.95),150),("front_left",1,(0.18,0.44,0.56,0.95),150),
        ("sides",3,(0.0,0.0,0.92,1.0),80),("garage_plan",5,(0.22,0.20,0.52,0.72),150)]
for name,pg,(x0,y0,x1,y1),dpi in jobs:
    p = d[pg]; r = p.rect
    clip = pymupdf.Rect(r.x0+x0*r.width, r.y0+y0*r.height, r.x0+x1*r.width, r.y0+y1*r.height)
    pm = p.get_pixmap(dpi=dpi, clip=clip)
    pm.save(sp + "\\crop_%s.jpg" % name, jpg_quality=85); print(name, pm.width, pm.height)
