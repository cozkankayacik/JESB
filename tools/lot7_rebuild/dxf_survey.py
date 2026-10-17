"""Survey the Lot 7 architect DXFs: entity types, layers, extents, texts, blocks.

Usage: python -I dxf_survey.py <dxf_dir> <out_dir>
Writes one <name>_survey.txt per DXF.
"""
import sys, os, collections
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import ezdxf
from ezdxf import bbox

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)

for fn in sorted(os.listdir(src)):
    if not fn.lower().endswith(".dxf"):
        continue
    doc = ezdxf.readfile(os.path.join(src, fn))
    msp = doc.modelspace()
    lines = [f"# {fn}", f"units {doc.header.get('$INSUNITS')}  version {doc.dxfversion}"]
    types = collections.Counter(e.dxftype() for e in msp)
    lines.append("## modelspace entity types")
    lines += [f"{k:20s} {v}" for k, v in types.most_common()]
    by_layer = collections.defaultdict(collections.Counter)
    for e in msp:
        by_layer[e.dxf.layer][e.dxftype()] += 1
    lines.append("## layers (entity counts)")
    for lay in sorted(by_layer):
        ext = bbox.extents(e for e in msp if e.dxf.layer == lay)
        box = f"x {ext.extmin.x:.0f}..{ext.extmax.x:.0f} y {ext.extmin.y:.0f}..{ext.extmax.y:.0f}" if ext.has_data else ""
        lines.append(f"{lay:35s} {sum(by_layer[lay].values()):6d}  {box}  {dict(by_layer[lay])}")
    lines.append("## inserts")
    ins = collections.Counter(e.dxf.name for e in msp.query("INSERT"))
    lines += [f"{k:40s} {v}" for k, v in ins.most_common()]
    lines.append("## texts (modelspace)")
    for e in msp.query("TEXT MTEXT"):
        t = e.plain_text() if e.dxftype() == "MTEXT" else e.dxf.text
        p = e.dxf.insert
        lines.append(f"{e.dxf.layer:25s} ({p.x:9.1f},{p.y:9.1f}) {t.replace(chr(10), ' | ')[:120]}")
    lines.append("## layouts")
    for lay in doc.layouts:
        lines.append(f"{lay.name}: {len(lay)} entities")
    with open(os.path.join(out, fn[:-4] + "_survey.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(fn, dict(types.most_common(8)))
