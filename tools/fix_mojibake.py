"""Repair UTF-8 text that was read as Windows-1252 and saved again as UTF-8 (e.g. 'â€”' -> '—').
Fixes line by line; lines that do not round-trip are left unchanged. Usage: python -I fix_mojibake.py <file> [...]
"""
import sys

for fn in sys.argv[1:]:
    raw = open(fn, "rb").read()
    bom = raw.startswith(b"\xef\xbb\xbf")
    text = raw.decode("utf-8-sig")
    out, fixed = [], 0
    for line in text.split("\n"):
        if any(m in line for m in ("â€", "Ã", "Â")):
            try:
                new = line.encode("cp1252").decode("utf-8")
                out.append(new); fixed += 1
                continue
            except (UnicodeEncodeError, UnicodeDecodeError):
                pass
        out.append(line)
    open(fn, "wb").write(("\n".join(out)).encode("utf-8"))
    print(fn, "lines fixed:", fixed, "(BOM removed)" if bom else "")
