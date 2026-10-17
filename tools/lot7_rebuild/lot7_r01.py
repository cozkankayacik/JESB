"""JESB Lot 7 - exterior model R01: geometry generator.

Builds the full exterior description of the house from the architect's drawings and writes r01_spec.json, which
build_r01.rb turns into a SketchUp model. Plan coordinates are DWG plan inches (xflr0/1/2), z = 0 at the top of the
main floor (839.20'). Sources and decisions are listed in 00_Project_Admin/JESB_Lot7_Model_R01_Change_Log.md.

Usage: python -I lot7_r01.py <work_dir>   (work_dir holds openings.json, grade.json, xflr0_plan_segs.json)
"""
import sys, os, json, math
sys.path.insert(0, os.path.dirname(__file__))
from geometry import *

W = sys.argv[1]
P9, P6, P_FRONT_PROJ, P_TERR = 0.75, None, 0.55, 0.44
FASCIA = 7.25
MAIN_EAVE = 248.87            # top of main fascia (xelev)
MAIN_RIDGE = 381.97           # xelev
WING_EAVE = 201.12
DORMER_EAVE = 234.5
GARAGE_EAVE = 105.62
TERRACE_EAVE = 112.37          # xelev: fascia 105.12..112.37, beam 97.87..105.12; slope ~5:12 on the elevations
GBR_EAVE = 127.1              # from the roof/wall line 159.37 on the north elevation at 9:12
GARAGE_SHIFT = 9.36           # new xflr1 garage front against the roof outlines drawn in xflr2 (old issue)

# main front/rear pitch from the dimensioned ridge (25'-8") and the elevation ridge height
P6 = (MAIN_RIDGE - MAIN_EAVE) / ((924.32 - 417.36) / 2.0)


# ---------------------------------------------------------------------------------------------------- roof bodies
def plane(edge, pos, pitch, ze):
    """Roof plane rising inward from an eave line. edge: 'W' (x=pos, rises +x), 'E', 'S' (y=pos, rises +y), 'N'."""
    nx, ny = {"W": (1, 0), "E": (-1, 0), "S": (0, 1), "N": (0, -1)}[edge]
    px, py = (pos, 0) if edge in "WE" else (0, pos)
    return {"a": pitch * nx, "b": pitch * ny, "c": ze - pitch * (nx * px + ny * py), "n": (nx, ny), "p0": (px, py)}


def half(px, py, nx, ny):
    return (nx, ny, -(nx * px + ny * py))


def body(name, planes, box, mat="shingle", metal=()):
    x0, x1, y0, y1 = box
    hs = [half(x0, 0, 1, 0), half(x1, 0, -1, 0), half(0, y0, 0, 1), half(0, y1, 0, -1)]
    return {"name": name, "planes": planes, "hs": hs, "box": box, "mat": mat, "metal": list(metal)}


def zpl(pl, x, y):
    return pl["a"] * x + pl["b"] * y + pl["c"]


def inside(b, x, y):
    return all(h[0] * x + h[1] * y + h[2] >= -1e-7 for h in b["hs"])


def height(b, x, y):
    return min(zpl(pl, x, y) for pl in b["planes"])


ROOF_UPPER = [
    body("A1 main", [plane("W", -12, P9, MAIN_EAVE), plane("E", 650.96, P9, MAIN_EAVE),
                     plane("S", 417.36, P6, MAIN_EAVE), plane("N", 924.32, P6, MAIN_EAVE)], (-12, 650.96, 417.36, 924.32)),
    # north-front corner: the main west eave runs on to y 388 (xelev north: fascia 387.96..924.36); a small hip whose
    # east slope dies into the main front plane, its south/east eaves overhang the lower wing roof
    # R06 per A-220: front eave y 388 at 6:12, east slope 9:12 with its eave at x 232. This reproduces the drawn hip
    # from the corner (-12,388), the short ridge at x 110 (y 571..592), the hip against the main front plane
    # (112,589)..(223,430), and the two wing valleys meeting at the wing ridge (y ~492).
    body("A2 main north-front", [plane("W", -12, P9, MAIN_EAVE), plane("S", 388.0, 0.5, MAIN_EAVE),
                                 plane("E", 232.0, P9, MAIN_EAVE), plane("N", 924.32, P6, MAIN_EAVE)], (-12, 232.0, 388.0, 924.32)),
    body("FP1 portico", [plane("S", 408.3, P_FRONT_PROJ, MAIN_EAVE), plane("W", 323.0, P9, MAIN_EAVE),
                         plane("E", 479.0, P9, MAIN_EAVE)], (323.0, 479.0, 408.3, 700.0), metal=[0]),
    body("FP2 front bay", [plane("S", 413.3, P_FRONT_PROJ, MAIN_EAVE), plane("W", 489.0, P9, MAIN_EAVE),
                           plane("E", 585.0, P9, MAIN_EAVE)], (489.0, 585.0, 413.3, 700.0), metal=[0]),
    # gablet on the south hip (xelev south/front): gable face in the south wall plane x 637.6, base on the hip,
    # 6:12, ridge 313.2 dying into the hip at x 565
    body("GB gablet south", [plane("S", 605.9, 0.5, 258.9), plane("N", 823.3, 0.5, 258.9)], (480.0, 637.6, 605.9, 823.3)),
    body("W wing", [plane("W", 17.0, P9, WING_EAVE), plane("E", 282.96, P9, WING_EAVE)], (17.0, 282.96, 54.96, 760.0)),
    body("DL dormer west", [plane("W", 4.9, P9, DORMER_EAVE), plane("S", 89.3, P9, DORMER_EAVE),
                            plane("N", 253.0, P9, DORMER_EAVE)], (4.9, 150.0, 89.3, 253.0), metal=[0, 1, 2]),
    body("DR dormer east", [plane("E", 294.0, P9, DORMER_EAVE), plane("S", 164.2, P9, DORMER_EAVE),
                            plane("N", 329.6, P9, DORMER_EAVE)], (150.0, 294.0, 164.2, 329.6), metal=[0, 1, 2]),
]
GF = -19.0 + GARAGE_SHIFT         # garage roof front (west half) after the garage front moved back
# Garage roofs per the xelev front elevation (R02):
#  G  = main garage gable, eaves x -7 / 288 (apex x 140.5 at 216.2 as drawn), gable face in the plane of the right
#       front wall y 25.36, 6" rake overhang;
#  LG = lower front gable over the 11" bump of the left garage front (x 0..137.68, face y 14.32): eaves x -7 / 149.7,
#       apex x 71.35 at 164.4, 9:12, 6" rake overhang; its ridge dies into the G gable face.
ROOF_GARAGE = [
    body("G garage gable", [plane("W", -7.0, P9, GARAGE_EAVE), plane("E", 288.0, P9, GARAGE_EAVE)], (-7.0, 288.0, 19.36, 434.32)),
    body("LG lower front gable", [plane("W", -7.0, P9, GARAGE_EAVE), plane("E", 149.7, P9, GARAGE_EAVE)], (-7.0, 149.7, 8.32, 60.0)),
]
ROOF_GBR = [body("B guest bedroom bay", [plane("W", -43.04, P9, GBR_EAVE), plane("S", 382.96, P9, GBR_EAVE),
                                         plane("N", 602.08, P9, GBR_EAVE)], (-43.04, 0.0, 382.96, 602.08), metal=[0, 1, 2])]
