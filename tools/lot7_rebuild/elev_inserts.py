"""List block inserts of the elevation DXF with their world bounding boxes (window / door units).

Usage: python -I elev_inserts.py <xelev.dxf> <out.json>
"""
import sys, json, collections
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf
from ezdxf import bbox

doc = ezdxf.readfile(sys.argv[1])
out = []
for e in doc.modelspace().query("INSERT"):
    try:
        ext = bbox.extents(e.virtual_entities())
    except Exception:
        continue
    if not ext.has_data:
        continue
    layers = collections.Counter(v.dxf.layer for v in e.virtual_entities())
    out.append({"name": e.dxf.name, "layer": e.dxf.layer, "x0": round(ext.extmin.x, 2), "x1": round(ext.extmax.x, 2),
                "y0": round(ext.extmin.y, 2), "y1": round(ext.extmax.y, 2), "inner": dict(layers.most_common(3))})
json.dump(out, open(sys.argv[2], "w"), indent=0)
c = collections.Counter((o["name"], o["layer"]) for o in out)
for k, v in c.most_common():
    print(v, k)
