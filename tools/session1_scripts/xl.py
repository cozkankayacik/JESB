import sys, os
import openpyxl
out = sys.argv[1]
wb = openpyxl.load_workbook(r"C:\Projects\JESB\ACC MATERIAL PACKAGE.xlsx")
for ws in wb.worksheets:
    print("=== SHEET", repr(ws.title), ws.dimensions, "state=", ws.sheet_state, "images=", len(getattr(ws, "_images", [])), "merged=", len(ws.merged_cells.ranges))
    for row in ws.iter_rows():
        for c in row:
            if c.value is not None and str(c.value).strip() != "":
                print("  %s: %s" % (c.coordinate, str(c.value).replace("\n", " / ")[:300]))
    for i, im in enumerate(getattr(ws, "_images", [])):
        a = im.anchor._from
        name = "%s_%02d_r%dc%d.%s" % ("".join(ch if ch.isalnum() else "_" for ch in ws.title)[:20], i, a.row + 1, a.col + 1, (im.format or "png").lower())
        data = im._data()
        open(os.path.join(out, name), "wb").write(data)
        print("  IMG %s anchor row %d col %d  %dx%d  %d bytes" % (name, a.row + 1, a.col + 1, im.width, im.height, len(data)))
