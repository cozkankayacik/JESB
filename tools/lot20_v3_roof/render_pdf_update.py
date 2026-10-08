# Replace the page images of the render PDF with the updated PNGs, keeping its layout.
# usage: python render_pdf_update.py <existing pdf> <renders folder> <output pdf> [check folder]
import sys
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import pymupdf
src, folder, out = sys.argv[1:4]
doc = pymupdf.open(src)
order = []
for i, page in enumerate(doc):
    text = page.get_text().strip().replace("\n", " | ")
    imgs = page.get_images(full=True)
    side = next((s for s in ("Front", "Left", "Rear", "Right") if s.lower() in text.lower()), None)
    print("page", i + 1, page.rect, "images", [(im[0], im[2], im[3]) for im in imgs], "text:", text[:120], "->", side)
    if side is None or len(imgs) != 1:
        raise SystemExit("unexpected page structure on page %d" % (i + 1))
    page.replace_image(imgs[0][0], filename=folder + "\\JESB_Lot20_v3_Render_%s.png" % side)
    order.append(side)
doc.save(out, deflate=True, garbage=3)
print(out, order)
if len(sys.argv) > 4:
    d2 = pymupdf.open(out)
    for i, p in enumerate(d2):
        p.get_pixmap(dpi=45).save(sys.argv[4] + "\\rpdf_%d.jpg" % i)
