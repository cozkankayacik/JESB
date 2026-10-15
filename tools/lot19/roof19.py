# JESB Lot 19 - roof from the Revision 1 elevations (sheets A-300 / A-310), all 6:12, as the upper envelope of hip blocks.
# Coordinates are model inches. Block extents are read from the elevation outlines (see the v1 change log).
# Output roof19.json: {'main': {zt, zb, faces}, 'tower': {...}} for build_roof19.rb.
import os, sys, json, math

W = os.path.dirname(os.path.abspath(__file__)) if len(sys.argv) < 2 else sys.argv[1]
P = 0.5

def plane(px, py, nx, ny, pitch=P):
    l = math.hypot(nx, ny); nx, ny = nx / l, ny / l
    return {'a': pitch * nx, 'b': pitch * ny, 'c': -pitch * (nx * px + ny * py), 'n': (nx, ny), 'p0': (px, py)}
def half(px, py, nx, ny):
    l = math.hypot(nx, ny); nx, ny = nx / l, ny / l
    return (nx, ny, -(nx * px + ny * py))
def z(pl, x, y): return pl['a'] * x + pl['b'] * y + pl['c']
def hipblock(name, x0, x1, y0, y1):
    pls = [plane(x0, 0, 1, 0), plane(x1, 0, -1, 0), plane(0, y0, 0, 1), plane(0, y1, 0, -1)]
    return {'name': name, 'planes': pls, 'hs': [half(p['p0'][0], p['p0'][1], p['n'][0], p['n'][1]) for p in pls]}

MAIN = [
    hipblock('A', 1170.0, 1620.0, 1405.7, 1807.7),     # west part, ridge 1371..1419, rise 100.5
    hipblock('B', 1218.0, 1785.5, 1389.7, 1807.7),     # middle, ridge 1427..1576.5, rise 104.5
    hipblock('C', 1369.0, 1852.5, 1394.0, 1840.0),     # east / high, ridge 1592..1629.5, rise 111.5
    hipblock('D', 1643.7, 1853.7, 1600.0, 1959.0),     # north-east block (Br 2), ridge along y, rise 52.5
    hipblock('E', 1218.0, 1410.0, 1098.0, 1582.0),     # front-left two-storey bay, ridge along y, rise 48
    hipblock('F', 1180.0, 1382.0, 1154.0, 1318.0),     # west bump of that bay, ridge along x, rise 41
]
TOWER = [hipblock('T', 1504.5, 1688.5, 1388.5, 1643.5)]  # entry tower, eave 31 in. higher, ridge along y

def clip(poly, h, keep=True):
    a, b, c = h
    if not keep: a, b, c = -a, -b, -c
    out = []
    for i in range(len(poly)):
        p, q = poly[i], poly[(i + 1) % len(poly)]
        dp, dq = a * p[0] + b * p[1] + c, a * q[0] + b * q[1] + c
        if dp >= -1e-9: out.append(p)
        if (dp > 1e-9 and dq < -1e-9) or (dp < -1e-9 and dq > 1e-9):
            t = dp / (dp - dq); out.append((p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])))
    res = []
    for p in out:
        if not res or math.hypot(p[0] - res[-1][0], p[1] - res[-1][1]) > 1e-7: res.append(p)
    if len(res) > 1 and math.hypot(res[0][0] - res[-1][0], res[0][1] - res[-1][1]) < 1e-7: res.pop()
    return res if len(res) >= 3 else []
def area(p): return 0.5 * sum(p[i][0] * p[(i + 1) % len(p)][1] - p[(i + 1) % len(p)][0] * p[i][1] for i in range(len(p)))
def centroid(p):
    a = area(p); cx = cy = 0
    for i in range(len(p)):
        u, v = p[i], p[(i + 1) % len(p)]; w = u[0] * v[1] - v[0] * u[1]; cx += (u[0] + v[0]) * w; cy += (u[1] + v[1]) * w
    return cx / (6 * a), cy / (6 * a)
def inside(b, x, y): return all(h[0] * x + h[1] * y + h[2] >= -1e-7 for h in b['hs'])
def height(b, x, y): return min(z(pl, x, y) for pl in b['planes'])
def diffline(p, q):
    a, b, c = p['a'] - q['a'], p['b'] - q['b'], p['c'] - q['c']; l = math.hypot(a, b)
    return None if l < 1e-9 else (a / l, b / l, c / l)

def envelope(bodies):
    cells = []
    for bi, b in enumerate(bodies):
        foot = [(0, 0), (4000, 0), (4000, 4000), (0, 4000)]
        for h in b['hs']: foot = clip(foot, h)
        for pi, pl in enumerate(b['planes']):
            reg = foot
            for qi, q in enumerate(b['planes']):
                if qi == pi or not reg: continue
                dl = diffline(q, pl)
                if dl: reg = clip(reg, dl)
            if not reg or abs(area(reg)) < 1e-4: continue
            cs = [reg]
            for ci, c in enumerate(bodies):
                if ci == bi: continue
                for ln in list(c['hs']) + [d for d in (diffline(pl, q) for q in c['planes']) if d]:
                    nxt = []
                    for cell in cs:
                        for side in (True, False):
                            part = clip(cell, ln, side)
                            if part and abs(area(part)) > 1e-4: nxt.append(part)
                    cs = nxt
            for cell in cs:
                cx, cy = centroid(cell); zb = z(pl, cx, cy); ok = True
                for ci, c in enumerate(bodies):
                    if ci == bi or not inside(c, cx, cy): continue
                    zc = height(c, cx, cy)
                    if zc > zb + 1e-6 or (abs(zc - zb) <= 1e-6 and ci < bi): ok = False; break
                if ok: cells.append({'body': b['name'], 'plane': pi, 'poly': cell, 'pl': pl})
    return cells

def export(cells, zt):
    out = []; allv = [p for c in cells for p in c['poly']]
    for c in cells:
        pl = c['pl']; poly = []; n = len(c['poly'])
        for i in range(n):
            p, q = c['poly'][i], c['poly'][(i + 1) % n]
            dx, dy = q[0] - p[0], q[1] - p[1]; L2 = dx * dx + dy * dy; mids = {}
            for v in allv:
                t = ((v[0] - p[0]) * dx + (v[1] - p[1]) * dy) / L2
                if 1e-6 < t < 1 - 1e-6 and abs((v[0] - p[0]) * dy - (v[1] - p[1]) * dx) / math.sqrt(L2) < 1e-5:
                    mids[round(t, 7)] = (p[0] + t * dx, p[1] + t * dy)
            poly.append(p); poly.extend(mids[k] for k in sorted(mids))
        out.append({'key': '%s.%d' % (c['body'], c['plane']), 'pts': [[round(x, 4), round(y, 4), round(zt + z(pl, x, y), 4)] for x, y in poly]})
    return out

mc = envelope(MAIN); tc = envelope(TOWER)
data = {'main': {'zt': 279.7, 'zb': 272.5, 'faces': export(mc, 279.7)}, 'tower': {'zt': 310.2, 'zb': 299.0, 'faces': export(tc, 310.2)}}
json.dump(data, open(os.path.join(W, 'roof19.json'), 'w'))
for name, cells, zt in (('main', mc, 279.7), ('tower', tc, 310.2)):
    print(name, 'cells', len(cells))
    for b in sorted(set(c['body'] for c in cells)):
        cs = [c for c in cells if c['body'] == b]
        print('  %s cells %3d top %.1f' % (b, len(cs), max(zt + z(c['pl'], x, y) for c in cs for x, y in c['poly'])))
