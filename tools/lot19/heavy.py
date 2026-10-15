import sys, json, math
W = sys.argv[1]
vec = json.load(open(W + '\\vectors.json'))
LIM = {'front': (1080, 1900), 'rear': (1080, 1900), 'left': (1050, 2000), 'right': (1050, 2000)}
for v in ('front', 'rear', 'left', 'right'):
    a0, a1 = LIM[v]; rows = set()
    for s in vec[v]:
        if s[4] < 1.3: continue
        if not (a0 < min(s[0], s[2]) and max(s[0], s[2]) < a1 and 125 < min(s[1], s[3]) and max(s[1], s[3]) < 420): continue
        if math.hypot(s[2] - s[0], s[3] - s[1]) < 12: continue
        a, b = sorted([(round(s[0], 1), round(s[1], 1)), (round(s[2], 1), round(s[3], 1))])
        rows.add((a, b))
    print('=====', v, len(rows))
    for a, b in sorted(rows, key=lambda r: (-max(r[0][1], r[1][1]), r[0][0])):
        dz = b[1] - a[1]; dh = b[0] - a[0]
        tag = 'H' if abs(dz) < 0.2 else ('V' if abs(dh) < 0.2 else '%.1f:12' % (abs(dz / dh) * 12))
        print('  %-7s (%7.1f,%6.1f) - (%7.1f,%6.1f)' % (tag, a[0], a[1], b[0], b[1]))
