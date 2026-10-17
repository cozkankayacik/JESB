"""Find window/door openings: horizontal span from the floor plans (glazing/door lines on an exterior face),
vertical span from the elevation (holes in the brick/siding hatch, or outline rectangles).

Usage: python -I openings.py <work_dir>
needs: xflr1_plan_segs.json, xflr2_plan_segs.json, xflr0_plan_segs.json, xelev_hatch.json, xelev_segs.json
writes: openings.json, openings_report.txt
"""
import sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from geometry import *

W = sys.argv[1]
H = json.load(open(os.path.join(W, "xelev_hatch.json")))
ES = json.load(open(os.path.join(W, "xelev_segs.json")))
EL_RANGE = {"front": (6380, 7330), "south": (7440, 8600), "rear": (3550, 4520), "north": (5150, 6200)}


def view_of(x):
    for v, (a, b) in EL_RANGE.items():
        if a <= x <= b:
            return v


# ---- elevation rectangles: hatch holes + closed outline rectangles ----
rects = {v: [] for v in EL_RANGE}
for h in H:
    if h["pattern"] in ("SOLID",) or h["layer"] == "0":
        continue
    for poly in h["polys"]:
        xs = [p[0] for p in poly]; ys = [p[1] for p in poly]
        w, hh = max(xs) - min(xs), max(ys) - min(ys)
        # rectangle test: every vertex on the bbox
        rect = all((abs(p[0] - min(xs)) < 0.05 or abs(p[0] - max(xs)) < 0.05) and (abs(p[1] - min(ys)) < 0.05 or abs(p[1] - max(ys)) < 0.05) for p in poly)
        v = view_of((min(xs) + max(xs)) / 2)
        if rect and v and 14 <= w <= 220 and 14 <= hh <= 160:
            rects[v].append((min(xs), max(xs), min(ys) - Z_DATUM, max(ys) - Z_DATUM, h["pattern"]))


# window/door units drawn as exploded line work (layers ARWINDOW / ARDOOR / A-Elev-Glaz): cluster connected lines
UNIT_LAYERS = ("ARWINDOW", "ARDOOR", "A-Elev-Glaz")
us = [s for s in ES if s[4] in UNIT_LAYERS]
parent = list(range(len(us)))


def find(i):
    while parent[i] != i:
        parent[i] = parent[parent[i]]
        i = parent[i]
    return i


cell = {}
for i, s in enumerate(us):
    for (x, y) in ((s[0], s[1]), (s[2], s[3])):
        cell.setdefault((round(x), round(y)), []).append(i)
for i, s in enumerate(us):
    for (x, y) in ((s[0], s[1]), (s[2], s[3])):
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                for j in cell.get((round(x) + dx, round(y) + dy), []):
                    t = us[j]
                    if min(abs(x - t[0]) + abs(y - t[1]), abs(x - t[2]) + abs(y - t[3])) < 0.6 or \
                       (min(t[0], t[2]) - 0.3 <= x <= max(t[0], t[2]) + 0.3 and min(t[1], t[3]) - 0.3 <= y <= max(t[1], t[3]) + 0.3 and
                        abs((t[2] - t[0]) * (y - t[1]) - (t[3] - t[1]) * (x - t[0])) / max(1e-6, ((t[2] - t[0]) ** 2 + (t[3] - t[1]) ** 2) ** 0.5) < 0.3):
                        a, b = find(i), find(j)
                        if a != b:
                            parent[a] = b
groups = {}
for i, s in enumerate(us):
    groups.setdefault(find(i), []).append(s)
units = []
for g in groups.values():
    xs = [v for s in g for v in (s[0], s[2])]; ys = [v for s in g for v in (s[1], s[3])]
    if max(xs) - min(xs) >= 12 and max(ys) - min(ys) >= 12:
        v = view_of((min(xs) + max(xs)) / 2)
        if v:
            rects[v].append((min(xs), max(xs), min(ys) - Z_DATUM, max(ys) - Z_DATUM, "UNIT:" + g[0][4]))