ROOF_TERRACE = [body("T covered terrace", [plane("E", 795.0, P_TERR, TERRACE_EAVE), plane("S", 569.7, P_TERR, TERRACE_EAVE),
                                           plane("N", 859.3, P_TERR, TERRACE_EAVE)], (638.96, 795.0, 569.7, 859.3))]
ROOF_GROUPS = [("Roof - Main and wing", ROOF_UPPER), ("Roof - Garage", ROOF_GARAGE), ("Roof - Guest bedroom bay", ROOF_GBR),
               ("Roof - Covered terrace", ROOF_TERRACE)]
ALL_BODIES = [b for _, g in ROOF_GROUPS for b in g]


# ---- envelope (upper surface of a set of convex roof bodies), as in the Lot 19 / Lot 20 roofs
def clip(poly, h, keep=True):
    a, b, c = h
    if not keep:
        a, b, c = -a, -b, -c
    out = []
    for i in range(len(poly)):
        p, q = poly[i], poly[(i + 1) % len(poly)]
        dp, dq = a * p[0] + b * p[1] + c, a * q[0] + b * q[1] + c
        if dp >= -1e-9:
            out.append(p)
        if (dp > 1e-9 and dq < -1e-9) or (dp < -1e-9 and dq > 1e-9):
            t = dp / (dp - dq)
            out.append((p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])))
    res = []
    for p in out:
        if not res or math.hypot(p[0] - res[-1][0], p[1] - res[-1][1]) > 1e-7:
            res.append(p)
    if len(res) > 1 and math.hypot(res[0][0] - res[-1][0], res[0][1] - res[-1][1]) < 1e-7:
        res.pop()
    return res if len(res) >= 3 else []


def area(p):
    return 0.5 * sum(p[i][0] * p[(i + 1) % len(p)][1] - p[(i + 1) % len(p)][0] * p[i][1] for i in range(len(p)))


def centroid(p):
    a = area(p); cx = cy = 0
    for i in range(len(p)):
        u, v = p[i], p[(i + 1) % len(p)]
        w = u[0] * v[1] - v[0] * u[1]; cx += (u[0] + v[0]) * w; cy += (u[1] + v[1]) * w
    return cx / (6 * a), cy / (6 * a)


def diffline(p, q):
    a, b, c = p["a"] - q["a"], p["b"] - q["b"], p["c"] - q["c"]
    l = math.hypot(a, b)
    return None if l < 1e-9 else (a / l, b / l, c / l)


def envelope(bodies):
    cells = []
    for bi, b in enumerate(bodies):
        foot = [(-3000, -3000), (3000, -3000), (3000, 3000), (-3000, 3000)]
        for h in b["hs"]:
            foot = clip(foot, h)
        for pi, pl in enumerate(b["planes"]):
            reg = foot
            for qi, q in enumerate(b["planes"]):
                if qi == pi or not reg:
                    continue
                dl = diffline(q, pl)
                if dl:
                    reg = clip(reg, dl)
            if not reg or abs(area(reg)) < 1e-3:
                continue
            cs = [reg]
            for ci, c in enumerate(bodies):
                if ci == bi:
                    continue
                for ln in list(c["hs"]) + [d for d in (diffline(pl, q) for q in c["planes"]) if d]:
                    nxt = []
                    for cell in cs:
                        for side in (True, False):
                            part = clip(cell, ln, side)
                            if part and abs(area(part)) > 1e-3:
                                nxt.append(part)
                    cs = nxt
            for cell in cs:
                cx, cy = centroid(cell)
                zb = zpl(pl, cx, cy); ok = True
                for ci, c in enumerate(bodies):
                    if ci == bi or not inside(c, cx, cy):
                        continue
                    zc = height(c, cx, cy)
                    if zc > zb + 1e-6 or (abs(zc - zb) <= 1e-6 and ci < bi):
                        ok = False; break
                if ok:
                    cells.append({"body": b["name"], "plane": pi, "poly": cell, "pl": pl,
                                  "mat": "metal" if pi in b["metal"] else b["mat"]})
    return cells


