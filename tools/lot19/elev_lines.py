# JESB Lot 19 - list roof-relevant lines of each elevation (model coordinates): sloped lines and long horizontals above z 120.
import sys, os, json, math, collections
W = sys.argv[1]
vec = json.load(open(os.path.join(W, 'vectors.json')))
LIM = {'front': (1100, 1900), 'rear': (1100, 1900), 'left': (900, 2060), 'right': (900, 2060)}
out = []
for v in ('front', 'rear', 'left', 'right'):
    a0, a1 = LIM[v]
    segs = [s for s in vec[v] if a0 < min(s[0], s[2]) and max(s[0], s[2]) < a1 and 120 < min(s[1], s[3]) and max(s[1], s[3]) < 420]
    out.append('===== %s (h = %s, z)' % (v, 'x' if v in ('front', 'rear') else 'y'))
    hor = collections.defaultdict(list); slo = []
    for s in segs:
        dx, dz = s[2] - s[0], s[3] - s[1]; L = math.hypot(dx, dz)
        if L < 15: continue
        if abs(dz) < 0.05: hor[round(s[1], 1)].append((round(min(s[0], s[2]), 1), round(max(s[0], s[2]), 1), s[4]))
        elif abs(dx) > 2 and abs(dz) > 2: slo.append((s, abs(dz / dx) * 12, L))
    out.append('-- horizontals z: [h0..h1 width]')
    for z in sorted(hor, reverse=True):
        it = sorted(set(hor[z]))
        if max(b - a for a, b, _ in it) < 25: continue
        out.append('%7.1f: %s' % (z, ' '.join('[%.1f..%.1f w%.1f]' % t for t in it[:8])))
    out.append('-- sloped (h1,z1)-(h2,z2) pitch/12 len')
    seen = set()
    for s, p, L in sorted(slo, key=lambda t: (round(min(t[0][0], t[0][2])), t[0][1])):
        k = (round(s[0]), round(s[1]), round(s[2]), round(s[3]))
        if k in seen or L < 30: continue
        seen.add(k)
        out.append('  (%.1f,%.1f)-(%.1f,%.1f) %.2f len %.0f w%.1f' % (s[0], s[1], s[2], s[3], p, L, s[4]))
open(os.path.join(W, 'elev_lines.txt'), 'w').write('\n'.join(out))
print(len(out))
