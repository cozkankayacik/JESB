import sys, os
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf
from PIL import Image, ImageDraw
W = os.path.dirname(os.path.abspath(__file__))
TX, TY = 17273.64, 4111.42
CX, CY, CZ, H = 12776.80, 3838.76, 187.33, 813.694
doc = ezdxf.readfile(os.path.join(W, 'lot20.dxf'))
segs = []
def walk(ents):
    for e in ents:
        t = e.dxftype(); L = e.dxf.layer
        if t == 'LINE': segs.append((e.dxf.start.x, e.dxf.start.y, e.dxf.end.x, e.dxf.end.y, L))
        elif t == 'LWPOLYLINE':
            pts = [(p[0], p[1]) for p in e.get_points()]
            if e.closed: pts.append(pts[0])
            for a, b in zip(pts, pts[1:]): segs.append((a[0], a[1], b[0], b[1], L))
        elif t == 'INSERT':
            try: walk(list(e.virtual_entities()))
            except Exception: pass
walk(doc.modelspace())
def overlay(src, dst, box, fn, crop):
    img = Image.open(os.path.join(W, src)).convert('RGB'); d = ImageDraw.Draw(img)
    x0, x1, y0, y1 = box
    for s in segs:
        if x0 <= min(s[0], s[2]) and max(s[0], s[2]) <= x1 and y0 <= min(s[1], s[3]) and max(s[1], s[3]) <= y1:
            if s[4] in ('1-WINDOW', '1-DOOR', '4-WALL', '4-HATCH', '1-HATCH'): continue
            d.line([fn(s[0], s[1]), fn(s[2], s[3])], fill=(255, 0, 0), width=2)
    img.crop(crop).save(os.path.join(W, dst), quality=90)
s = 1500 / H
overlay('JESB_Lot20_v5_Elevation_Front.png', 'ov5_front.jpg', (-5040, -3940, -2280 + 120, -1850),
        lambda x, y: (1200 + (x + TX - CX) * s, 750 - (y + 2280 - CZ) * s), (250, 550, 1250, 950))
overlay('JESB_Lot20_v5_Elevation_Right.png', 'ov5_right.jpg', (-3580, -2440, -2280 + 120, -1850),
        lambda x, y: (1200 + ((x + 2773.4) + TY - CY) * s, 750 - (y + 2280 - CZ) * s), (250, 550, 1450, 950))
xc = -(CY - TY) - 6230.2
overlay('JESB_Lot20_v5_Elevation_Left.png', 'ov5_left.jpg', (-6560, -5420, -2280 + 120, -1850),
        lambda x, y: (1200 + (x - xc) * s, 750 - (y + 2280 - CZ) * s), (950, 550, 2250, 950))
st = 2400 / 1100.0
overlay('chk_top.png', 'ov5_top.jpg', (-4960, -4030, -730, 170),
        lambda x, y: (1200 + (x + TX - 12770) * st, 1200 - (y + TY - 3870) * st), (150, 1150, 1050, 2350))
print('ok')