def with_tjunctions(cells):
    """Insert every cell vertex that lies on another cell's edge (keeps the mesh watertight in SketchUp)."""
    allv = [p for c in cells for p in c["poly"]]
    out = []
    for c in cells:
        poly = []
        n = len(c["poly"])
        for i in range(n):
            p, q = c["poly"][i], c["poly"][(i + 1) % n]
            dx, dy = q[0] - p[0], q[1] - p[1]; L2 = dx * dx + dy * dy; mids = {}
            for v in allv:
                t = ((v[0] - p[0]) * dx + (v[1] - p[1]) * dy) / L2
                if 1e-6 < t < 1 - 1e-6 and abs((v[0] - p[0]) * dy - (v[1] - p[1]) * dx) / math.sqrt(L2) < 1e-5:
                    mids[round(t, 7)] = (p[0] + t * dx, p[1] + t * dy)
            poly.append(p); poly.extend(mids[k] for k in sorted(mids))
        out.append({"mat": c["mat"], "key": "%s.%d" % (c["body"], c["plane"]),
                    "pts": [[round(x, 4), round(y, 4), round(zpl(c["pl"], x, y), 4)] for x, y in poly]})
    return out


def free_edges(faces_, bodies):
    """Edges used by exactly one surface cell and lying on the outline of the group's footprint (eaves, rakes,
    edges against walls). Internal seams that only look unmatched because of rounding are dropped."""
    cnt = {}
    for f in faces_:
        pts = f["pts"]
        for i in range(len(pts)):
            a, b = tuple(round(v, 3) for v in pts[i]), tuple(round(v, 3) for v in pts[(i + 1) % len(pts)])
            k = (min(a, b), max(a, b))
            cnt[k] = cnt.get(k, 0) + 1
    out = []
    for (a, b), n in cnt.items():
        if n != 1:
            continue
        mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy)
        if L < 1e-6:
            continue
        nx, ny = -dy / L * 0.5, dx / L * 0.5
        s1 = any(inside(bd, mx + nx, my + ny) for bd in bodies)
        s2 = any(inside(bd, mx - nx, my - ny) for bd in bodies)
        if s1 and s2:
            continue
        out.append([list(a), list(b)])
    return out


roofs = []
for gname, bodies in ROOF_GROUPS:
    cells = envelope(bodies)
    faces_ = with_tjunctions(cells)
    top = max(p[2] for f in faces_ for p in f["pts"])
    fe = free_edges(faces_, bodies)
    roofs.append({"name": gname, "faces": faces_, "thickness": FASCIA, "free_edges": fe})
    print("%-26s %3d cells, top %.2f, free edges %d" % (gname, len(cells), top, len(fe)))


def roof_surfaces_at(x, y):
    """Visible roof height of every roof group covering (x, y): the envelope (max) of its bodies."""
    out = []
    for _, bodies in ROOF_GROUPS:
        hs = [height(b, x, y) for b in bodies if inside(b, x, y)]
        if hs:
            out.append(max(hs))
    return out


# ------------------------------------------------------------------------------------------------------------ walls
def zone_material(face_p, face_q, z_mid, floor):
    (x0, y0), (x1, y1) = face_p, face_q
    xm, ym = (x0 + x1) / 2, (y0 + y1) / 2
    in_wing = 10 <= xm <= 290 and 50 <= ym <= 434 and floor == "L2"
    if in_wing:
        if (abs(xm - 16.9) < 0.1 or abs(xm - 282.0) < 0.1) or (abs(ym - 101.3) < 0.1 or abs(ym - 241.0) < 0.1 or abs(ym - 176.2) < 0.1 or abs(ym - 317.6) < 0.1):
            return "panel"                     # bay dormer faces: white decorative panel (ACC "siding dec")
        return "siding"
    return "brick"


def subtract(iv, cuts):
    res = [iv]
    for a, b in cuts:
        nxt = []
        for p, q in res:
            if b <= p or a >= q:
                nxt.append((p, q))
            else:
                if a > p: nxt.append((p, a))
                if b < q: nxt.append((b, q))
        res = nxt
    return [r for r in res if r[1] - r[0] > 0.5]


def faces_of(poly, floor):
    out = []
    for p, q, n, view in faces(poly):
        out.append({"p": p, "q": q, "n": n, "view": view, "floor": floor})
    return out


l1f = faces_of(L1_OUTLINE, "L1")
l2f = faces_of(L2_OUTLINE, "L2")
walls = []


def axis_of(f):
    return "x" if abs(f["p"][1] - f["q"][1]) < 1e-6 else "y"      # 'x': wall runs along x (constant y)


