"""Extract the A-220 roof plan vectors from the architectural PDF and place them in the DWG plan frame.

Usage: python -I roofplan_extract.py <set.pdf> <page_no> <xflr2_plan_segs.json> <out_dir>
Scale: 1/4" = 1'-0"  ->  1 pt = 2/3 in.  Translation found by voting on axis-aligned lines against the
second floor plan (exterior wall faces and the lower-roof outlines drawn in xflr2).
Writes roofplan_segs.json ([x0,y0,x1,y1,width] in plan inches) and roofplan_overlay.png.
"""
import sys, os, json, collections
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import pymupdf
from PIL import Image, ImageDraw

pdf, pg, ref, out = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
page = pymupdf.open(pdf)[pg - 1]
rm = page.rotation_matrix
K = 2.0 / 3.0
raw = []
for d in page.get_drawings():
    for it in d["items"]:
        if it[0] == "l":
            ps = [it[1], it[2]]
        elif it[0] == "re":
            r = it[1]; ps = [r.tl, r.tr, r.br, r.bl, r.tl]
        elif it[0] == "qu":
            q = it[1]; ps = [q.ul, q.ur, q.lr, q.ll, q.ul]
        else:
            continue
        for a, b in zip(ps, ps[1:]):
            A, B = a * rm, b * rm
            raw.append((A.x * K, -A.y * K, B.x * K, -B.y * K, d.get("width") or 0))

R = [s for s in json.load(open(ref)) if s[4] in ("A-Wall", "A-Elev-Otln", "A-Roof-Wall")]


def axis_lines(ss, minlen):
    V, H = [], []
    for s in ss:
        if abs(s[0] - s[2]) < 0.05 and abs(s[1] - s[3]) > minlen:
            V.append((s[0], min(s[1], s[3]), max(s[1], s[3])))
        if abs(s[1] - s[3]) < 0.05 and abs(s[0] - s[2]) > minlen:
            H.append((s[1], min(s[0], s[2]), max(s[0], s[2])))
    return V, H


rv, rh = axis_lines(R, 30)
RAW0 = raw
best_all = None
for rot in range(8):
    def rotp(x, y, r=rot):
        if r >= 4:
            y = -y
        for _ in range(r % 4):
            x, y = -y, x
        return x, y
    raw = [(*rotp(s[0], s[1]), *rotp(s[2], s[3]), s[4]) for s in RAW0]
    pv, ph = axis_lines(raw, 30)
    # coarse translation: vote on (dx, dy) from pairs of long lines, weighted by length
    vx, vy = collections.Counter(), collections.Counter()
    for x, a, b in pv:
        for X, A, B in rv:
            vx[round(X - x)] += min(b - a, B - A)
    for y, a, b in ph:
        for Y, A, B in rh:
            vy[round(Y - y)] += min(b - a, B - A)
    cands = [(dx, dy) for dx, _ in vx.most_common(15) for dy, _ in vy.most_common(15)]


    def score(dx, dy):
        s = 0.0
        for x, a, b in pv:
            for X, A, B in rv:
                if abs(X - (x + dx)) < 1.0:
                    s += max(0.0, min(b + dy, B) - max(a + dy, A))
        for y, a, b in ph:
            for Y, A, B in rh:
                if abs(Y - (y + dy)) < 1.0:
                    s += max(0.0, min(b + dx, B) - max(a + dx, A))
        return s


    best = max(cands, key=lambda c: score(*c))
    # refine to 0.1 in
    bx, by = best
    fine = max(((bx + i / 10, by + j / 10) for i in range(-10, 11) for j in range(-10, 11)), key=lambda c: score(*c))
    dx, dy = fine
    print("translation dx %.1f dy %.1f  score %.0f" % (dx, dy, score(dx, dy)))
    if best_all is None or score(dx, dy) > best_all[0]:
        best_all = (score(dx, dy), rot, dx, dy, raw)
sc, rot, dx, dy, raw = best_all
print("chosen variant (>=4 mirrored)", rot, "rot", (rot % 4) * 90, "dx", dx, "dy", dy)
segs = [[round(s[0] + dx, 2), round(s[1] + dy, 2), round(s[2] + dx, 2), round(s[3] + dy, 2), s[4]] for s in raw]
segs = [s for s in segs if -150 < min(s[0], s[2]) and max(s[0], s[2]) < 950 and -150 < min(s[1], s[3]) and max(s[1], s[3]) < 1100]
json.dump(segs, open(os.path.join(out, "roofplan_segs.json"), "w"))
x0, x1, y0, y1, S = -120, 900, -80, 1050, 2.0
img = Image.new("RGB", (int((x1 - x0) * S), int((y1 - y0) * S)), "white")
d = ImageDraw.Draw(img)
for g in range(-96, 1050, 48):
    d.line([(0, (y1 - g) * S), (img.width, (y1 - g) * S)], fill=(232, 232, 232)); d.text((2, (y1 - g) * S), str(g), fill=(140, 140, 140))
    d.line([((g - x0) * S, 0), ((g - x0) * S, img.height)], fill=(232, 232, 232)); d.text(((g - x0) * S + 2, 2), str(g), fill=(140, 140, 140))
for s in R:
    d.line([((s[0] - x0) * S, (y1 - s[1]) * S), ((s[2] - x0) * S, (y1 - s[3]) * S)], fill=(255, 140, 0))
for s in segs:
    d.line([((s[0] - x0) * S, (y1 - s[1]) * S), ((s[2] - x0) * S, (y1 - s[3]) * S)], fill=(0, 0, 0))
img.save(os.path.join(out, "roofplan_overlay.png"))
