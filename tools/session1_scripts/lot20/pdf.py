import sys
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import pymupdf
w = sys.argv[1]
d = pymupdf.open(r"C:\Projects\JESB\LOT20\Lot-20-ACC response.pdf")
print("pages", d.page_count, d.metadata.get("creationDate"), d.metadata.get("creator"))
for i, p in enumerate(d):
    t = " | ".join(x.strip() for x in p.get_text().split("\n") if x.strip())
    print("--- page", i, p.rect, "rot", p.rotation, "annots", len(list(p.annots() or [])))
    print(t[:1500])
    p.get_pixmap(dpi=45).save(w + "\\pg%02d.jpg" % i, jpg_quality=80)
