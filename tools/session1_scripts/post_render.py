"""Finish the V-Ray elevation renders: put a soft sky gradient behind the model (using the alpha channel) and build the PDF."""
import sys
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import numpy as np
from PIL import Image
import pymupdf

src = sys.argv[1]
dst = r"C:\Projects\JESB\LOT2\exports_v4_new\renders_vray"
views = [("Front", "Front Elevation"), ("Left", "Left Side Elevation"), ("Rear", "Rear Elevation"), ("Right", "Right Side Elevation")]
top = np.array([126, 168, 214], dtype=np.float32)
hor = np.array([222, 232, 242], dtype=np.float32)

for key, _ in views:
    rgb = np.asarray(Image.open(rf"{src}\JESB_Lot2_v4_Render_{key}.png").convert("RGB")).astype(np.float32)
    # tone: +0.45 stop and a slightly cooler white balance, done in linear light
    lin = (rgb / 255.0) ** 2.2 * 1.37 * np.array([0.97, 1.0, 1.09], dtype=np.float32)
    rgb = np.clip(lin, 0, 1) ** (1 / 2.2) * 255.0
    a = np.asarray(Image.open(rf"{src}\JESB_Lot2_v4_Render_{key}.Alpha.png").convert("L")).astype(np.float32) / 255.0
    h, w = a.shape
    # horizon = lowest row that still has sky
    rows = np.where((a < 0.5).any(axis=1))[0]
    y_h = rows.max() if len(rows) else h - 1
    t = np.clip(np.arange(h, dtype=np.float32) / max(y_h, 1), 0, 1)[:, None, None]
    sky = top * (1 - t) ** 1.3 + hor * (1 - (1 - t) ** 1.3)
    sky = np.broadcast_to(sky, (h, w, 3))
    out = rgb * a[..., None] + sky * (1 - a[..., None])
    Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).save(rf"{dst}\JESB_Lot2_v4_Render_{key}.png", optimize=True)
    print(key, w, h, "horizon row", y_h, "mean", out.mean(axis=(0, 1)).round(1))

pdf = rf"{dst}\JESB_Lot2_v4_Elevations_Render.pdf"
doc = pymupdf.open()
W, H = 17 * 72, 11 * 72
m, cap = 36, 34
for key, title in views:
    page = doc.new_page(width=W, height=H)
    page.insert_text((m, m + 14), "JESB Lot 2 - " + title, fontsize=16, fontname="helv")
    page.insert_text((W - m - 262, m + 14), "Model v4  |  V-Ray render  |  2026-10-07", fontsize=9, fontname="helv", color=(0.35, 0.35, 0.35))
    im = Image.open(rf"{dst}\JESB_Lot2_v4_Render_{key}.png")
    tmp = rf"{src}\_pdf_{key}.jpg"
    im.save(tmp, quality=92)
    page.insert_image(pymupdf.Rect(m, m + cap, W - m, H - m), filename=tmp, keep_proportion=True)
doc.set_metadata({"title": "JESB Lot 2 - Elevations, V-Ray renders (model v4)", "subject": "Jade Estates, South Barrington - Lot 2"})
doc.save(pdf, deflate=True, garbage=3)
print(pdf, doc.page_count, "pages")

