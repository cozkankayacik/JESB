"""Cluster the red 'motif' line work of the elevation DWG (window muntins, door/panel motifs, decking/rail motifs)
into connected groups and report their bounding boxes per elevation, in plan/z terms.

Usage: python -I motifs_extract.py <work_dir>   -> motifs.json
"""
import sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from geometry import ELEV, Z_DATUM

W = sys.argv[1]
S = json.load(open(os.path.join(W, "xelev_segs.json")))
RANGE = {"front": (6380, 7330), "south": (7440, 8600), "rear": (3550, 4520), "north": (5150, 6200)}
LAY = ("A-Elev-Glaz-Munt", "A-Elev-Door-Half", "A-Elev-Decking", "A-Flor-Hral")


def view_of(x):
    for v, (a, b) in RANGE.items():
        if a <= x <= b:
            return v


segs = [s for s in S if s[4] in LAY and view_of((s[0] + s[2]) / 2)]
par = list(range(len(segs)))


def find(i):
    while par[i] != i:
        par[i] = par[par[i]]; i = par[i]
    return i


def touch(s, t, tol=0.6):
    # endpoint of one on the other (or endpoints close)
    for (x, y) in ((s[0], s[1]), (s[2], s[3])):
        if min(t[0], t[2]) - tol <= x <= max(t[0], t[2]) + tol and min(t[1], t[3]) - tol <= y <= max(t[1], t[3]) + tol:
            dx, dy = t[2] - t[0], t[3] - t[1]
            L = max(1e-9, (dx * dx + dy * dy) ** 0.5)
            if abs(dx * (y - t[1]) - dy * (x - t[0])) / L < tol:
                return True
    return False


grid = {}
for i, s in enumerate(segs):
    for gx in range(int(min(s[0], s[2]) // 12), int(max(s[0], s[2]) // 12) + 1):
        for gy in range(int(min(s[1], s[3]) // 12), int(max(s[1], s[3]) // 12) + 1):
            grid.setdefault((gx, gy), []).append(i)
for cell in grid.values():
    for a in range(len(cell)):
        for b in range(a + 1, len(cell)):
            i, j = cell[a], cell[b]
            if segs[i][4] == segs[j][4] and (touch(segs[i], segs[j]) or touch(segs[j], segs[i])):
                ri, rj = find(i), find(j)
                if ri != rj:
                    par[ri] = rj
groups = {}
for i, s in enumerate(segs):
    groups.setdefault(find(i), []).append(s)
out = []
for g in groups.values():
    xs = [v for s in g for v in (s[0], s[2])]; ys = [v for s in g for v in (s[1], s[3])]
    v = view_of((min(xs) + max(xs)) / 2)
    e = ELEV[v]
    p0, p1 = sorted(((min(xs) - e["c"]) * e["sign"], (max(xs) - e["c"]) * e["sign"]))
    out.append({"view": v, "layer": g[0][4], "n": len(g), "ex0": round(min(xs), 2), "ex1": round(max(xs), 2),
                "plan0": round(p0, 2), "plan1": round(p1, 2), "z0": round(min(ys) - Z_DATUM, 2), "z1": round(max(ys) - Z_DATUM, 2),
                "segs": [[round(c, 3) for c in s[:4]] for s in g]})
out.sort(key=lambda o: (o["view"], o["layer"], o["plan0"], o["z0"]))
json.dump(out, open(os.path.join(W, "motifs.json"), "w"))
for o in out:
    if o["z1"] - o["z0"] < 1 and o["plan1"] - o["plan0"] < 1:
        continue
    print("%-6s %-18s n=%3d plan %7.1f..%7.1f  z %6.1f..%6.1f" % (o["view"], o["layer"], o["n"], o["plan0"], o["plan1"], o["z0"], o["z1"]))
