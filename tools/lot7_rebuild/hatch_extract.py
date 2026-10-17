"""List HATCH entities of the elevation DXF: pattern name, layer, boundary polygons (DWG coords).

Usage: python -I hatch_extract.py <xelev.dxf> <out.json>
"""
import sys, json, collections
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf
from ezdxf import path as ezpath

doc = ezdxf.readfile(sys.argv[1])
out = []
cnt = collections.Counter()


def walk(ents, depth=0):
    for e in ents:
        if e.dxftype() == "HATCH":
            polys = []
            for p in ezpath.from_hatch(e):
                pts = [(round(v.x, 2), round(v.y, 2)) for v in p.flattening(0.5)]
                if len(pts) >= 3:
                    polys.append(pts)
            name = e.dxf.pattern_name
            cnt[(name, e.dxf.layer)] += 1
            out.append({"pattern": name, "layer": e.dxf.layer, "solid": bool(e.dxf.solid_fill), "polys": polys})
        elif e.dxftype() == "INSERT" and depth < 5:
            try:
                walk(list(e.virtual_entities()), depth + 1)
            except Exception:
                pass


walk(doc.modelspace())
json.dump(out, open(sys.argv[2], "w"))
for k, v in cnt.most_common():
    print(k, v)
