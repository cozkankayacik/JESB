"""Contact sheet of the ACC sample images: one column per lot, one row per item, labelled with the selection text.
Usage: python -I acc_contact_sheet.py <dump_dir> <out.png> [lot columns e.g. B,D,F,H,J,L,N,P]
"""
import sys, os
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
from PIL import Image, ImageDraw

d = sys.argv[1]; out = sys.argv[2]
cols = (sys.argv[3] if len(sys.argv) > 3 else "B,D,F,H,J,L,N,P").split(",")
cells = {}
for line in open(os.path.join(d, "acc_cells.tsv"), encoding="utf8"):
    p = line.rstrip("\n").split("\t")
    if p[0] == "EXTERIOR":
        cells[p[1]] = p[2]
imgs = {}
for line in open(os.path.join(d, "acc_images.tsv"), encoding="utf8"):
    p = line.rstrip("\n").split("\t")
    if p[0] == "EXTERIOR":
        imgs[p[1]] = os.path.join(d, p[5])
rows = list(range(9, 33, 2))


def nxt(c):
    n = 0
    for ch in c:
        n = n * 26 + ord(ch) - 64
    n += 1
    s = ""
    while n:
        n, r = divmod(n - 1, 26)
        s = chr(65 + r) + s
    return s


CW, RH, T = 230, 150, 34
sheet = Image.new("RGB", (190 + CW * len(cols), 40 + RH * len(rows)), "white")
dr = ImageDraw.Draw(sheet)
for j, c in enumerate(cols):
    dr.text((190 + j * CW + 6, 12), cells.get(c + "2", c), fill=(0, 0, 0))
for i, r in enumerate(rows):
    y = 40 + i * RH
    dr.text((6, y + 6), cells.get("A%d" % r, ""), fill=(0, 0, 0))
    dr.line([(0, y), (sheet.width, y)], fill=(210, 210, 210))
    for j, c in enumerate(cols):
        x = 190 + j * CW
        dr.text((x + 4, y + 4), (cells.get("%s%d" % (c, r), "") or "-")[:34], fill=(20, 20, 120))
        sel = cells.get("%s%d" % (c, r + 1), "")
        dr.text((x + 4, y + 18), "selection: %s" % sel, fill=(120, 120, 120))
        p = imgs.get("%s%d" % (nxt(c), r))
        if p:
            im = Image.open(p).convert("RGB")
            im.thumbnail((CW - 10, RH - T - 6))
            sheet.paste(im, (x + 4, y + T))
sheet.save(out)
print("written", out, sheet.size)
