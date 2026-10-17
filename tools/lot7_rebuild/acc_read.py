"""Print the ACC Material Package rows for given columns (no openpyxl needed).

Usage: python -I acc_read.py <xlsx> <col> [<col> ...]
"""
import sys, zipfile, re

z = zipfile.ZipFile(sys.argv[1])
ss = [re.sub(r"<[^>]+>", "", s) for s in re.findall(r"<si>(.*?)</si>", z.read("xl/sharedStrings.xml").decode("utf8"), re.S)]
x = z.read("xl/worksheets/sheet1.xml").decode("utf8")
cells = {}
for m in re.finditer(r'<c r="([A-Z]+)(\d+)"([^>]*?)(?<!/)>(.*?)</c>', x, re.S):
    col, row, attrs, body = m.group(1), int(m.group(2)), m.group(3), m.group(4)
    v = re.search(r"<v>(.*?)</v>", body, re.S)
    if not v:
        continue
    val = ss[int(v.group(1))] if 't="s"' in attrs else v.group(1)
    cells[(col, row)] = val
for r in range(1, 40):
    vals = [(c, cells.get((c, r))) for c in ["A"] + sys.argv[2:]]
    if any(v for _, v in vals):
        print(r, " | ".join(f"{c}: {v}" for c, v in vals if v))
