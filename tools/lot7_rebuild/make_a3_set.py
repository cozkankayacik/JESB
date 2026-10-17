"""Projades A3 review set for JESB Lot 7 (layout copied from PROJADES_A3_Title_Block_Template.pdf:
420 x 297 mm landscape, 28 pt border, title block band y 746.9..813.9 with dividers at x 276 / 718 / 900 / 1038,
Arial / Arial Bold, colours #17332F / #66736F / #B1663C).

Usage: python -I make_a3_set.py <sheets.json> <out.pdf>
sheets.json: {"revision": "R01", "date": "16.10.2026", "sheets": [{"no": "A-101", "title": "...", "subtitle": "...",
              "images": ["path", ...], "layout": "single" | "grid2x2" | "cover", "notes": ["..."]}]}
"""
import sys, json
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import pymupdf
from PIL import Image, ImageChops

SPEC = json.load(open(sys.argv[1], encoding="utf-8-sig"))
OUT = sys.argv[2]
W, H = 1190.551, 841.890
DARK = (0x17 / 255, 0x33 / 255, 0x2F / 255)
GREY = (0x66 / 255, 0x73 / 255, 0x6F / 255)
ACCENT = (0xB1 / 255, 0x66 / 255, 0x3C / 255)
TEAL = (0x27 / 255, 0x76 / 255, 0x6E / 255)
F_REG = r"C:\Windows\Fonts\arial.ttf"
F_BOLD = r"C:\Windows\Fonts\arialbd.ttf"
ASC = 0.905   # Arial ascent: baseline = top + size * ASC


def text(page, x, top, s, size, bold=False, color=DARK):
    page.insert_text((x, top + size * ASC), s, fontsize=size, fontname="ArialB" if bold else "Arial",
                     fontfile=F_BOLD if bold else F_REG, color=color)


def trimmed(path, pad=30):
    """Crop uniform background around the drawing (keeps a small margin)."""
    im = Image.open(path).convert("RGB")
    bg = Image.new("RGB", im.size, im.getpixel((2, 2)))
    diff = ImageChops.difference(im, bg).convert("L").point(lambda v: 255 if v > 18 else 0)
    bb = diff.getbbox()
    if bb:
        bb = (max(0, bb[0] - pad), max(0, bb[1] - pad), min(im.width, bb[2] + pad), min(im.height, bb[3] + pad))
        im = im.crop(bb)
    import tempfile, os as _os
    tmp = _os.path.join(tempfile.gettempdir(), "a3_" + _os.path.basename(path).replace(".png", "_trim.png"))
    im.save(tmp)
    return tmp, im.size


def place(page, path, rect, trim=True):
    p, (iw, ih) = trimmed(path) if trim else (path, Image.open(path).size)
    s = min(rect.width / iw, rect.height / ih)
    w, h = iw * s, ih * s
    r = pymupdf.Rect(rect.x0 + (rect.width - w) / 2, rect.y0 + (rect.height - h) / 2,
                     rect.x0 + (rect.width + w) / 2, rect.y0 + (rect.height + h) / 2)
    page.insert_image(r, filename=p)
    return r


def frame(page, sh):
    page.draw_rect(pymupdf.Rect(28, 28, W - 28, H - 28), color=DARK, width=0.65)
    page.draw_line((28, 746.9), (W - 28, 746.9), color=DARK, width=0.65)
    for x in (276, 718, 900, 1038):
        page.draw_line((x, 746.9), (x, H - 28), color=DARK, width=0.65)
    text(page, 44, 47.2, sh["title"], 23, True)
    text(page, 44, 79.5, sh.get("subtitle", ""), 11, False, GREY)
    # title block
    text(page, 44, 763.0, "PROJADES", 23, True)
    text(page, 44, 794.1, "ARCHITECTURE / DESIGN STUDY", 7.5, False, GREY)
    text(page, 292, 759.6, "JADE ESTATES - LOT 7", 12, True)
    text(page, 292, 779.1, "South Barrington, Illinois", 10)
    text(page, 292, 796.7, SPEC.get("set_label", "EXTERIOR MODEL / REVIEW SET - NOT FOR CONSTRUCTION"), 8, False, ACCENT)
    text(page, 734, 761.1, SPEC.get("rev_label", "MODEL ") + SPEC["revision"], 10, True)
    text(page, 734, 780.9, "A3 / 420 x 297 mm", 9)
    text(page, 734, 797.7, sh.get("scale", "FIT TO SHEET / NTS"), 8)
    text(page, 916, 761.1, SPEC["date"], 10)
    text(page, 916, 782.9, "REVISION " + SPEC["revision"], 9)
    text(page, 1052, 761.0, sh["no"], 14, True)
    text(page, 1052, 791.7, "PROJADES", 8)


doc = pymupdf.open()
AREA = pymupdf.Rect(44, 104, W - 44, 736)
for sh in SPEC["sheets"]:
    page = doc.new_page(width=W, height=H)
    frame(page, sh)
    lay = sh.get("layout", "single")
    imgs = sh.get("images", [])
    if lay == "single":
        place(page, imgs[0], AREA)
    elif lay == "grid2x2":
        gx, gy = (AREA.width - 16) / 2, (AREA.height - 16) / 2
        cap = 14 if sh.get("captions") else 0          # caption band under each image
        for i, p in enumerate(imgs[:4]):
            r = pymupdf.Rect(AREA.x0 + (i % 2) * (gx + 16), AREA.y0 + (i // 2) * (gy + 16),
                             AREA.x0 + (i % 2) * (gx + 16) + gx, AREA.y0 + (i // 2) * (gy + 16) + gy - cap)
            ri = place(page, p, r)
            if cap:
                text(page, ri.x0, ri.y1 + 3, sh["captions"][i], 8, True, TEAL)
    elif lay == "cover":
        img_r = pymupdf.Rect(AREA.x0, AREA.y0, AREA.x0 + 760, AREA.y1)
        place(page, imgs[0], img_r, trim=False)
        x = AREA.x0 + 790
        y = AREA.y0
        text(page, x, y, "SHEET INDEX", 10, True); y += 18
        for no, t in sh["index"]:
            text(page, x, y, no, 8.5, True); text(page, x + 48, y, t, 8.5); y += 14
        y += 12
        text(page, x, y, "NOTES", 10, True); y += 18
        for n in sh.get("notes", []):
            # simple word wrap at ~52 characters
            line = ""
            for wd in n.split():
                if len(line) + len(wd) > 52:
                    text(page, x, y, line, 8, False, GREY); y += 11; line = ""
                line += ("" if not line else " ") + wd
            if line:
                text(page, x, y, line, 8, False, GREY); y += 11
            y += 5
doc.save(OUT, garbage=3, deflate=True)
print("written", OUT, len(doc), "pages")
