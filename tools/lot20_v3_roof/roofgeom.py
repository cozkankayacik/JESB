# Lot 20 roof from the DWG roof plan: upper envelope of hip "bodies" -> planar cells (JSON for SketchUp).
import sys, os, json, math
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
from PIL import Image, ImageDraw
import ezdxf

W = os.path.dirname(os.path.abspath(__file__))
TX, TY = 17273.64, 4111.42          # DWG roof plan -> model
EPS = 1e-6

def plane(px, py, nx, ny, pitch):
    """Roof plane rising from the eave line through (px,py) with inward unit normal (nx,ny)."""
    l = math.hypot(nx, ny); nx, ny = nx / l, ny / l
    return {'a': pitch * nx, 'b': pitch * ny, 'c': -pitch * (nx * px + ny * py), 'n': (nx, ny), 'p0': (px, py)}
def half(px, py, nx, ny):
    l = math.hypot(nx, ny); nx, ny = nx / l, ny / l
    return (nx, ny, -(nx * px + ny * py))          # nx*x+ny*y+c >= 0 is inside
def Wp(x, p=0.5): return plane(x, 0, 1, 0, p)     # eave on the west, rises to the east
def Ep(x, p=0.5): return plane(x, 0, -1, 0, p)
def Sp(y, p=0.5): return plane(0, y, 0, 1, p)
def Np(y, p=0.5): return plane(0, y, 0, -1, p)
def z(pl, x, y): return pl['a'] * x + pl['b'] * y + pl['c']

def body(name, planes, clips=()):
    hs = [half(pl['p0'][0], pl['p0'][1], pl['n'][0], pl['n'][1]) for pl in planes] + list(clips)
    return {'name': name, 'planes': planes, 'hs': hs}

# ---- main level (eave top 264.6, fascia bottom 256.6), all 6:12 ----
MAIN = [
    body('M2', [Wp(-4784.84), Ep(-4210.84), Sp(-317.42), Np(150.58)]),
    body('M1', [Ep(-4054.84), Sp(-317.42), Np(138.58)], [half(-4445, 0, 1, 0)]),
    body('NW', [Wp(-4784.84), Ep(-4431.84), Np(162.58)], [half(0, -40, 0, 1)]),
    body('LW', [Wp(-4952.84), Ep(-4591.34), Sp(-329.42), Np(-47.42)]),
    # saddle between the left wing and the main roof (DWG line 44-46): left-wing north plane against the main south plane
    body('X', [Np(-47.42), Sp(-317.42)], [half(-4760, 0, 1, 0), half(-4640, 0, -1, 0)]),
    body('F2', [Wp(-4485.34), Ep(-4205.84), Sp(-333.42)], [half(0, -170, 0, -1)]),
    body('F1', [Wp(-4485.34), Ep(-4305.34), Sp(-345.42)], [half(0, -230, 0, -1)]),
    body('RB', [Ep(-4040.84), Sp(-169.42), Np(-9.42)], [half(-4140, 0, 1, 0)]),
]
# ---- garage level (eave top 142.8, fascia bottom 134.8): sides 4:12, front 6:12 ----
P7 = (-4640.84, -452.58); P8 = (-4608.91, -333.42); P49 = (-4796.84, -333.42)
ux, uy = P8[0] - P7[0], P8[1] - P7[1]; ul = math.hypot(ux, uy); ux, uy = ux / ul, uy / ul
anx, any_ = -uy, ux                                  # inward normal of the angled eave (points west)
dA = (P49[0] - P7[0]) * anx + (P49[1] - P7[1]) * any_
PA = 52.0 / dA                                       # pitch that makes the angled plane meet the ridge end (roof plan line 7-49)
YN = -310.42                                         # brick face of the two-storey wall the garage roof dies into
GAR = [
    body('G1', [Wp(-4952.84, 1 / 3), Ep(-4640.84, 1 / 3), Sp(-713.42, 0.5)], [half(0, YN, 0, -1)]),
    body('G2', [Wp(-4952.84, 1 / 3), plane(P7[0], P7[1], anx, any_, PA)], [half(0, YN, 0, -1), half(0, P7[1], 0, 1)]),
    body('GF', [Wp(-4880.84, 1 / 3), Ep(-4712.84, 1 / 3), Sp(-725.42, 0.5)], [half(0, -650, 0, -1)]),
]

