"""Overlay DWG elevation / roof-plan linework (red) on the SketchUp exports at the same scale, with a best-fit shift."""
import sys, math
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import numpy as np
import ezdxf
from PIL import Image, ImageDraw, ImageFilter

w = sys.argv[1]
doc = ezdxf.readfile(w + r"\lot20.dxf")
msp = doc.modelspace()
SKIP = {"1-HATCH", "2-HATCH", "3-HATCH", "4-HATCH", "A-Area", "Data", "DEFPOINTS", "1-FND", "A-Flor-Dims", "1-TITLE", "!ELEV-HTS"}

def segs(e, depth=0):
    t = e.dxftype()
    if e.dxf.layer in SKIP: return
    if t == "LINE":
        if "HIDDEN" in e.dxf.get("linetype", "").upper(): return
        yield (e.dxf.start.x, e.dxf.start.y, e.dxf.end.x, e.dxf.end.y)
    elif t == "LWPOLYLINE":
        p = [(x, y) for x, y, *_ in e.get_points()]
        if e.closed and p: p.append(p[0])
        for a, b in zip(p, p[1:]): yield (a[0], a[1], b[0], b[1])
    elif t == "INSERT" and depth < 4:
        try:
            for v in e.virtual_entities(): yield from segs(v, depth + 1)
        except Exception: pass

S = [s for e in msp for s in segs(e)]
BW, BH = 908.4, 1017.1
CX, CY, CZ = (12314.8 + 13223.2) / 2, (3330.2 + 4347.3) / 2, (-6.9 + 374.0) / 2
sc = 1500.0 / (max(BW, BH) * 0.80)

def region(x0, x1, y0=-2290, y1=-1860):
    return [s for s in S if x0 <= min(s[0], s[2]) and max(s[0], s[2]) <= x1 and y0 <= min(s[1], s[3]) and max(s[1], s[3]) <= y1]

def raster(lines, W, H, width=1):
    im = Image.new("L", (W, H), 0); d = ImageDraw.Draw(im)
    for l in lines: d.line(l, fill=255, width=width)
    return im

def fit_and_draw(name, skp_file, lines_px, W=2400, H=1500, search=80):
    base = Image.open(w + "\\" + skp_file).convert("RGB")
    g = np.asarray(base.convert("L").filter(ImageFilter.FIND_EDGES).filter(ImageFilter.GaussianBlur(2))).astype(np.float32)
    best = (-1, 0, 0)
    for dx in range(-search, search + 1, 2):
        for dy in range(-12, 13, 2):
            r = np.asarray(raster([(a + dx, b + dy, c + dx, d + dy) for a, b, c, d in lines_px], W, H)).astype(np.float32)
            sc_ = float((r * g).sum())
            if sc_ > best[0]: best = (sc_, dx, dy)
    _, dx, dy = best
    d = ImageDraw.Draw(base)
    for a, b, c, e in lines_px: d.line((a + dx, b + dy, c + dx, e + dy), fill=(230, 0, 0), width=2)
    base.save(w + "\\ov_%s.jpg" % name, quality=88)
    print(name, "shift px", dx, dy, "= inches", round(dx / sc, 1), round(dy / sc, 1), "lines", len(lines_px))

# elevations: DWG y -2280 is model z 0. flip = True when DWG x runs opposite to screen x.
def elev(name, skp_file, x0, x1, anchor_dwg, anchor_px):
    L = region(x0, x1)
    px = [((a - anchor_dwg) * sc + anchor_px, 750 - ((b + 2280) - CZ) * sc, (c - anchor_dwg) * sc + anchor_px, 750 - ((d + 2280) - CZ) * sc) for a, b, c, d in L]
    fit_and_draw(name, skp_file, px)

def mid(x0, x1):
    L = region(x0, x1, -2279, -1860)
    xs = [v for s in L for v in (s[0], s[2])]
    return (min(xs) + max(xs)) / 2

for name, f, x0, x1 in [("front", "s_front.jpg", -5020, -3960), ("left", "s_left.jpg", -6540, -5440), ("right", "s_right.jpg", -3560, -2460), ("rear", "s_rear.jpg", -2280, -1240)]:
    elev(name, f, x0, x1, mid(x0, x1), 1200)

# roof plan on the top view
st = 2000.0 / (max(BW, BH) * 1.15)
R = [s for s in S if -5000 <= min(s[0], s[2]) and max(s[0], s[2]) <= -4000 and -760 <= min(s[1], s[3]) and max(s[1], s[3]) <= 200]
xs = [v for s in R for v in (s[0], s[2])]; ys = [v for s in R for v in (s[1], s[3])]
mx, my = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
px = [((a - mx) * st + 1000, 1000 - (b - my) * st, (c - mx) * st + 1000, 1000 - (d - my) * st) for a, b, c, d in R]
sc = st
fit_and_draw("roof", "s_top.jpg", px, 2000, 2000, 120)
print("roof plan dwg extents", min(xs), max(xs), min(ys), max(ys))
