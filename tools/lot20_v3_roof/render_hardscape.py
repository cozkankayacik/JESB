# JESB Lot 20 v3 - put the model's hardscape (driveways) into the four AI elevation renders.
# The house part of each render is untouched; only the ground below the grade line is edited.
# Driveway outlines come from JESB_Lot20_v3.skp (Asphalt_06_1K faces). In an elevation the ground is seen
# edge-on, so it is drawn as a one-point perspective foreground: true scale at the wall base, vanishing point
# on the image centre line EYE px above the grade line, camera DIST inches from the reference wall.
# usage: python render_hardscape.py <renders folder> <output folder>
import sys, os
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SRC, OUT = sys.argv[1], sys.argv[2]
EYE = 190.0                                 # vanishing point height above the grade line, px
DIST = 820.0                                # camera distance from the reference wall, inches
# hardscape in model coordinates (inches)
FRONT_DRIVE = [(12614.8, 3446.0), (12789.9, 3446.0), (12789.9, 3330.2), (12948.7, 3330.2), (12948.7, 3764.4), (12614.8, 3764.4)]
REAR_DRIVE = [(12493.0, 4040.1), (12493.0, 4417.4), (12361.7, 4417.4), (12361.7, 4040.1)]

def load(side): return Image.open(os.path.join(SRC, 'JESB_Lot20_v3_Render_%s.png' % side)).convert('RGB')

# per render: facade scale s (px/in), anchor (model lateral coordinate -> px), grade row y0, measured on the renders
VIEW = {
    'Front': dict(s=1.3356, px=lambda x, y: 210 + (x - 12344.8) * 1.3356, y0=723, depth=lambda x, y: 3773.1 - y),
    'Right': dict(s=1.3746, px=lambda x, y: 175 + (y - 3417.1) * 1.3746, y0=742, depth=lambda x, y: x - 12614.8),
    'Rear':  dict(s=1.4636, px=lambda x, y: 397 + (13043.8 - x) * 1.4636, y0=749, depth=lambda x, y: y - 4040.1),
    'Left':  dict(s=1.4490, px=lambda x, y: 104 + (4346.1 - y) * 1.4490, y0=715, depth=lambda x, y: 12506.8 - x),
}
def project(side, poly):
    v = VIEW[side]
    cx = 793.0
    out = []
    for x, y in poly:
        k = DIST / (DIST - v['depth'](x, y))
        out.append((cx + (v['px'](x, y) - cx) * k, v['y0'] - EYE + EYE * k))
    return out

rear0 = load('Rear'); left0 = load('Left')
# asphalt look sampled from the asphalt already painted in the rear render
patch = np.asarray(rear0.crop((1335, 775, 1400, 985))).astype(np.float32)
A_MEAN = patch.reshape(-1, 3).mean(0); A_STD = float(patch.mean(2).std())
rng = np.random.default_rng(20)
def asphalt(w, h):
    n = rng.normal(0, A_STD * 1.25, (h, w)).astype(np.float32)
    n = np.asarray(Image.fromarray(np.clip(n + 128, 0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.7))).astype(np.float32) - 128
    grad = np.linspace(-3, 4, h, dtype=np.float32)[:, None]            # a touch lighter toward the viewer
    return Image.fromarray(np.clip(A_MEAN[None, None, :] + (n + grad)[:, :, None], 0, 255).astype(np.uint8))

def paint_asphalt(img, pts):
    w, h = img.size
    SS = 4
    m = Image.new('L', (w * SS, h * SS), 0)
    ImageDraw.Draw(m).polygon([(x * SS, y * SS) for x, y in pts], fill=255)
    m = m.resize((w, h), Image.LANCZOS)
    img.paste(asphalt(w, h), (0, 0), m)
    # soft darker edge line so the paving reads against the grass
    edge = m.filter(ImageFilter.FIND_EDGES).filter(ImageFilter.GaussianBlur(0.8)).point(lambda v: min(255, int(v * 0.55)))
    img.paste(Image.new('RGB', (w, h), (46, 48, 50)), (0, 0), edge)

def grass_band(width, rows, mirror=False):
    g = left0.crop((0, 737, left0.width, left0.height))                 # clean lawn of the left render
    if mirror: g = g.transpose(Image.FLIP_LEFT_RIGHT)
    return g.resize((width, rows), Image.LANCZOS)

res = {}
# ---- Front and Right: blank presentation ground -> lawn + driveway ----
for side, poly, mirror in (('Front', FRONT_DRIVE, False), ('Right', FRONT_DRIVE, True)):
    im = load(side); w, h = im.size; y0 = VIEW[side]['y0']
    top = y0 - 1
    band = grass_band(w, h - top, mirror)
    mask = Image.new('L', (w, h - top), 255)
    md = ImageDraw.Draw(mask)
    for i in range(4): md.line([(0, i), (w, i)], fill=int(255 * (i + 1) / 5))      # feather into the grade line
    im.paste(band, (0, top), mask)
    paint_asphalt(im, project(side, poly))
    res[side] = im

# ---- Rear: keep the lawn, remove the diagonal driveway, paint the straight strip of the model ----
im = load('Rear'); w, h = im.size; y0 = VIEW['Rear']['y0']
half = w // 2
lawn = im.crop((0, y0 + 4, half, h)).transpose(Image.FLIP_LEFT_RIGHT)          # left half is clean lawn
im.paste(lawn, (w - half, y0 + 4))
strip = im.crop((1100, y0 + 4, 1500, y0 + 10)).resize((400, 6))                 # thin band right under the wall base
im.paste(strip.transpose(Image.FLIP_TOP_BOTTOM), (1100, y0 - 1))
paint_asphalt(im, project('Rear', REAR_DRIVE))
res['Rear'] = im

# ---- Left: keep the lawn, remove the old strip, paint the strip of the model ----
im = load('Left'); w, h = im.size; y0 = VIEW['Left']['y0']
src = im.crop((0, 742, 440, 742 + 36))                                          # lawn just below the old strip
m = Image.new('L', (440, 36), 255); md = ImageDraw.Draw(m)
for i in range(3): md.line([(0, i), (440, i)], fill=int(255 * (i + 1) / 4))
for x in range(30): md.line([(410 + x, 0), (410 + x, 36)], fill=int(255 * (29 - x) / 30))
keep = im.crop((95, 690, 240, y0 + 2))                                          # deck platform and pier base stay
im.paste(src, (0, 704), m)
im.paste(keep.crop((0, 0, 145, y0 - 690)), (95, 690))
paint_asphalt(im, project('Left', REAR_DRIVE))
res['Left'] = im

os.makedirs(OUT, exist_ok=True)
for side, im in res.items():
    im.save(os.path.join(OUT, 'JESB_Lot20_v3_Render_%s.png' % side))
    print(side, [tuple(round(c, 1) for c in p) for p in project(side, FRONT_DRIVE if side in ('Front', 'Right') else REAR_DRIVE)])
print('asphalt mean', A_MEAN.round(1), 'std', round(A_STD, 2))
