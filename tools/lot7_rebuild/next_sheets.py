"""Derive the sheet list of a new revision from the previous one.
Usage: python -I next_sheets.py <prev.json> <out.json> <prev_rev> <new_rev> "<note>" [roofplan]
'roofplan' adds sheet A-902 (model roof plan over A-220) if missing.
"""
import sys, json

src, dst, a, b, note = sys.argv[1:6]
s = open(src, encoding="utf-8-sig").read()
s = s.replace('"revision": "%s"' % a, '"revision": "%s"' % b).replace("/%s/" % a, "/%s/" % b) \
     .replace("JESB_Lot7_%s_" % a, "JESB_Lot7_%s_" % b).replace("EXTERIOR MODEL %s" % a, "EXTERIOR MODEL %s" % b) \
     .replace("SketchUp model %s" % a, "SketchUp model %s" % b) \
     .replace("JESB_Lot7_Model_%s_Change_Log.md" % a, "JESB_Lot7_Model_%s_Change_Log.md" % b)
spec = json.loads(s)
cover = spec["sheets"][0]
notes = cover["notes"]
i = next(k for k, n in enumerate(notes) if n.startswith("Open items"))
notes.insert(i, note)
if len(sys.argv) > 6 and sys.argv[6] == "roofplan" and not any(sh["no"] == "A-902" for sh in spec["sheets"]):
    cover["index"].append(["A-902", "QA - model roof plan over A-220 (red)"])
    spec["sheets"].append({"no": "A-902", "title": "QA - MODEL ROOF PLAN OVER A-220",
                           "subtitle": "Red: A-220 roof plan (Revision 1) placed on the model top view", "layout": "single",
                           "images": ["C:/Projects/JESB/LOT7/04_Visualization/Exports/%s/QA_Overlay_vs_Architect_DWG/JESB_Lot7_%s_Roof_Plan_vs_A-220.png" % (b, b)]})
json.dump(spec, open(dst, "w", encoding="utf-8"), indent=1)
print("written", dst, len(spec["sheets"]), "sheets")
