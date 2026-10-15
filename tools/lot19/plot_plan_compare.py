# JESB Lot 19 - roof plan vectors (black) vs model wall cuts at z 100 (blue) / 230 (red) and model roof edges (green).
import sys, os, json
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
from PIL import Image, ImageDraw, ImageFont
W = sys.argv[1]
X0, X1, Y0, Y1 = 1080, 1920, 880, 2060
S = 2.4
vec = json.load(open(os.path.join(W, 'vectors.json')))['roof']
cut = json.load(open(os.path.join(W, 'cuts.json')))
img = Image.new('RGB', (int((X1 - X0) * S), int((Y1 - Y0) * S)), 'white'); d = ImageDraw.Draw(img)
P = lambda x, y: ((x - X0) * S, (Y1 - y) * S)
try: f = ImageFont.truetype('arial.ttf', 14)
except Exception: f = ImageFont.load_default()
for g in range(int(X0 // 50 * 50), X1, 50):
    d.line([P(g, Y0), P(g, Y1)], fill=(225, 225, 240)); d.text((P(g, Y1)[0] + 2, 2), str(g), fill=(90, 90, 200), font=f)
for g in range(int(Y0 // 50 * 50), Y1, 50):
    d.line([P(X0, g), P(X1, g)], fill=(225, 225, 240)); d.text((2, P(X0, g)[1] - 15), str(g), fill=(90, 90, 200), font=f)
for r in cut['roofs']:
    pts = [P(p[0], p[1]) for p in r['pts']]
    d.line(pts + [pts[0]], fill=(0, 170, 0), width=1)
for z, col in (('100.0', (0, 90, 255)), ('230.0', (230, 0, 0))):
    for s in cut['cuts'][z]:
        d.line([P(s[0], s[1]), P(s[2], s[3])], fill=col, width=3)
for s in vec:
    if X0 < s[0] < X1 and Y0 < s[1] < Y1 and X0 < s[2] < X1 and Y0 < s[3] < Y1:
        d.line([P(s[0], s[1]), P(s[2], s[3])], fill=(0, 0, 0), width=1)
img.save(os.path.join(W, 'plan_compare.png'))
print(img.size)
