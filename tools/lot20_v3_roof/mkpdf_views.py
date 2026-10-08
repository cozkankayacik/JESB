# Build the one-file PDF of the Lot 20 views (11 x 17 landscape, one view per page) from the PNG exports.
# usage: python mkpdf_views.py <exports folder> <prefix, e.g. JESB_Lot20_v3> <label, e.g. "Model v3"> <date> [check folder]
import sys
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import pymupdf
src, prefix, label, date = sys.argv[1:5]
out = src + "\\%s_Views.pdf" % prefix
# elevations only: the user asked for the perspective page to be left out (2026-10-08)
views = [("Elevation_Front", "Front Elevation"), ("Elevation_Left", "Left Side Elevation"), ("Elevation_Rear", "Rear Elevation"),
         ("Elevation_Right", "Right Side Elevation")]
doc = pymupdf.open()
W, H = 17 * 72, 11 * 72
m, cap = 36, 34
for key, title in views:
    page = doc.new_page(width=W, height=H)
    page.insert_text((m, m + 14), "JESB Lot 20 - " + title, fontsize=16, fontname="helv")
    page.insert_text((W - m - 250, m + 14), "%s  |  SketchUp export  |  %s" % (label, date), fontsize=9, fontname="helv", color=(0.35, 0.35, 0.35))
    page.insert_image(pymupdf.Rect(m, m + cap, W - m, H - m), filename=src + "\\%s_%s.png" % (prefix, key), keep_proportion=True)
doc.set_metadata({"title": "JESB Lot 20 - Views (%s)" % label.lower(), "author": "", "subject": "Jade Estates, South Barrington - Lot 20"})
doc.save(out, deflate=True, garbage=3)
print(out, doc.page_count, "pages")
if len(sys.argv) > 5:
    d2 = pymupdf.open(out)
    for i, p in enumerate(d2):
        p.get_pixmap(dpi=40).save(sys.argv[5] + "\\pdfchk_%d.jpg" % i)