def add_wall(f, a, b, zb, floor, thick, margin=24.0):
    ax = axis_of(f)
    c = f["p"][1] if ax == "x" else f["p"][0]
    # top profile: sample the lowest roof surface clearly above the wall bottom, minus the roof thickness
    us = sorted(set([a, b] + [a + i * 2.0 for i in range(1, int((b - a) / 2.0))]))
    prof = []
    for u in us:
        x, y = (u, c) if ax == "x" else (c, u)
        # only roofs covering the interior side of the wall count (a lower roof dying into the wall from outside
        # does not stop it); first-floor walls stop at the lowest such roof, upper walls run to the highest
        cand = [h - FASCIA for h in roof_surfaces_at(x - f["n"][0] * 0.3, y - f["n"][1] * 0.3) if h - FASCIA > zb + margin]
        pick = (min if floor == "L1" else max)
        prof.append((u, round(pick(cand), 3) if cand else None))
    if any(t is None for _, t in prof):
        missing = [round(u, 1) for u, t in prof if t is None]
        print("  !! no roof above wall %s %s..%s at u=%s" % (f["view"], a, b, missing[:5]))
        prof = [(u, t if t is not None else 241.62) for u, t in prof]
    # drop collinear profile points
    simp = [prof[0]]
    for i in range(1, len(prof) - 1):
        (u0, t0), (u1, t1), (u2, t2) = simp[-1], prof[i], prof[i + 1]
        if abs((t1 - t0) * (u2 - u0) - (t2 - t0) * (u1 - u0)) > 1e-3 * max(1.0, (u2 - u0)):
            simp.append(prof[i])
    simp.append(prof[-1])
    zmid = (zb + max(t for _, t in simp)) / 2
    tmin, tmax = min(t for _, t in simp), max(t for _, t in simp)
    um = (a + b) / 2
    mx, my = (um, c) if ax == "x" else (c, um)
    under_garage = any(inside(bd, mx - f["n"][0] * 0.3, my - f["n"][1] * 0.3) for bd in ROOF_GARAGE)
    if floor == "L1" and under_garage and tmax > GARAGE_EAVE + 5:
        # gable end of the garage: brick up to the eave line, siding in the gable (xelev front)
        tmin = GARAGE_EAVE - FASCIA
        walls.append({"axis": ax, "c": c, "n": f["n"], "a": a, "b": b, "zb": zb, "top": [(a, tmin), (b, tmin)], "floor": floor,
                      "view": f["view"], "thick": thick, "mat": "brick", "openings": []})
        simp = [(u, max(t, tmin)) for u, t in simp]
        gable = [(u, t) for u, t in simp]
        walls.append({"axis": ax, "c": c, "n": f["n"], "a": a, "b": b, "zb": tmin, "top": gable, "floor": floor,
                      "view": f["view"], "thick": thick, "mat": "siding", "openings": []})
        return
    walls.append({"axis": ax, "c": c, "n": f["n"], "a": a, "b": b, "zb": zb, "top": simp, "floor": floor,
                  "view": f["view"], "thick": thick, "mat": zone_material(f["p"], f["q"], zmid, floor), "openings": []})


def wall_bottom(f, a, b):
    # finished grade or below: walls go down to 6 in. under the lowest grade so the terrain closes on them
    return -84.0


for f in l1f:
    ax = axis_of(f)
    lo, hi = sorted((f["p"][0], f["q"][0])) if ax == "x" else sorted((f["p"][1], f["q"][1]))
    add_wall(f, lo, hi, wall_bottom(f, lo, hi), "L1", 10.5)
for f in l2f:
    ax = axis_of(f)
    lo, hi = sorted((f["p"][0], f["q"][0])) if ax == "x" else sorted((f["p"][1], f["q"][1]))
    c = f["p"][1] if ax == "x" else f["p"][0]
    cuts = []
    for g in l1f:
        if axis_of(g) == ax and abs((g["p"][1] if ax == "x" else g["p"][0]) - c) < 0.05 and g["n"] == f["n"]:
            ga, gb = sorted((g["p"][0], g["q"][0])) if ax == "x" else sorted((g["p"][1], g["q"][1]))
            cuts.append((ga, gb))
    for a, b in subtract((lo, hi), cuts):
        add_wall(f, a, b, 96.0, "L2", 6.0)

# garage front (R02, xelev front): the bump face y 14.32 is brick only below the water table, white panel above
# (panels flank the window); the main garage gable face continues above the lower gable in the plane y 25.36
for w in list(walls):
    if w["axis"] == "x" and abs(w["c"] - 14.32) < 0.05:
        if w["mat"] == "brick" and w["zb"] < 0:
            walls.append(dict(w, zb=16.7, mat="panel", openings=list(w["openings"])))
            w["top"] = [(w["a"], 16.7), (w["b"], 16.7)]
            w["openings"] = []
        else:
            w["mat"] = "deco"                     # lower gable infill: textured panel (GENERAL_TEXTURE)
    if w["axis"] == "y" and abs(w["c"] - 137.68) < 0.05 and w["zb"] > 50:
        w["mat"] = "panel"
        _t = GARAGE_EAVE + P9 * (149.7 - 137.68) - FASCIA     # side of the bump: up to its own roof only
        w["top"] = [(w["a"], round(_t, 2)), (w["b"], round(_t, 2))]
_gf = {"p": (0.0, 25.36), "q": (137.68, 25.36), "n": (0.0, -1.0), "view": "front", "floor": "L2"}
add_wall(_gf, 0.0, 137.68, GARAGE_EAVE - FASCIA, "L2", 6.0, margin=0.05)
walls[-1]["mat"] = "siding"

# gablet gable infill (siding) in the plane x 637.6: from the hip surface up to the gablet roof underside
_hip = 248.87 + P9 * (650.96 - 637.6)
_ya = 605.9 + (_hip + FASCIA - 258.9) / 0.5
_yb = 823.3 - (_hip + FASCIA - 258.9) / 0.5
walls.append({"axis": "y", "c": 637.6, "n": [1, 0], "a": round(_ya, 2), "b": round(_yb, 2), "zb": round(_hip, 2),
              "top": [(round(_ya, 2), round(_hip, 2)), (714.6, round(258.9 + 0.5 * 108.7 - FASCIA, 2)), (round(_yb, 2), round(_hip, 2))],
              "floor": "L2", "view": "south", "thick": 3.0, "mat": "siding", "openings": []})

# ------------------------------------------------------------------------------------------------------- openings
OPEN = json.load(open(os.path.join(W, "openings.json")))
fixes = []
op_list = []
for o in OPEN:
    if "z0" not in o:
        if o["floor"] == "L2" and o["view"] == "front" and abs(o["c"] - 62.96) < 0.1:
            o["z0"], o["z1"] = 226.0, 258.0          # wing gable window (xelev front, 24x32)
            fixes.append("wing gable window: z from xelev (horizontal from plan)")
        else:
            continue
    op_list.append(o)
