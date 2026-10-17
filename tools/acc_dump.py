"""Dump the ACC Material Package workbook: every non-empty cell of every sheet, merged ranges, hyperlinks,
and the embedded images with their anchor cells (drawing XML).

Usage: python -I acc_dump.py <xlsx> <out_dir>
Writes <out_dir>/acc_cells.tsv, acc_images.tsv and the image files (named <sheet>_<cell>_<name>).
"""
import sys, os, re, zipfile, posixpath

xlsx, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
z = zipfile.ZipFile(xlsx)
names = z.namelist()
ss = [re.sub(r"<[^>]+>", "", s) for s in re.findall(r"<si>(.*?)</si>", z.read("xl/sharedStrings.xml").decode("utf8"), re.S)] \
    if "xl/sharedStrings.xml" in names else []
wb = z.read("xl/workbook.xml").decode("utf8")
rels = z.read("xl/_rels/workbook.xml.rels").decode("utf8")
rid2t = dict(re.findall(r'Id="(rId\d+)"[^>]*Target="([^"]+)"', rels)) | {a: b for b, a in re.findall(r'Target="([^"]+)"[^>]*Id="(rId\d+)"', rels)}
sheets = re.findall(r'<sheet [^>]*name="([^"]+)"[^>]*r:id="(rId\d+)"', wb)


def col2n(c):
    n = 0
    for ch in c:
        n = n * 26 + ord(ch) - 64
    return n


def n2col(n):
    s = ""
    while n:
        n, r = divmod(n - 1, 26)
        s = chr(65 + r) + s
    return s


cells_out, img_out = [], []
for sname, rid in sheets:
    path = "xl/" + rid2t[rid].lstrip("/").replace("xl/", "")
    x = z.read(path).decode("utf8")
    for m in re.finditer(r'<c r="([A-Z]+)(\d+)"([^>]*?)(?<!/)>(.*?)</c>', x, re.S):
        col, row, attrs, body = m.groups()
        v = re.search(r"<v>(.*?)</v>", body, re.S)
        isv = re.search(r"<is>(.*?)</is>", body, re.S)
        f = re.search(r"<f>(.*?)</f>", body, re.S)
        if v:
            val = ss[int(v.group(1))] if 't="s"' in attrs else v.group(1)
        elif isv:
            val = re.sub(r"<[^>]+>", "", isv.group(1))
        else:
            continue
        cells_out.append((sname, col + row, val.replace("\n", " | "), f.group(1) if f else ""))
    merges = re.findall(r'<mergeCell ref="([^"]+)"', x)
    cells_out.append((sname, "MERGED", " ".join(merges), ""))
    # hyperlinks
    srels_p = posixpath.join(posixpath.dirname(path), "_rels", posixpath.basename(path) + ".rels")
    srels = z.read(srels_p).decode("utf8") if srels_p in names else ""
    for ref, hrid in re.findall(r'<hyperlink ref="([^"]+)"[^>]*r:id="(rId\d+)"', x):
        t = re.search(r'Id="%s"[^>]*Target="([^"]+)"' % hrid, srels) or re.search(r'Target="([^"]+)"[^>]*Id="%s"' % hrid, srels)
        cells_out.append((sname, ref, "HYPERLINK " + (t.group(1) if t else "?"), ""))
    # drawings / images
    for drid in re.findall(r'<drawing r:id="(rId\d+)"', x):
        t = re.search(r'Id="%s"[^>]*Target="([^"]+)"' % drid, srels) or re.search(r'Target="([^"]+)"[^>]*Id="%s"' % drid, srels)
        dpath = posixpath.normpath(posixpath.join(posixpath.dirname(path), t.group(1)))
        dx = z.read(dpath).decode("utf8")
        drels_p = posixpath.join(posixpath.dirname(dpath), "_rels", posixpath.basename(dpath) + ".rels")
        drels = z.read(drels_p).decode("utf8")
        for anc in re.findall(r"<xdr:(?:twoCellAnchor|oneCellAnchor)[^>]*>(.*?)</xdr:(?:twoCellAnchor|oneCellAnchor)>", dx, re.S):
            fr = re.search(r"<xdr:from><xdr:col>(\d+)</xdr:col>.*?<xdr:row>(\d+)</xdr:row>", anc, re.S)
            to = re.search(r"<xdr:to><xdr:col>(\d+)</xdr:col>.*?<xdr:row>(\d+)</xdr:row>", anc, re.S)
            emb = re.search(r'r:embed="(rId\d+)"', anc)
            nm = re.search(r'<xdr:cNvPr [^>]*name="([^"]*)"', anc)
            if not (fr and emb):
                continue
            tt = re.search(r'Id="%s"[^>]*Target="([^"]+)"' % emb.group(1), drels) or re.search(r'Target="([^"]+)"[^>]*Id="%s"' % emb.group(1), drels)
            ipath = posixpath.normpath(posixpath.join(posixpath.dirname(dpath), tt.group(1)))
            cell = n2col(int(fr.group(1)) + 1) + str(int(fr.group(2)) + 1)
            cell2 = (n2col(int(to.group(1)) + 1) + str(int(to.group(2)) + 1)) if to else ""
            fn = "%s_%s_%s" % (sname, cell, posixpath.basename(ipath))
            open(os.path.join(out, fn), "wb").write(z.read(ipath))
            img_out.append((sname, cell, cell2, nm.group(1) if nm else "", ipath, fn))
with open(os.path.join(out, "acc_cells.tsv"), "w", encoding="utf8") as fh:
    for r in cells_out:
        fh.write("\t".join(r) + "\n")
with open(os.path.join(out, "acc_images.tsv"), "w", encoding="utf8") as fh:
    for r in img_out:
        fh.write("\t".join(r) + "\n")
print(len(cells_out), "cells,", len(img_out), "images")
