# JESB Lot 7 - roofs from the Rev 1 roof plan A-220 (vector lines, registered to the model: plan + (11, -14.5) in.)
# with heights from the Rev 1 elevations A-300 / A-310 (eave tops: main 277.9, garage upper 230.8, dormers 263.5,
# covered terrace 141.4; fascia 7.3 in.). Output roof7.json for build_v1.rb.
import os, sys, json, math
W = sys.argv[1]

def plane(px, py, nx, ny, pitch):
    l = math.hypot(nx, ny); nx, ny = nx / l, ny / l
    return {'a': pitch * nx, 'b': pitch * ny, 'c': -pitch * (nx * px + ny * py), 'n': (nx, ny), 'p0': (px, py)}
def half(px, py, nx, ny):
    l = math.hypot(nx, ny); nx, ny = nx / l, ny / l
    return (nx, ny, -(nx * px + ny * py))
def z(pl, x, y): return pl['a'] * x + pl['b'] * y + pl['c']
def body(name, planes, clips=()):
    return {'name': name, 'planes': planes, 'hs': [half(p['p0'][0], p['p0'][1], p['n'][0], p['n'][1]) for p in planes] + list(clips)}
Wp = lambda x, p: plane(x, 0, 1, 0, p)
Ep = lambda x, p: plane(x, 0, -1, 0, p)
Sp = lambda y, p: plane(0, y, 0, 1, p)
Np = lambda y, p: plane(0, y, 0, -1, p)
xmin = lambda x: half(x, 0, 1, 0)
xmax = lambda x: half(x, 0, -1, 0)
ymin = lambda y: half(0, y, 0, 1)
ymax = lambda y: half(0, y, 0, -1)

MAIN = [
    body('M', [Wp(1629.5, .75), Ep(2292.6, .75), Sp(3739.2, .5), Np(4246.5, .5)]),
    body('CG', [Wp(1629.5, .75), Ep(1877.1, .75)], [ymin(3710.2), ymax(4060)]),   # ridge dies into the main north slope at y 4060.9
    body('FG1', [Wp(1968.6, .75), Ep(2126.6, .75)], [ymin(3730.2), ymax(3950)]),
    body('FG2', [Wp(2135.0, .75), Ep(2236.1, .75)], [ymin(3735.2), ymax(3900)]),
]
GARAGE = [body('G', [Wp(1658.5, .75), Ep(1924.6, .75)], [ymin(3377.2), ymax(3780)])]
DORMER_W = [body('DW', [Wp(1646.5, .75), Sp(3410.1, .75), Np(3575.1, .75)], [xmax(1791.6)])]
DORMER_E = [body('DE', [Ep(1936.6, .75), Sp(3485.8, .75), Np(3650.8, .75)], [xmin(1791.6)])]
TERRACE = [body('T', [Ep(2436.6, .5), Sp(3891.9, .5), Np(4181.5, .5)], [xmin(2283.8)])]

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
        foot = [(0, 0), (6000, 0), (6000, 6000), (0, 6000)]
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
data = {}
for name, bodies, zt, zb, gables in (
        ('main', MAIN, 277.9, 270.6, [[3710.2, 223.5, 'siding'], [3730.2, 270.6, 'metal'], [3735.2, 270.6, 'metal']]),
        ('garage', GARAGE, 230.8, 223.5, [[3377.2, 223.5, 'siding']]),
        ('dormer_w', DORMER_W, 263.5, 256.2, []),
        ('dormer_e', DORMER_E, 263.5, 256.2, []),
        ('terrace', TERRACE, 141.4, 134.1, [])):
    cells = envelope(bodies)
    data[name] = {'zt': zt, 'zb': zb, 'gables': gables, 'faces': export(cells, zt)}
    top = max(zt + z(c['pl'], x, y) for c in cells for x, y in c['poly'])
    print('%-9s cells %3d top %.1f' % (name, len(cells), top))
json.dump(data, open(os.path.join(W, 'roof7.json'), 'w'))
