"""Grade profiles along the four sides from the elevation grade lines (A-Elev-Grad, plus A-Elev-Plat stubs).

For each elevation, the finished grade at a horizontal position is the highest grade line found there (the drawn
grade is the line on the face of the building). Output: grade.json {view: [[plan_coord, z], ...]} in plan inches.
Usage: python -I grade_profiles.py <work_dir>
"""
import sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from geometry import ELEV, Z_DATUM

W = sys.argv[1]
S = json.load(open(os.path.join(W, "xelev_segs.json")))
RANGE = {"front": (6380, 7330), "south": (7440, 8600), "rear": (3550, 4520), "north": (5150, 6200)}
out = {}
for v, (a, b) in RANGE.items():
    segs = [s for s in S if s[4] == "A-Elev-Grad" and a - 200 < min(s[0], s[2]) and max(s[0], s[2]) < b + 200]
    prof = []
    x = a - 150
    while x <= b + 150:
        zs = []
        for s in segs:
            x0, y0, x1, y1 = s[:4]
            if min(x0, x1) <= x <= max(x0, x1) and abs(x1 - x0) > 1e-6:
                zs.append(y0 + (y1 - y0) * (x - x0) / (x1 - x0))
        if zs:
            e = ELEV[v]
            prof.append([round((x - e["c"]) * e["sign"], 1), round(max(zs) - Z_DATUM, 2)])
        x += 6
    prof.sort()
    out[v] = prof
    print(v, len(prof), "pts; z range", min(p[1] for p in prof) if prof else None, max(p[1] for p in prof) if prof else None)
    print("   ", prof[:: max(1, len(prof) // 12)])
json.dump(out, open(os.path.join(W, "grade.json"), "w"))
