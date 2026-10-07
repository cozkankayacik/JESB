import sys
sys.path.insert(0, r"C:\Projects\DerbyEstates\tmp\python-libs")
import ezdxf
from ezdxf import bbox
from ezdxf.addons.drawing import Frontend, RenderContext, pymupdf, layout, config
from ezdxf.math import BoundingBox2d
w = sys.argv[1]
doc = ezdxf.readfile(w + r"\lot20.dxf"); msp = doc.modelspace()
# title positions on 1-NOTES / 1-TITLE to locate the four elevations
for e in msp.query("MTEXT TEXT"):
    t = (e.plain_text() if e.dxftype()=="MTEXT" else e.dxf.text).strip()
    if "ELEVATION" in t.upper() or "ROOF PLAN" in t.upper() or "SCALE" in t.upper():
        print("title", e.dxf.layer, round(e.dxf.insert.x), round(e.dxf.insert.y), t[:40])
regions = {"elev_a": (-6520, -2440, -3850, -1860), "elev_b": (-3900, -2440, -1280, -1860), "roof": (-5000, -760, -4000, 200), "plan1": (-4960, 480, -3690, 1450), "plan2": (-3760, 480, -2840, 1450), "found": (-6150, 480, -5230, 1450)}
cfg = config.Configuration(background_policy=config.BackgroundPolicy.WHITE, color_policy=config.ColorPolicy.BLACK, lineweight_policy=config.LineweightPolicy.ABSOLUTE, lineweight_scaling=0.6, hatch_policy=config.HatchPolicy.IGNORE)
for name, (x0, y0, x1, y1) in regions.items():
    ents = []
    for e in msp:
        try:
            b = bbox.extents([e], fast=True)
        except Exception:
            continue
        if not b.has_data: continue
        if b.extmax.x < x0 or b.extmin.x > x1 or b.extmax.y < y0 or b.extmin.y > y1: continue
        if b.size.x > (x1 - x0) * 1.5 or b.size.y > (y1 - y0) * 3: continue
        ents.append(e)
    backend = pymupdf.PyMuPdfBackend()
    Frontend(RenderContext(doc), backend, config=cfg).draw_entities(ents)
    wmm = 700 if name.startswith("elev") else 500
    page = layout.Page(wmm, 0, layout.Units.mm, margins=layout.Margins.all(5))
    png = backend.get_pixmap_bytes(page, fmt="png", dpi=96)
    open(w + "\\dwg_%s.png" % name, "wb").write(png)
    from PIL import Image
    Image.open(w + "\\dwg_%s.png" % name).convert("RGB").save(w + "\\dwg_%s.jpg" % name, quality=88)
    print(name, len(ents), "entities", len(png), "bytes")

