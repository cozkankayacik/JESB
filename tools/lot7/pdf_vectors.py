# JESB Lot 7 - extract vector lines of the roof plan and the four elevations from the Revision 1 PDF and express
# them in model coordinates (inches), using the alignment found by overlay_pdf.py (same crops, same offsets).
# usage: python pdf_vectors.py <pdf> <folder with overlay.txt>   -> vectors.json, vec_<view>.png
import sys, os, json, re
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import pymupdf
from PIL import Image, ImageDraw

PDF, W = sys.argv[1], sys.argv[2]
Z = 4.0 / 3.0                          # pixmap scale used by overlay_pdf (2 px per real inch)
F = 96 / 55 * 1.155                    # crop factor used by crop.py
CROPS = {'front': (7, (290, 70)), 'right': (7, (200, 720)), 'rear': (8, (290, 90)), 'left': (8, (320, 670)), 'roof': (6, (90, 330))}
VIEW = {'front': 'south', 'rear': 'north', 'left': 'west', 'right': 'east', 'roof': 'top'}
CX, CY, CZ = 1950.0, 3780.0, 190.0
off = {}
for line in open(os.path.join(W, 'overlay.txt')):
    m = re.match(r'(\w+) vs (\w+): drawing placed at dx (-?\d+) dy (-?\d+)', line)
    if m: off[m.group(1)] = (int(m.group(3)), int(m.group(4)))

def to_model(view, px, py):
    """px, py: pixel in the model ortho image (2400 wide, centre = model centre)."""
    if view == 'roof':   return (CX + (px - 1200) / 2.0, CY - (py - 1200) / 2.0)
    h = (px - 1200) / 2.0; z = CZ - (py - 500) / 2.0
    if view == 'front':  return (CX + h, z)          # x, z
    if view == 'rear':   return (CX - h, z)          # x, z  (view from north: image right = -x)
    if view == 'left':   return (CY - h, z)          # y, z  (view from west: image right = -y)
    if view == 'right':  return (CY + h, z)          # y, z

doc = pymupdf.open(PDF)
out = {}
for view, (pg, (cx0, cy0)) in CROPS.items():
    page = doc[pg - 1]
    rm = page.rotation_matrix * pymupdf.Matrix(Z, Z)
    ox, oy = int(cx0 * F), int(cy0 * F)
    dx, dy = off[view]
    segs = []
    for d in page.get_drawings():
        col = d.get('color')
        for it in d['items']:
            if it[0] == 'l':
                ps = [it[1], it[2]]
            elif it[0] == 're':
                r = it[1]; ps = [r.tl, r.tr, r.br, r.bl, r.tl]
            elif it[0] == 'qu':
                q = it[1]; ps = [q.ul, q.ur, q.lr, q.ll, q.ul]
            else:
                continue
            for a, b in zip(ps, ps[1:]):
                A = a * rm; B = b * rm
                pa = (A.x - ox + dx, A.y - oy + dy); pb = (B.x - ox + dx, B.y - oy + dy)
                if not (-200 < pa[0] < 2600 and -200 < pa[1] < (2600 if view == 'roof' else 1200)): continue
                ma = to_model(view, *pa); mb = to_model(view, *pb)
                segs.append([round(ma[0], 2), round(ma[1], 2), round(mb[0], 2), round(mb[1], 2), round(d.get('width') or 0, 2)])
    out[view] = segs
    img = Image.new('RGB', (2400, 2400 if view == 'roof' else 1000), 'white'); dr = ImageDraw.Draw(img)
    for s in segs:
        if view == 'roof':
            P = lambda x, y: (1200 + (x - CX) * 2, 1200 - (y - CY) * 2)
        elif view in ('front',):
            P = lambda x, y: (1200 + (x - CX) * 2, 500 - (y - CZ) * 2)
        elif view == 'rear':
            P = lambda x, y: (1200 - (x - CX) * 2, 500 - (y - CZ) * 2)
        elif view == 'left':
            P = lambda x, y: (1200 - (x - CY) * 2, 500 - (y - CZ) * 2)
        else:
            P = lambda x, y: (1200 + (x - CY) * 2, 500 - (y - CZ) * 2)
        dr.line([P(s[0], s[1]), P(s[2], s[3])], fill=(0, 0, 0), width=1)
    img.save(os.path.join(W, 'vec_%s.png' % view))
    print(view, len(segs), 'segments')
json.dump(out, open(os.path.join(W, 'vectors.json'), 'w'))

