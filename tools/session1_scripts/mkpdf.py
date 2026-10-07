import sys
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import pymupdf
src = r"C:\Projects\JESB\LOT2\exports_v4"
out = r"C:\Projects\JESB\LOT2\exports_v4_new\JESB_Lot2_v4_Elevations.pdf"
views = [("Front", "Front Elevation"), ("Left", "Left Side Elevation"), ("Rear", "Rear Elevation"), ("Right", "Right Side Elevation")]
doc = pymupdf.open()
W, H = 17 * 72, 11 * 72          # 11 x 17 landscape
m, cap = 36, 34
for key, title in views:
    page = doc.new_page(width=W, height=H)
    page.insert_text((m, m + 14), "JESB Lot 2 - " + title, fontsize=16, fontname="helv")
    page.insert_text((W - m - 250, m + 14), "Model v4  |  SketchUp export  |  2026-10-07", fontsize=9, fontname="helv", color=(0.35, 0.35, 0.35))
    page.insert_image(pymupdf.Rect(m, m + cap, W - m, H - m), filename=src + r"\JESB_Lot2_v4_Elevation_%s.png" % key, keep_proportion=True)
doc.set_metadata({"title": "JESB Lot 2 - Elevations (model v4)", "author": "", "subject": "Jade Estates, South Barrington - Lot 2"})
doc.save(out, deflate=True, garbage=3)
print(out, doc.page_count, "pages")
d2 = pymupdf.open(out)
for i, p in enumerate(d2):
    p.get_pixmap(dpi=40).save(sys.argv[1] + "\\pdfchk_%d.jpg" % i)

