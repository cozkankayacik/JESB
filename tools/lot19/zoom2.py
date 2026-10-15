import sys, json
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import numpy as np
from PIL import Image, ImageDraw
W = sys.argv[1]
vec = json.load(open(W + '\\vectors.json'))
CX, CY, CZ = 1495.0, 1475.0, 190.0
P = {'front': lambda h, z: (1200 + (h - CX) * 2, 500 - (z - CZ) * 2), 'rear': lambda h, z: (1200 - (h - CX) * 2, 500 - (z - CZ) * 2),
     'left': lambda h, z: (1200 - (h - CY) * 2, 500 - (z - CZ) * 2), 'right': lambda h, z: (1200 + (h - CY) * 2, 500 - (z - CZ) * 2)}
for v, m in (('front', 'south'), ('rear', 'north'), ('left', 'west'), ('right', 'east')):
    a = np.asarray(Image.open(W + '\\m_%s.png' % m).convert('RGB')).astype(np.float32)
    im = Image.fromarray((255 - (255 - a) * 0.5).astype(np.uint8)); d = ImageDraw.Draw(im)
    for s in vec[v]:
        if s[4] >= 0.7 and 120 < min(s[1], s[3]):
            d.line([P[v](s[0], s[1]), P[v](s[2], s[3])], fill=(230, 0, 0), width=2)
    im.crop((0, 0, 2400, 560)).save(W + '\\zoom_%s.png' % v)
