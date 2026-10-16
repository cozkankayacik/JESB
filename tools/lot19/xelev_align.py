import sys, os, json
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
W = sys.argv[1]
segs = json.load(open(os.path.join(W, 'segs.json')))
CZ = 190.0; Z0 = 1401.7   # dwg y of model z 0 (T/GRADE text 1408 = 840.3, model grade 1.3 -> approx)
views = {'front': ('m_south.png', (6250, 7700), False), 'right': ('m_east.png', (2400, 3850), False), 'rear': ('m_north.png', (3900, 4850), False), 'left': ('m_west.png', (4900, 6150), False)}
out = []
for v, (mf, (x0, x1), flip) in views.items():
    m = Image.open(os.path.join(W, mf)).convert('RGB')
    a = (np.asarray(m.convert('L').filter(ImageFilter.FIND_EDGES)) > 40).astype(np.float32)
    a = np.asarray(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))).astype(np.float32) / 255
    best = None
    ss = [s for s in segs if x0 <= min(s[0], s[2]) and max(s[0], s[2]) <= x1]
    for dz in (-6, -3, 0, 3, 6):
        img = Image.new('L', ((x1 - x0) * 2, 1000), 0); d = ImageDraw.Draw(img)
        for s in ss:
            P = lambda x, y: ((x - x0) * 2, 500 - (y - Z0 + dz - CZ) * 2)
            d.line([P(s[0], s[1]), P(s[2], s[3])], fill=255, width=1)
        b = np.asarray(img.filter(ImageFilter.MaxFilter(5))).astype(np.float32) / 255
        H, Wd = a.shape[0] + b.shape[0], a.shape[1] + b.shape[1]
        c = np.fft.irfft2(np.fft.rfft2(a, (H, Wd)) * np.fft.rfft2(b[::-1, ::-1], (H, Wd)), (H, Wd))
        row = c[b.shape[0] - 1]     # no vertical shift in pixels (dz loop handles it)
        ix = int(np.argmax(row)); val = row[ix]
        if best is None or val > best[0]: best = (val, ix - (b.shape[1] - 1), dz)
    _, dx, dz = best
    out.append((v, dx, dz, x0))
    ov = np.asarray(m).astype(np.float32); ov = 255 - (255 - ov) * 0.5
    img = Image.fromarray(ov.astype(np.uint8)); d = ImageDraw.Draw(img)
    for s in ss:
        P = lambda x, y: ((x - x0) * 2 + dx, 500 - (y - Z0 + dz - CZ) * 2)
        d.line([P(s[0], s[1]), P(s[2], s[3])], fill=(220, 0, 0), width=1)
    img.save(os.path.join(W, 'ovx_%s.png' % v))
json.dump(out, open(os.path.join(W, 'align.json'), 'w')); print(out)
