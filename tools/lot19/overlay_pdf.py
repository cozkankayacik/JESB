# JESB Lot 19 - align drawing views (rendered from the PDF at 2 px per real inch) with the model's ortho views
# (also 2 px per inch) by cross-correlating edge maps, then draw the drawing's lines in red over the model.
# usage: python overlay_pdf.py <folder>   (expects pdf_<view>.png and m_<side>.png in that folder)
import sys, os
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import numpy as np
from PIL import Image, ImageFilter

W = sys.argv[1]
PAIRS = [('front', 'south', 0), ('rear', 'north', 0), ('left', 'west', 0), ('right', 'east', 0), ('roof', 'top', 0)]

def model_edges(im):
    g = np.asarray(im.convert('L').filter(ImageFilter.FIND_EDGES)).astype(np.float32)
    return (g > 40).astype(np.float32)

def pdf_lines(im):
    g = np.asarray(im.convert('L')).astype(np.float32)
    return (g < 110).astype(np.float32)

def best_shift(a, b, coarse=4):
    """shift (dy, dx) to apply to b so that it best matches a"""
    def xc(A, B):
        H, Wd = A.shape[0] + B.shape[0], A.shape[1] + B.shape[1]
        FA = np.fft.rfft2(A, (H, Wd)); FB = np.fft.rfft2(B[::-1, ::-1], (H, Wd))
        c = np.fft.irfft2(FA * FB, (H, Wd))
        iy, ix = np.unravel_index(np.argmax(c), c.shape)
        return iy - (B.shape[0] - 1), ix - (B.shape[1] - 1), c.max()
    A = a[::coarse, ::coarse]; B = b[::coarse, ::coarse]
    dy, dx, _ = xc(A, B)
    return dy * coarse, dx * coarse

out = []
for pv, mv, rot in PAIRS:
    pp = os.path.join(W, 'pdf_%s.png' % pv); mp = os.path.join(W, 'm_%s.png' % mv)
    if not (os.path.exists(pp) and os.path.exists(mp)): continue
    pim = Image.open(pp).convert('RGB')
    if rot: pim = pim.rotate(rot, expand=True, fillcolor=(255, 255, 255))
    mim = Image.open(mp).convert('RGB')
    a = model_edges(mim); b = pdf_lines(pim)
    # blur both a little so thin lines still correlate
    a = np.asarray(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))).astype(np.float32) / 255
    b2 = np.asarray(Image.fromarray((b * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))).astype(np.float32) / 255
    dy, dx = best_shift(a, b2)
    # refine at full resolution in a +-6 px window
    best = None
    H, Wd = a.shape
    for ry in range(-6, 7, 2):
        for rx in range(-6, 7, 2):
            oy, ox = dy + ry, dx + rx
            y0, x0 = max(0, oy), max(0, ox); y1, x1 = min(H, oy + b.shape[0]), min(Wd, ox + b.shape[1])
            if y1 <= y0 or x1 <= x0: continue
            s = (a[y0:y1, x0:x1] * b2[y0 - oy:y1 - oy, x0 - ox:x1 - ox]).sum()
            if best is None or s > best[0]: best = (s, oy, ox)
    _, oy, ox = best
    ov = np.asarray(mim).copy()
    mask = np.zeros(a.shape, bool)
    y0, x0 = max(0, oy), max(0, ox); y1, x1 = min(H, oy + b.shape[0]), min(Wd, ox + b.shape[1])
    mask[y0:y1, x0:x1] = b[y0 - oy:y1 - oy, x0 - ox:x1 - ox] > 0
    ov[mask] = (230, 0, 0)
    Image.fromarray(ov).save(os.path.join(W, 'ov_%s.png' % pv))
    out.append('%s vs %s: drawing placed at dx %d dy %d px (model image coords)' % (pv, mv, ox, oy))
open(os.path.join(W, 'overlay.txt'), 'w').write('\n'.join(out) + '\n')
print('\n'.join(out))
