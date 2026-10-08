# JESB Lot 2 - one PDF of the four elevation PNGs (11 x 17 landscape, one per page).
# usage: python lot2_mkpdf_elevations.py <folder with the PNGs> <date>
import sys
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import pymupdf
src, date = sys.argv[1], sys.argv[2]
out = src + r"\JESB_Lot2_v4_Elevations.pdf"
views = [("Front", "Front Elevation"), ("Left", "Left Side Elevation"), ("Rear", "Rear Elevation"), ("Right", "Right Side Elevation")]
doc = pymupdf.open()
W, H = 17 * 72, 11 * 72
m, cap = 36, 34
for key, title in views:
    page = doc.new_page(width=W, height=H)
    page.insert_text((m, m + 14), "JESB Lot 2 - " + title, fontsize=16, fontname="helv")
    page.insert_text((W - m - 250, m + 14), "Model v4  |  SketchUp export  |  " + date, fontsize=9, fontname="helv", color=(0.35, 0.35, 0.35))
    page.insert_image(pymupdf.Rect(m, m + cap, W - m, H - m), filename=src + r"\JESB_Lot2_v4_Elevation_%s.png" % key, keep_proportion=True)
doc.set_metadata({"title": "JESB Lot 2 - Elevations (model v4)", "author": "", "subject": "Jade Estates, South Barrington - Lot 2"})
doc.save(out, deflate=True, garbage=3)
print(out, doc.page_count, "pages")