# entry door with two side lights and transom replaces the two side-light spans found on the porch wall
op_list = [o for o in op_list if not (o["floor"] == "L1" and o["view"] == "front" and abs(o["c"] - 480.96) < 0.1)]
op_list.append({"floor": "L1", "view": "front", "c": 480.96, "a": 368.8, "b": 442.8, "z0": 0.0, "z1": 107.7, "kind": "entry",
                "n": [0, -1]})
# portico upper window (plan 60 in wide; xelev draws a pair 86 in wide - plan followed)
for o in op_list:
    if o["floor"] == "L2" and o["view"] == "front" and abs(o["c"] - 480.96) < 0.1:
        o["z0"], o["z1"] = 156.6, 228.6
# stair window on the front (R05): xelev draws two stacked units in the second-floor opening x 293.2..329.2 -
# lower 116.4..156.6 and upper 156.6..228.6, split by a 2 in frame transom; each unit has its own cross grid
for o in op_list:
    if o["floor"] == "L2" and o["view"] == "front" and abs(o["c"] - 434.32) < 0.1 and abs(o["a"] - 293.2) < 0.5:
        o["rows"] = [156.6]
# covered terrace sliding door 6080 (plan), full height
op_list.append({"floor": "L1", "view": "south", "c": 638.96, "a": 678.2, "b": 750.2, "z0": 0.0, "z1": 96.0, "kind": "slider",
                "n": [1, 0]})
# garage doors (plan positions, xelev heights: bottom = garage slab -38.1, 8 ft)
op_list.append({"floor": "L1", "view": "south", "c": 276.0, "a": 52.0, "b": 150.0, "z0": -38.1, "z1": 57.9, "kind": "garage8", "n": [1, 0]})
op_list.append({"floor": "L1", "view": "south", "c": 276.0, "a": 174.0, "b": 366.0, "z0": -38.1, "z1": 57.9, "kind": "garage16", "n": [1, 0]})
# basement egress windows (xelev north, 48x48 at z -80..-32; positions from xflr0 glazing, else xelev)
x0segs = json.load(open(os.path.join(W, "xflr0_plan_segs.json")))
bw = sorted({round(min(s[1], s[3]), 1) for s in x0segs if s[4] == "A-Glaz" and abs(s[0] - s[2]) < 0.05 and s[0] < 15 and abs(s[1] - s[3]) > 40})
print("basement glazing on the north wall (xflr0):", bw)
for a in (bw if len(bw) == 2 else (636.6, 833.3)):
    op_list.append({"floor": "B", "view": "north", "c": 0.0, "a": a, "b": a + 48.0, "z0": -80.0, "z1": -32.0, "kind": "window", "n": [-1, 0]})

placed = 0
for o in op_list:
    o.setdefault("kind", "window")
    ax = "x" if o["view"] in ("front", "rear") else "y"
    hits = [w for w in walls if w["axis"] == ax and abs(w["c"] - o["c"]) < 0.05 and w["a"] - 0.5 <= o["a"] and o["b"] <= w["b"] + 0.5
            and w["zb"] <= o["z0"] and o["z1"] <= max(t for _, t in w["top"]) + 0.5 and list(w["n"]) == list(o["n"])]
    if not hits:
        print("  !! opening without wall:", o["floor"], o["view"], o["c"], o["a"], o["b"])
        continue
    w = min(hits, key=lambda w: w["b"] - w["a"])
    w["openings"].append({"a": o["a"], "b": o["b"], "z0": o["z0"], "z1": o["z1"], "kind": o["kind"], "rows": o.get("rows", [])})
    placed += 1
print("openings placed:", placed, "of", len(op_list))

# ----------------------------------------------------------------------------------------------- other elements
boxes = []   # [name, x0, x1, y0, y1, z0, z1, material, tag]
# portico brick piers (xflr1 column bases; xelev height) and entablature beam
boxes += [["Portico pier north", 338.96, 362.96, 420.32, 434.32, -38.0, 228.7, "brick", "A-WALL-EXT"],
          ["Portico pier south", 448.96, 472.96, 420.32, 434.32, -38.0, 228.7, "brick", "A-WALL-EXT"],
          ["Portico entablature", 330.0, 472.0, 414.0, 434.32, 228.7, MAIN_EAVE - FASCIA, "trim", "A-TRIM"]]
# garage front (R02): cornice (eave) returns at the feet of the two front gables (xelev front, 17.5 in wide),
# and the two decorative panels flanking the bump window (xelev GENERAL_TEXTURE, 26 x 64)
boxes += [["Eave return - lower gable west", -7.0, 10.5, 8.32, 14.32, GARAGE_EAVE - FASCIA, GARAGE_EAVE + 4.0, "trim", "A-TRIM"],
          ["Eave return - lower gable east", 132.2, 149.7, 8.32, 14.32, GARAGE_EAVE - FASCIA, GARAGE_EAVE + 4.0, "trim", "A-TRIM"],
          ["Eave return - garage gable east", 270.5, 288.0, 19.36, 25.36, GARAGE_EAVE - FASCIA, GARAGE_EAVE + 3.0, "trim", "A-TRIM"]]

# window / door surrounds and stone headers (R04, xelev layer FINE):
#  - first floor (head below 130): cast-stone header 8 in high over the opening, 2 in wider each side, 1.25 in proud;
#    2 in white side casings from the sill to the header
#  - second floor brick walls: 4 in side casings and a 5.5 in apron under the sill, top against the frieze band
#  - siding walls (wing gable, dormer bays): 3.5 in casing all round
#  - basement egress windows (below grade): none
#  R07: openings of the same height set side by side (gap <= 13 in, e.g. the rear window ranks and the guest bay) form
#  one group with ONE continuous stone header and one surround around the whole group, as drawn (FINE)
def opening_groups(ops):
    groups = []
    for o in sorted(ops, key=lambda o: (round(o["z0"]), round(o["z1"]), o["a"])):
        g = groups[-1] if groups else None
        if (g and o["kind"] == "window" and g["kind"] == "window" and o["a"] - g["b"] <= 13.0
                and abs(o["z0"] - g["z0"]) < 1.0 and abs(o["z1"] - g["z1"]) < 1.0):
            g["b"] = o["b"]; g["n"] += 1
        else:
            groups.append({"a": o["a"], "b": o["b"], "z0": o["z0"], "z1": o["z1"], "kind": o["kind"], "n": 1})
    return groups