for o in json.load(open(os.path.join(W, "xelev_inserts.json"))):
    if o["name"].startswith(("garage", "DR")):
        v = view_of((o["x0"] + o["x1"]) / 2)
        if v:
            rects[v].append((o["x0"], o["x1"], o["y0"] - Z_DATUM, o["y1"] - Z_DATUM, "BLOCK:" + o["name"]))
json.dump(rects, open(os.path.join(W, "elev_units.json"), "w"), indent=0)


def plan_spans(segs, poly, layers=("A-Glaz", "A-Door"), band=(1.0, 14.0)):
    """Merge glazing/door lines parallel to each exterior face and within the wall band into spans."""
    res = []
    for p, q, n, view in faces(poly):
        horiz = abs(p[1] - q[1]) < 0.01
        lo, hi = sorted((p[0], q[0])) if horiz else sorted((p[1], q[1]))
        c = p[1] if horiz else p[0]
        iv = []
        for s in segs:
            if s[4] not in layers:
                continue
            if horiz and abs(s[1] - s[3]) < 0.05:
                d = (s[1] - c) * (-n[1])          # depth into the wall (+ = inside)
                a, b = sorted((s[0], s[2]))
            elif not horiz and abs(s[0] - s[2]) < 0.05:
                d = (s[0] - c) * (-n[0])
                a, b = sorted((s[1], s[3]))
            else:
                continue
            if band[0] <= d <= band[1] and b - a > 6 and a >= lo - 1 and b <= hi + 1:
                iv.append((a, b))
        iv.sort()
        merged = []
        for a, b in iv:
            if merged and a <= merged[-1][1] + 0.3:
                merged[-1][1] = max(merged[-1][1], b)
            else:
                merged.append([a, b])
        for a, b in merged:
            if b - a >= 12:
                res.append({"view": view, "face": [p, q], "n": n, "a": round(a, 2), "b": round(b, 2), "c": c})
    return res


out, rep = [], []
for floor, fn, poly, zmin, zmax in (("L1", "xflr1", L1_OUTLINE, -20, 125), ("L2", "xflr2", L2_OUTLINE, 125, 260)):
    segs = json.load(open(os.path.join(W, fn + "_plan_segs.json")))
    for sp in plan_spans(segs, poly):
        v = sp["view"]
        ea, eb = sorted((to_elev(v, *(sp["a"], sp["c"]) if abs(sp["face"][0][1] - sp["face"][1][1]) < 0.01 else (sp["c"], sp["a"])),
                         to_elev(v, *(sp["b"], sp["c"]) if abs(sp["face"][0][1] - sp["face"][1][1]) < 0.01 else (sp["c"], sp["b"]))))
        best, bo = None, 0
        for r in rects[v]:
            if not (zmin <= (r[2] + r[3]) / 2 <= zmax):
                continue
            ov = min(eb, r[1]) - max(ea, r[0])
            frac = ov / max(eb - ea, r[1] - r[0])
            if frac > bo:
                best, bo = r, frac
        sp["floor"] = floor
        if best and bo > 0.6:
            sp["z0"], sp["z1"] = round(best[2], 2), round(best[3], 2)
            sp["elev_dx"] = round(((best[0] + best[1]) - (ea + eb)) / 2, 2)
            sp["elev_w"] = round(best[1] - best[0], 2)
            sp["src"] = best[4]
        out.append(sp)
        rep.append("%s %-5s face %-28s span %7.2f..%7.2f (w %6.2f)  %s" % (
            floor, v, "%s-%s" % (tuple(sp["face"][0]), tuple(sp["face"][1])), sp["a"], sp["b"], sp["b"] - sp["a"],
            ("z %6.1f..%6.1f elev w %6.1f dx %+5.1f %s" % (sp["z0"], sp["z1"], sp["elev_w"], sp["elev_dx"], sp["src"])) if "z0" in sp else "NO ELEVATION MATCH"))
json.dump(out, open(os.path.join(W, "openings.json"), "w"), indent=1)
open(os.path.join(W, "openings_report.txt"), "w").write("\n".join(rep))
print("\n".join(rep))
print(len(out), "openings,", sum(1 for o in out if "z0" in o), "matched")