BIG = 3000.0
def clip(poly, h, keep_inside=True):
    a, b, c = h
    if not keep_inside: a, b, c = -a, -b, -c
    out = []
    n = len(poly)
    for i in range(n):
        p, q = poly[i], poly[(i + 1) % n]
        dp, dq = a * p[0] + b * p[1] + c, a * q[0] + b * q[1] + c
        if dp >= -1e-9: out.append(p)
        if (dp > 1e-9 and dq < -1e-9) or (dp < -1e-9 and dq > 1e-9):
            t = dp / (dp - dq)
            out.append((p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])))
    # drop duplicates
    res = []
    for p in out:
        if not res or math.hypot(p[0] - res[-1][0], p[1] - res[-1][1]) > 1e-7: res.append(p)
    if len(res) > 1 and math.hypot(res[0][0] - res[-1][0], res[0][1] - res[-1][1]) < 1e-7: res.pop()
    return res if len(res) >= 3 else []
def area(poly):
    return 0.5 * sum(poly[i][0] * poly[(i + 1) % len(poly)][1] - poly[(i + 1) % len(poly)][0] * poly[i][1] for i in range(len(poly)))
def centroid(poly):
    a = area(poly); cx = cy = 0
    for i in range(len(poly)):
        p, q = poly[i], poly[(i + 1) % len(poly)]
        w = p[0] * q[1] - q[0] * p[1]; cx += (p[0] + q[0]) * w; cy += (p[1] + q[1]) * w
    return cx / (6 * a), cy / (6 * a)
def inside(b, x, y): return all(h[0] * x + h[1] * y + h[2] >= -1e-7 for h in b['hs'])
def height(b, x, y): return min(z(pl, x, y) for pl in b['planes'])
def diffline(p, q):
    a, b_, c = p['a'] - q['a'], p['b'] - q['b'], p['c'] - q['c']
    l = math.hypot(a, b_)
    return None if l < 1e-9 else (a / l, b_ / l, c / l)

def envelope(bodies):
    cells = []
    for bi, b in enumerate(bodies):
        foot = [(-9000, -3000), (0, -3000), (0, 3000), (-9000, 3000)]
        for h in b['hs']: foot = clip(foot, h)
        for pi, pl in enumerate(b['planes']):
            reg = foot
            for qi, q in enumerate(b['planes']):
                if qi == pi or not reg: continue
                dl = diffline(q, pl)                 # keep where q - pl >= 0
                if dl is None: continue
                reg = clip(reg, dl)
            if not reg or abs(area(reg)) < 1e-4: continue
            cs = [reg]
            for ci, c in enumerate(bodies):
                if ci == bi: continue
                lines = list(c['hs']) + [d for d in (diffline(pl, q) for q in c['planes']) if d]
                for ln in lines:
                    nxt = []
                    for cell in cs:
                        for side in (True, False):
                            part = clip(cell, ln, side)
                            if part and abs(area(part)) > 1e-4: nxt.append(part)
                    cs = nxt
            for cell in cs:
                cx, cy = centroid(cell)
                zb = z(pl, cx, cy); ok = True
                for ci, c in enumerate(bodies):
                    if ci == bi or not inside(c, cx, cy): continue
                    zc = height(c, cx, cy)
                    if zc > zb + 1e-6 or (abs(zc - zb) <= 1e-6 and ci < bi): ok = False; break
                if ok: cells.append({'body': b['name'], 'plane': pi, 'poly': cell, 'pl': pl})
    return cells

