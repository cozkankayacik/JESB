import sys
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import fitz
sp = sys.argv[1]
d = fitz.open(r"C:\Projects\JESB\LOT2\Lot 2_revision1.pdf")
for i, p in enumerate(d):
    print(i, p.rect, p.rotation)
    pm = p.get_pixmap(dpi=45)
    pm.save(sp + r"\page%02d.jpg" % i, jpg_quality=80)
    print("  ", pm.width, pm.height)
