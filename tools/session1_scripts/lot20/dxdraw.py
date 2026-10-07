"""Plain rasteriser for DXF regions: lines, polylines, arcs, circles, block inserts. Hatches and text are skipped."""
import sys, math
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import ezdxf
from PIL import Image, ImageDraw

w = sys.argv[1]
doc = ezdxf.readfile(w + r"\lot20.dxf")
msp = doc.modelspace()
SKIP_LAYERS = {"1-HATCH", "2-HATCH", "3-HATCH", "4-HATCH", "A-Area", "Data", "DEFPOINTS"}

def segs(e, depth=0):
    t = e.dxftype()
    if e.dxf.layer in SKIP_LAYERS:
        return
    if t == "LINE":
        yield (e.dxf.start.x, e.dxf.start.y, e.dxf.end.x, e.dxf.end.y, e.dxf.layer, e.dxf.get("linetype", ""))
    elif t == "LWPOLYLINE":
        try:
            for v in e.virtual_entities():
                yield from segs(v, depth)
        except Exception:
            p = [(x, y) for x, y, *_ in e.get_points()]
            if e.closed: p.append(p[0])
            for a, b in zip(p, p[1:]):
                yield (a[0], a[1], b[0], b[1], e.dxf.layer, "")
    elif t in ("ARC", "CIRCLE"):
        c = e.dxf.center; r = e.dxf.radius
        a0, a1 = (0, 360) if t == "CIRCLE" else (e.dxf.start_angle, e.dxf.end_angle)
        if a1 <= a0: a1 += 360
        n = max(8, int((a1 - a0) / 10))
        pts = [(c.x + r * math.cos(math.radians(a0 + (a1 - a0) * i / n)), c.y + r * math.sin(math.radians(a0 + (a1 - a0) * i / n))) for i in range(n + 1)]
        for a, b in zip(pts, pts[1:]):
            yield (a[0], a[1], b[0], b[1], e.dxf.layer, "")
    elif t == "INSERT" and depth < 4:
        try:
            for v in e.virtual_entities():
                yield from segs(v, depth + 1)
        except Exception:
            pass

allsegs = [s for e in msp for s in segs(e)]
print("segments", len(allsegs))

def draw(name, x0, y0, x1, y1, px_per_in):
    W = int((x1 - x0) * px_per_in); H = int((y1 - y0) * px_per_in)
    im = Image.new("RGB", (W, H), "white"); d = ImageDraw.Draw(im)
    n = 0
    for ax, ay, bx, by, layer, lt in allsegs:
        if max(ax, bx) < x0 or min(ax, bx) > x1 or max(ay, by) < y0 or min(ay, by) > y1: continue
        hidden = "HIDDEN" in (lt or "").upper() or layer in ("1-FND", "2-FOOT")
        col = (150, 150, 150) if hidden else (0, 0, 0)
        d.line([((ax - x0) * px_per_in, (y1 - ay) * px_per_in), ((bx - x0) * px_per_in, (y1 - by) * px_per_in)], fill=col, width=1)
        n += 1
    im.save(w + "\\dwg_%s.jpg" % name, quality=90)
    print(name, W, H, n)

# locate the elevations: clusters of 1-WALL geometry along x
xs = sorted(set(round(min(a, c) / 20) * 20 for a, _, c, _, layer, _ in allsegs if layer in ("1-WALL", "1-WINDOW", "1-TRIM")))
groups = []
for x in xs:
    if groups and x - groups[-1][1] <= 60: groups[-1][1] = x
    else: groups.append([x, x])
print("elevation x-clusters:", groups)
for i, (a, b) in enumerate(groups):
    draw("elev%d" % i, a - 60, -2440, b + 80, -1860, 2.0)
draw("roof", -5000, -760, -4000, 200, 2.0)
draw("plan1", -4960, 480, -3690, 1450, 1.9)
draw("plan2", -3760, 480, -2840, 1450, 2.2)
draw("found", -6150, 480, -5230, 1450, 2.2)