for w in walls:
    nx, ny = w["n"]
    for o in opening_groups(w["openings"]):
        a, b, z0, z1, kind = o["a"], o["b"], o["z0"], o["z1"], o["kind"]
        if z1 < 0:
            continue

        def fb(name, u0, u1, za, zb_, d0, d1, mat):
            if w["axis"] == "x":
                ya, yb = sorted((w["c"] + ny * d0, w["c"] + ny * d1))
                boxes.append([name, u0, u1, ya, yb, za, zb_, mat, "A-TRIM"])
            else:
                xa, xb = sorted((w["c"] + nx * d0, w["c"] + nx * d1))
                boxes.append([name, xa, xb, u0, u1, za, zb_, mat, "A-TRIM"])

        tag = "%s %s %.0f" % (w["view"], kind, (a + b) / 2)
        if w["mat"] in ("siding", "panel") and w["floor"] == "L2":
            c = 3.5
            fb("Casing " + tag, a - c, a, z0 - c, z1 + c, 0.0, 0.75, "trim")
            fb("Casing " + tag, b, b + c, z0 - c, z1 + c, 0.0, 0.75, "trim")
            fb("Casing " + tag, a, b, z1, z1 + c, 0.0, 0.75, "trim")
            fb("Casing " + tag, a, b, z0 - c, z0, 0.0, 0.75, "trim")
        elif z1 < 130.0:
            fb("Stone header " + tag, a - 2.0, b + 2.0, z1, z1 + 8.0, 0.0, 1.25, "stone")
            zs = z0 - (2.0 if kind == "window" else 0.0)
            fb("Casing " + tag, a - 2.0, a, max(zs, w["zb"] + 0.5), z1, 0.0, 0.75, "trim")
            fb("Casing " + tag, b, b + 2.0, max(zs, w["zb"] + 0.5), z1, 0.0, 0.75, "trim")
        else:
            fb("Surround " + tag, a - 4.0, a, z0 - 5.5, z1, 0.0, 0.75, "trim")
            fb("Surround " + tag, b, b + 4.0, z0 - 5.5, z1, 0.0, 0.75, "trim")
            fb("Surround " + tag, a, b, z0 - 5.5, z0 - 2.0, 0.0, 0.75, "trim")

# decorative panels (R03): every GENERAL_TEXTURE hatch panel of xelev - white frame board (1 in proud) with a
# speckled textured field (2 in border, 1.5 in proud). Plan position from the hatch, mapped to the wall face; the
# two dormer panels are re-centred on the bay faces (side elevations are ~5 in off against the plan).
DECO_PANELS = [  # name, face axis, face coord, outward normal, u0, u1, z0, z1
    ("Decorative panel - garage front west", "x", 14.32, -1, 17.8, 43.8, 29.0, 93.0),
    ("Decorative panel - garage front east", "x", 14.32, -1, 99.0, 125.0, 29.0, 93.0),
    ("Decorative panel - over stair window", "x", 434.32, -1, 292.8, 329.8, 64.3, 113.4),
    ("Decorative panel - over entry door", "x", 480.96, -1, 369.4, 442.4, 116.4, 151.1),
    ("Decorative panel - over front window", "x", 429.36, -1, 507.0, 581.0, 115.9, 151.6),
    ("Decorative panel - east dormer bay", "y", 282.0, 1, 246.9 - 62.9, 246.9 + 62.9, 112.4, 150.1),
    ("Decorative panel - west dormer bay", "y", 16.9, -1, 171.15 - 64.9, 171.15 + 64.9, 123.6, 152.1),
]


def face_box(axis, c, n, u0, u1, z0, z1, d0, d1):
    a, b = sorted((c + n * d0, c + n * d1))
    return (u0, u1, a, b, z0, z1) if axis == "x" else (a, b, u0, u1, z0, z1)


for name, axis, c, n, u0, u1, z0, z1 in DECO_PANELS:
    x0, x1, y0, y1, za, zb_ = face_box(axis, c, n, u0, u1, z0, z1, 0.0, 1.0)
    boxes.append([name + " frame", x0, x1, y0, y1, za, zb_, "trim", "A-TRIM"])
    x0, x1, y0, y1, za, zb_ = face_box(axis, c, n, u0 + 2.0, u1 - 2.0, z0 + 2.0, z1 - 2.0, 1.0, 1.5)
    boxes.append([name + " field", x0, x1, y0, y1, za, zb_, "deco", "A-TRIM"])
# porch stoop and 5 risers down to the front grade (-38)
boxes += [["Porch stoop", 362.96, 448.96, 420.32, 480.96, -40.0, -0.5, "concrete", "A-SLAB"]]
r = 37.5 / 5.0
for i in range(5):
    boxes.append(["Porch step %d" % (i + 1), 363.0, 449.0, 420.32 - 11.0 * (i + 1), 420.32 - 11.0 * i, -40.0, -0.5 - r * (i + 1), "concrete", "A-STAIR"])
# covered terrace (xflr1: 16x16 brick piers at the slab corners, 42" guardrail, 6R stair on the south edge)
TD = -4.0                                        # terrace deck top (pier bases on the xelev south/rear views)
for xa, xb in ((645.0, 660.7), (765.7, 781.7)):
    for ya, yb in ((582.3, 598.0), (830.4, 846.7)):
        boxes.append(["Terrace pier", xa, xb, ya, yb, TD, 97.87, "brick", "A-WALL-EXT"])