def export(cells, zt):
    out = []
    allv = [p for c in cells for p in c['poly']]
    for c in cells:
        pl = c['pl']
        # insert vertices of neighbouring cells that fall on this cell's edges (no T-junctions)
        poly = []
        n = len(c['poly'])
        for i in range(n):
            p, q = c['poly'][i], c['poly'][(i + 1) % n]
            dx, dy = q[0] - p[0], q[1] - p[1]; L2 = dx * dx + dy * dy
            mids = {}
            for v in allv:
                t = ((v[0] - p[0]) * dx + (v[1] - p[1]) * dy) / L2
                if 1e-6 < t < 1 - 1e-6 and abs((v[0] - p[0]) * dy - (v[1] - p[1]) * dx) / math.sqrt(L2) < 1e-5:
                    mids[round(t, 7)] = (p[0] + t * dx, p[1] + t * dy)
            poly.append(p)
            poly.extend(mids[k] for k in sorted(mids))
        pts = [[round(x + TX, 4), round(y + TY, 4), round(zt + z(pl, x, y), 4)] for x, y in poly]
        nx, ny = pl['n']
        out.append({'key': '%s.%d' % (c['body'], c['plane']), 'pts': pts,
                    'u': [-ny, nx, 0], 'up': [nx, ny, math.hypot(pl['a'], pl['b'])]})
    return out

main_cells = envelope(MAIN)
gar_cells = envelope(GAR)
data = {'main': {'zt': 264.6, 'zb': 256.6, 'faces': export(main_cells, 264.6)},
        'garage': {'zt': 142.8, 'zb': 134.8, 'faces': export(gar_cells, 142.8)}}
json.dump(data, open(os.path.join(W, 'roof.json'), 'w'))

# ---- report + check picture against the DWG roof plan ----
def top(cells, zt):
    best = max(((zt + z(c['pl'], x, y), x, y, c['body']) for c in cells for x, y in c['poly']))
    return best
print('cells main %d garage %d  PA=%.4f (%.2f:12)' % (len(main_cells), len(gar_cells), PA, PA * 12))
print('main top', top(main_cells, 264.6)); print('garage top', top(gar_cells, 142.8))
for nm, b, zt in [(b['name'], b, 264.6) for b in MAIN] + [(b['name'], b, 142.8) for b in GAR]:
    cs = [c for c in (main_cells + gar_cells) if c['body'] == nm]
    if cs:
        t = max(zt + z(c['pl'], x, y) for c in cs for x, y in c['poly'])
        print('  %-3s visible cells %3d  highest point %.2f' % (nm, len(cs), t))

S = 3.4; X0, Y1 = -4975, 185
def P(p): return ((p[0] - X0) * S, (Y1 - p[1]) * S)
img = Image.new('RGB', (int(960 * S), int(930 * S)), 'white'); d = ImageDraw.Draw(img)
import colorsys
keys = sorted(set((c['body'], c['plane']) for c in main_cells + gar_cells))
col = {k: tuple(int(255 * v) for v in colorsys.hsv_to_rgb(i / len(keys) * 0.97, 0.28, 1.0)) for i, k in enumerate(keys)}
for c in main_cells + gar_cells:
    d.polygon([P(p) for p in c['poly']], fill=col[(c['body'], c['plane'])])
doc = ezdxf.readfile(os.path.join(W, 'lot20.dxf'))
for e in doc.modelspace():
    if e.dxf.layer == '4-ROOF' and e.dxftype() == 'LINE':
        d.line([P((e.dxf.start.x, e.dxf.start.y)), P((e.dxf.end.x, e.dxf.end.y))], fill=(0, 0, 0), width=2)
    elif e.dxf.layer == '4-ROOF' and e.dxftype() == 'LWPOLYLINE':
        pts = [P((p[0], p[1])) for p in e.get_points()]
        if e.closed: pts.append(pts[0])
        d.line(pts, fill=(0, 0, 0), width=2)
img.save(os.path.join(W, 'roof_check.png'))
