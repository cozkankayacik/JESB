import sys, json, collections
W = sys.argv[1]
c = json.load(open(W + '\\cuts.json'))['cuts']['230.0']
# merge collinear axis-aligned segments of wall faces (ignore short ones)
xs = collections.defaultdict(list); ys = collections.defaultdict(list)
for s in c:
    x0, y0, x1, y1 = s[:4]
    if abs(x0 - x1) < 0.05 and abs(y1 - y0) > 12: xs[round(x0, 1)].append((round(min(y0, y1), 1), round(max(y0, y1), 1), s[4]))
    elif abs(y0 - y1) < 0.05 and abs(x1 - x0) > 12: ys[round(y0, 1)].append((round(min(x0, x1), 1), round(max(x0, x1), 1), s[4]))
print('--- faces parallel to y (x = const), z 230')
for x in sorted(xs): print('  x %7.1f  %s' % (x, sorted(set(xs[x]))[:5]))
print('--- faces parallel to x (y = const), z 230')
for y in sorted(ys): print('  y %7.1f  %s' % (y, sorted(set(ys[y]))[:5]))