boxes += [["Terrace beam south", 645.0, 781.7, 582.3, 598.0, 97.87, 105.12, "trim", "A-TRIM"],
          ["Terrace beam north", 645.0, 781.7, 830.4, 846.7, 97.87, 105.12, "trim", "A-TRIM"],
          ["Terrace beam east", 765.7, 781.7, 582.3, 846.7, 97.87, 105.12, "trim", "A-TRIM"],
          ["Raised terrace slab", 638.96, 783.3, 581.5, 847.7, -60.0, TD, "concrete", "A-SLAB"]]
# terrace stair: 6 risers from the deck to grade (-50), 55 in wide, x 705..760, down towards -y
TR = (TD - (-50.0)) / 6.0
for i in range(5):
    boxes.append(["Terrace step %d" % (i + 1), 705.0, 760.0, 581.5 - 11.0 * (i + 1), 581.5 - 11.0 * i, -60.0, TD - TR * (i + 1), "concrete", "A-STAIR"])


def guard(name, x0, x1, y0, y1, z, along):
    """42 in guardrail between two points (axis-aligned): top rail, bottom rail, 1.5 in balusters at 5.5 in."""
    out = [[name + " top rail", x0, x1, y0, y1, z + 39.0, z + 42.0, "trim", "A-STAIR"],
           [name + " bottom rail", x0, x1, y0, y1, z + 3.0, z + 5.0, "trim", "A-STAIR"]]
    L = (x1 - x0) if along == "x" else (y1 - y0)
    n = int(L // 5.5)
    for i in range(1, n):
        u = (x0 if along == "x" else y0) + i * L / n
        if along == "x":
            out.append([name + " baluster", u - 0.75, u + 0.75, y0 + 0.5, y1 - 0.5, z + 5.0, z + 39.0, "trim", "A-STAIR"])
        else:
            out.append([name + " baluster", x0 + 0.5, x1 - 0.5, u - 0.75, u + 0.75, z + 5.0, z + 39.0, "trim", "A-STAIR"])
    return out


# stair railings (R07, xelev front / south: A-Elev-Decking): wrought-iron style - newel posts at both ends, a double
# top rail (the ring band between them simplified to square bars), a bottom rail parallel to the nosing line and
# 5/8 in pickets at about 5 in. Rails run along y down the stairs; 'sloped' items are bars with a linear bottom.
sloped = []   # [name, x0, x1, y_low, y_high, z_bottom_at_y_low, z_bottom_at_y_high, height, material]


def stair_rail(name, xc, y_lo, y_hi, z_nose_lo, z_nose_hi, h_top):
    k = (z_nose_hi - z_nose_lo) / (y_hi - y_lo)
    nose = lambda y: z_nose_lo + k * (y - y_lo)
    x0, x1 = xc - 0.75, xc + 0.75
    sloped.append([name + " top rail", x0, x1, y_lo, y_hi, nose(y_lo) + h_top - 1.5, nose(y_hi) + h_top - 1.5, 1.5, "iron"])
    sloped.append([name + " second rail", x0, x1, y_lo, y_hi, nose(y_lo) + h_top - 6.0, nose(y_hi) + h_top - 6.0, 0.75, "iron"])
    sloped.append([name + " ring band", xc - 0.3, xc + 0.3, y_lo, y_hi, nose(y_lo) + h_top - 5.25, nose(y_hi) + h_top - 5.25, 3.75, "iron_band"])
    sloped.append([name + " bottom rail", x0, x1, y_lo, y_hi, nose(y_lo) + 3.0, nose(y_hi) + 3.0, 1.0, "iron"])
    n = int((y_hi - y_lo - 4.0) // 5.0)
    for i in range(1, n + 1):
        y = y_lo + 2.0 + i * (y_hi - y_lo - 4.0) / (n + 1)
        boxes.append([name + " picket", xc - 0.31, xc + 0.31, y - 0.31, y + 0.31, nose(y) + 4.0, nose(y) + h_top - 6.0, "iron", "A-STAIR"])
    for y in (y_lo, y_hi):
        boxes.append([name + " newel post", xc - 1.5, xc + 1.5, y - 1.5, y + 1.5, nose(y) - 30.0 if y == y_lo else nose(y) - 6.0,
                      nose(y) + h_top + 3.0, "iron", "A-STAIR"])


# entry steps: 5 risers 7.5 / treads 11 from the porch (z -0.5 at y 420.32) to grade (-38); rail top ~29 in above the
# nosings as drawn (post tops 28.7 at the porch); one rail each side on the step edges x 363 / 449
for xc, side in ((363.75, "west"), (448.25, "east")):
    stair_rail("Entry stair railing %s" % side, xc, 365.32, 420.32, -38.0, -0.5, 29.0)
# terrace stair: 6 risers from the deck (-4) to grade (-50), x 705..760, rail 32 in above the nosings
for xc, side in ((705.75, "west"), (759.25, "east")):
    stair_rail("Terrace stair railing %s" % side, xc, 526.5, 581.5, -50.0 + TR, TD, 32.0)

boxes += guard("Terrace guard north", 660.7, 765.7, 836.0, 839.5, TD, "x")
boxes += guard("Terrace guard east", 770.0, 773.5, 598.0, 830.4, TD, "y")
boxes += guard("Terrace guard south-west", 660.7, 705.0, 588.5, 592.0, TD, "x")
boxes += guard("Terrace guard south-east", 760.0, 765.7, 588.5, 592.0, TD, "x")

# frieze board under the main soffit and the rowlock water table, on the brick walls (xelev bands)
for w in walls:
    if w["mat"] != "brick":
        continue
    nx, ny = w["n"]
    tmin = min(t for _, t in w["top"])

    def band(name, z0, z1, proud, mat, skip_open):
        ivs = [(w["a"], w["b"])]
        if skip_open:
            ivs = subtract((w["a"], w["b"]), [(o["a"] - 2, o["b"] + 2) for o in w["openings"] if o["z0"] < z1 and o["z1"] > z0])
        for a, b in ivs:
            if w["axis"] == "x":
                ya, yb = sorted((w["c"], w["c"] + ny * proud))
                boxes.append([name, a, b, ya, yb, z0, z1, mat, "A-TRIM"])
            else:
                xa, xb = sorted((w["c"], w["c"] + nx * proud))
                boxes.append([name, xa, xb, a, b, z0, z1, mat, "A-TRIM"])

    if tmin > 240.0:
        band("Frieze board", 228.6, 238.1, 0.75, "trim", False)      # xelev frieze band (FINE lines 228.6 / 238.1)
    if w["floor"] == "L1":
        band("Water table (rowlock)", 10.7, 16.7, 1.0, "brick", True)
# garage slab and driveway apron (ASSUMPTION: no site plan - apron 20 ft wide in front of the garage doors)
boxes += [["Garage slab", 0.0, 276.0, 14.32, 400.0, -42.0, -38.1, "concrete", "A-SLAB"],
          ["Driveway apron (assumed)", 276.0, 516.0, 25.36, 400.0, -40.0, -37.9, "asphalt", "L-SITE"]]
# frieze board under the main soffit (white, 8 in) on the brick walls
trims = [{"wall": i, "z0": MAIN_EAVE - FASCIA - 8.0 + 9.0 * 0, "z1": None} for i in range(0)]   # placeholder (frieze built in Ruby from wall tops)

# ----------------------------------------------------------------------------------------------------- terrain
G = json.load(open(os.path.join(W, "grade.json")))


def prof_at(view, u):
    pts = G[view]
    if u <= pts[0][0]: return pts[0][1]
    if u >= pts[-1][0]: return pts[-1][1]
    for (u0, z0), (u1, z1) in zip(pts, pts[1:]):
        if u0 <= u <= u1:
            return z0 + (z1 - z0) * (u - u0) / max(1e-6, u1 - u0)


X0, X1, Y0, Y1 = -60.0, 830.0, -40.0, 960.0           # building box the profiles refer to
def grade(x, y):
    # Coons-style blend of the four side profiles (front: y=Y0 along x, rear: y=Y1, north: x=X0 along y, south: x=X1)
    s = min(1, max(0, (x - X0) / (X1 - X0))); t = min(1, max(0, (y - Y0) / (Y1 - Y0)))
    xf = min(max(x, X0), X1); yf = min(max(y, Y0), Y1)
    zf, zr = prof_at("front", xf), prof_at("rear", xf)
    zn, zs = prof_at("north", yf), prof_at("south", yf)
    c00, c10, c01, c11 = prof_at("front", X0), prof_at("front", X1), prof_at("rear", X0), prof_at("rear", X1)
    return ((1 - t) * zf + t * zr + (1 - s) * zn + s * zs
            - ((1 - s) * (1 - t) * c00 + s * (1 - t) * c10 + (1 - s) * t * c01 + s * t * c11))


STEP = 24.0
gx = [-480.0 + STEP * i for i in range(int((1300 + 480) / STEP) + 1)]
gy = [-600.0 + STEP * j for j in range(int((1400 + 600) / STEP) + 1)]
foot = [L1_OUTLINE, [(638.96, 581.5), (783.3, 581.5), (783.3, 847.7), (638.96, 847.7)], [(705.0, 526.5), (760.0, 526.5), (760.0, 581.5), (705.0, 581.5)],
        [(276.0, 25.36), (516.0, 25.36), (516.0, 400.0), (276.0, 400.0)], [(362.96, 365.0), (448.96, 365.0), (448.96, 434.32), (362.96, 434.32)]]


def in_poly(x, y, poly):
    c = False
    for i in range(len(poly)):
        (x0, y0), (x1, y1) = poly[i], poly[(i + 1) % len(poly)]
        if (y0 > y) != (y1 > y) and x < x0 + (y - y0) * (x1 - x0) / (y1 - y0):
            c = not c
    return c


def zgrid(x, y):
    z = grade(x, y)
    # driveway apron and the strip down to the street side stay at the garage slab level
    if 276 <= x <= 560 and -480 <= y <= 420:
        z = -38.3
    return round(z, 2)


terrain = {"x": gx, "y": gy, "z": [[zgrid(x, y) for x in gx] for y in gy],
           "skip": [[any(in_poly(x + STEP / 2, y + STEP / 2, p) for p in foot) for x in gx] for y in gy]}
# driveway strip to the street (ASSUMPTION, no site plan)
boxes += [["Driveway to street (assumed)", 300.0, 516.0, -480.0, 25.36, -40.0, -37.9, "asphalt", "L-SITE"]]

# gutters and downspouts: not modelled (owner instruction 2026-10-17 - materials only)

spec = {"roofs": roofs, "walls": walls, "boxes": boxes, "sloped": sloped, "terrain": terrain, "fascia": FASCIA,
        "floors": [],
        "levels": {"main": L1, "upper": L2, "garage": -38.1, "main_eave": MAIN_EAVE, "wing_eave": WING_EAVE},
        "notes": fixes}
json.dump(spec, open(os.path.join(W, "r01_spec.json"), "w"))
print("walls:", len(walls), " with openings:", sum(1 for w in walls if w["openings"]), " boxes:", len(boxes))
for w in walls:
    print("  %-2s %-5s c=%7.2f %7.2f..%7.2f zb %6.1f top %6.1f..%6.1f %-6s ops %d" % (
        w["floor"], w["view"], w["c"], w["a"], w["b"], w["zb"], min(t for _, t in w["top"]), max(t for _, t in w["top"]), w["mat"], len(w["openings"])))
