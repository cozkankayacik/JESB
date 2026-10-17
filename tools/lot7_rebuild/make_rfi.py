"""RFI 001 to the architect: differences between the xelev elevation drawings and the Lot 7 exterior model R10.
Evidence = crops of the model's QA overlays (model export with the architect's xelev lines in red).
Writes the Projades A3 PDF and a Markdown copy of the RFI text.
Usage: python -I make_rfi.py
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "tmp", "python-libs"))
import numpy as np
import pymupdf
from PIL import Image, ImageDraw, ImageFilter, ImageFont

LOT = r"C:\Projects\JESB\LOT7"
QA = os.path.join(LOT, r"04_Visualization\Exports\R10\QA_Overlay_vs_Architect_DWG\JESB_Lot7_R10_Elevation_{}_vs_DWG.png")
OUT_PDF = os.path.join(LOT, r"05_Presentations_and_Issued\RFI\PROJADES_JESB_Lot7_RFI-001_Elevations_vs_Model_2026-10-17.pdf")
OUT_MD = os.path.join(LOT, r"00_Project_Admin\RFI\JESB_Lot7_RFI-001_Elevations_vs_Model_2026-10-17.md")
CROPS = os.path.join(LOT, r"00_Project_Admin\RFI\RFI-001_Evidence")
DATE = "17.10.2026"
RFI = "RFI-001"

W, H = 1190.551, 841.890
DARK = (0x17 / 255, 0x33 / 255, 0x2F / 255)
GREY = (0x66 / 255, 0x73 / 255, 0x6F / 255)
ACCENT = (0xB1 / 255, 0x66 / 255, 0x3C / 255)
TEAL = (0x27 / 255, 0x76 / 255, 0x6E / 255)
F_REG = r"C:\Windows\Fonts\arial.ttf"
F_BOLD = r"C:\Windows\Fonts\arialbd.ttf"
ASC = 0.905

# ------------------------------------------------------------------------------------------------ items
# crop boxes are in the 3200 x 1850 export frame (2.984 px per inch)
ITEMS = [
    dict(no="01", view="Left (north) elevation – A-310", subject="Garage wing, west (front) end",
         crops=[("Left_North", (2560, 650, 3080, 1620), "North elevation, west end of the garage wing")],
         drawing="The north elevation draws the garage front wall and eave about 18–22 in further west than the model.",
         model="The model follows the re-issued first floor plan (xflr1, 16.10.2026), which moves the garage front 9.36 in back. "
               "The elevations, the second floor plan and the roof plan were not re-issued and still show the old position.",
         question="Please confirm the garage front position of xflr1 (moved back 9.36 in) and re-issue the elevations and "
                  "A-220 to match. The north elevation differs by about 10 in more than the 9.36 in shift. Please also "
                  "check its garage-end dimension.",
         short="Garage front: north elev. ~18–22 in west of model / xflr1"),
    dict(no="02", view="Right side (south) elevation – A-300", subject="Garage wing, west (front) end",
         crops=[("Right_South", (130, 650, 720, 1620), "South elevation, west end of the garage wing")],
         drawing="The south elevation draws the garage front wall about 9–16 in further west than the model. The eave and "
                 "the lower front gable are also further out.",
         model="As item 01: the model follows xflr1, with the garage front moved back 9.36 in.",
         question="Same as item 01. The south (≈9–16 in) and north (≈18–22 in) elevations disagree with each other. Please "
                  "confirm which garage-end position governs.",
         short="Garage front: south elev. ~9–16 in west of model / xflr1"),
    dict(no="03", view="Rear (east) elevation – A-310", subject="Main hip roof, ridge length / end-hip pitch",
         crops=[("Rear_East", (650, 230, 2800, 760), "Rear elevation: red ridge ≈131 in long"),
                ("Front_West", (380, 230, 2530, 760), "Front elevation: red ridge ≈311 in, matching the model")],
         drawing="The rear elevation draws a ridge only about 131 in long. The end hips appear at about 6:12.",
         model="The model follows A-220 and the front elevation: ridge about 309 in long, end hips 9:12. The front "
               "elevation and the A-220 overlay both match the model.",
         question="Is the rear elevation roof outline an error? Please confirm the ridge length and the end-hip pitch, or "
                  "revise A-220 and the front elevation if the rear elevation governs.",
         short="Main ridge: rear elev. ≈131 in vs front elev. / A-220 ≈309 in"),
    dict(no="04", view="South (A-300) and rear (A-310) elevations; A-220", subject="Covered terrace hip roof pitch",
         crops=[("Right_South", (1900, 780, 3000, 1300), "South elevation, covered terrace roof"),
                ("Rear_East", (300, 820, 900, 1300), "Rear elevation, covered terrace roof")],
         drawing="Both elevations draw the terrace roof apex about 10–13 in higher than the model. That is ≈6:12 or "
                 "slightly steeper, consistent with the 6:12 note on A-220. The eave height matches.",
         model="The terrace roof is 0.44 (≈5.3:12) with the eave at 112.37 in above the main floor. In R01 the "
               "elevations were read as ≈5:12.",
         question="Please confirm the terrace roof pitch. We propose 6:12 per A-220 and will revise the model on "
                  "confirmation.",
         short="Terrace roof: model ≈5.3:12, drawings ≈6:12"),
    dict(no="05", view="Right side (south) elevation – A-300", subject="Terrace sliding door head height",
         crops=[("Right_South", (2180, 1040, 2620, 1460), "South elevation, terrace slider")],
         drawing="Slider head at about 84 in (7'-0\") above the main floor.",
         model="The model has the slider 72 in wide, 0–96 in (8'-0\") high. It was modelled by hand in R01 with no "
               "schedule height. Width and position match the drawing.",
         question="Please confirm the slider size: height 6'-8\"/7'-0\" per the elevation, or 8'-0\". A door schedule "
                  "entry would close this item.",
         short="Terrace slider: model 8'-0\" high, elev. ≈7'-0\""),
    dict(no="06", view="Right side (south) elevation – A-300", subject="Second floor window at the east end",
         crops=[("Right_South", (2560, 640, 3080, 1020), "South elevation, upper east window")],
         drawing="The window is drawn about 5–8 in further east and about 3 in narrower than the model.",
         model="Position and width are taken from the second floor plan opening (72 in wide, sill 156.6 in, head "
               "228.6 in).",
         question="Plan and elevation disagree. Please confirm the window size and its position from the east corner.",
         short="South upper east window: ≈5–8 in shift, ≈3 in width"),
    dict(no="07", view="Left (north) elevation – A-310", subject="Guest bedroom bay, three windows",
         crops=[("Left_North", (1130, 860, 1820, 1420), "North elevation, guest bedroom bay")],
         drawing="Three windows about 29–30 in wide.",
         model="Three windows 36 in wide, from the first floor plan.",
         question="Please confirm the bay window width: 30 in per the elevation or 36 in per the plan.",
         short="Guest bay windows: plan 36 in vs elevation 30 in"),
    dict(no="08", view="Front (west) elevation – A-300", subject="Small window in the wing front gable",
         crops=[("Front_West", (720, 560, 1100, 820), "Front elevation, wing gable window")],
         drawing="Window drawn at x 138–162: about 13 in further right (south) than the plan.",
         model="Window at x 125–149 (24 x 32 in), from the second floor plan.",
         question="Please confirm the window position in the gable: plan or elevation.",
         short="Wing gable window: ≈13 in plan/elevation offset"),
    dict(no="09", view="Front (west) elevation – A-300", subject="Front entry door leaf style",
         crops=[("Front_West", (1520, 1040, 1860, 1470), "Front elevation, entry door")],
         drawing="Six-panel door leaf with sidelights and transom.",
         model="The frame, sidelights and transom match. The leaf is a flat brown placeholder in ACC Lot 7 Front Door – "
               "Brown.",
         question="Please confirm the door model and panel style, or a product reference, so the leaf can be modelled "
                  "as specified.",
         short="Entry door: confirm leaf / panel style"),
]


# ------------------------------------------------------------------------------------------------ evidence crops
def evidence(view, box, name):
    im = Image.open(QA.format(view)).convert("RGB")
    a = np.asarray(im).copy()
    red = (a[:, :, 0] > 200) & (a[:, :, 1] < 40) & (a[:, :, 2] < 40)
    m = np.asarray(Image.fromarray((red * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(3))) > 0
    a[m] = [230, 0, 0]
    im = Image.fromarray(a).crop(box)
    if im.width < 900:
        s = 900 / im.width
        im = im.resize((900, round(im.height * s)), Image.LANCZOS)
    path = os.path.join(CROPS, name + ".png")
    im.save(path)
    return path


# ------------------------------------------------------------------------------------------------ pdf
def text(page, x, top, s, size, bold=False, color=DARK):
    page.insert_text((x, top + size * ASC), s, fontsize=size, fontname="ArialB" if bold else "Arial",
                     fontfile=F_BOLD if bold else F_REG, color=color)


def para(page, rect, s, size=9.5, bold=False, color=DARK):
    """Wrapped paragraph; returns the y below it."""
    font = pymupdf.Font(fontfile=F_BOLD if bold else F_REG)
    words, lines, line = s.split(), [], ""
    for wd in words:
        t = (line + " " + wd).strip()
        if font.text_length(t, size) > rect.width:
            lines.append(line); line = wd
        else:
            line = t
    if line:
        lines.append(line)
    y = rect.y0
    for ln in lines:
        text(page, rect.x0, y, ln, size, bold, color); y += size * 1.32
    return y


def frame(page, title, subtitle, sheet):
    page.draw_rect(pymupdf.Rect(28, 28, W - 28, H - 28), color=DARK, width=0.65)
    page.draw_line((28, 746.9), (W - 28, 746.9), color=DARK, width=0.65)
    for x in (276, 718, 900, 1038):
        page.draw_line((x, 746.9), (x, H - 28), color=DARK, width=0.65)
    text(page, 44, 47.2, title, 23, True)
    text(page, 44, 79.5, subtitle, 11, False, GREY)
    text(page, 44, 763.0, "PROJADES", 23, True)
    text(page, 44, 794.1, "ARCHITECTURE / DESIGN STUDY", 7.5, False, GREY)
    text(page, 292, 759.6, "JADE ESTATES - LOT 7", 12, True)
    text(page, 292, 779.1, "South Barrington, Illinois", 10)
    text(page, 292, 796.7, "REQUEST FOR INFORMATION - TO PUROHIT ARCHITECTS, INC.", 8, False, ACCENT)
    text(page, 734, 761.1, RFI, 10, True)
    text(page, 734, 780.9, "A3 / 420 x 297 mm", 9)
    text(page, 734, 797.7, "MODEL R10 vs xelev", 8)
    text(page, 916, 761.1, DATE, 10)
    text(page, 916, 782.9, "RESPONSE REQUESTED", 9)
    text(page, 1052, 761.0, sheet, 14, True)
    text(page, 1052, 791.7, "PROJADES", 8)


def place(page, path, rect):
    iw, ih = Image.open(path).size
    s = min(rect.width / iw, rect.height / ih)
    w, h = iw * s, ih * s
    r = pymupdf.Rect(rect.x0 + (rect.width - w) / 2, rect.y0, rect.x0 + (rect.width + w) / 2, rect.y0 + h)
    page.insert_image(r, filename=path)
    page.draw_rect(r, color=GREY, width=0.4)
    return r


os.makedirs(os.path.dirname(OUT_PDF), exist_ok=True)
os.makedirs(CROPS, exist_ok=True)
doc = pymupdf.open()

# cover / summary
page = doc.new_page(width=W, height=H)
frame(page, f"{RFI}  Elevation drawings vs exterior model", "Jade Estates Lot 7 - project no. 202601.LOT 7", "RFI-00")
y = 112
for k, v in [("To", "Purohit Architects, Inc."), ("From", "Projades"), ("Date", DATE), ("Subject",
             "Differences between the elevation drawings (xelev) and the exterior model R10")]:
    text(page, 44, y, k, 9.5, True); text(page, 120, y, v, 9.5); y += 15
y += 6
y = para(page, pymupdf.Rect(44, y, 1146, y + 60),
         "Projades built the Lot 7 exterior model R10 from the architect's DWG files of 16.10.2026: xelev, xflr0, xflr1 "
         "and xflr2 (lot 7G). It also used the architectural set Revision 1 of 15.10.2026, including A-220. We overlaid "
         "the xelev elevation lines on the model elevations at 1:1. The nine items below are places where the "
         "drawings disagree with the model or with each other. The model has not been changed. Please answer each "
         "item, and re-issue the affected drawings where needed.") + 10
cols = [44, 84, 330, 560, 1146]
heads = ["No.", "Location / sheet", "Subject", "Difference"]
page.draw_rect(pymupdf.Rect(44, y - 3, 1146, y + 15), color=None, fill=(0.93, 0.95, 0.94))
for c, h in zip(cols, heads):
    text(page, c + 4, y, h, 9, True)
y += 20
for it in ITEMS:
    text(page, cols[0] + 4, y, it["no"], 9, True)
    text(page, cols[1] + 4, y, it["view"], 8.5)
    text(page, cols[2] + 4, y, it["subject"], 8.5)
    text(page, cols[3] + 4, y, it["short"], 8.5)
    y += 14
    page.draw_line((44, y - 3), (1146, y - 3), color=(0.8, 0.83, 0.82), width=0.4)
y += 14
for n in ["Evidence: the model's elevation exports with the xelev lines in red at 1:1 (2.984 px per inch). "
          "Measurements are taken from the overlays and are approximate (±1 in).",
          "Already-open items carried from model R01 (items 01/02, 07 and 08) are repeated here so that everything "
          "can be answered in one place.",
          "Not covered here: the site and grading plan is still missing, and the terrain and driveway in the model "
          "are assumed. That is a separate request."]:
    y = para(page, pymupdf.Rect(44, y, 1146, y + 40), "- " + n, 8.5, False, GREY) + 3

# one page per item
md = [f"# JESB Lot 7 – {RFI}: Elevation drawings vs exterior model R10", "",
      f"To: Purohit Architects, Inc. (project no. 202601.LOT 7)  ", "From: Projades  ", f"Date: {DATE}", "",
      "We overlaid the xelev elevation lines on the model elevations at 1:1. The model has not been changed. "
      "Please answer each item.", "",
      "| No. | Location / sheet | Subject | Difference |", "|---|---|---|---|"]
md += [f"| {it['no']} | {it['view']} | {it['subject']} | {it['short']} |" for it in ITEMS]
md.append("")
for it in ITEMS:
    page = doc.new_page(width=W, height=H)
    frame(page, f"{RFI}.{it['no']}  {it['subject']}", it["view"], f"RFI-{it['no']}")
    paths = [evidence(v, box, f"{RFI}_{it['no']}_{i + 1}_{v}") for i, (v, box, cap) in enumerate(it["crops"])]
    area = pymupdf.Rect(44, 104, 790, 728)
    n = len(paths)
    gap = 26
    hh = (area.height - gap * (n - 1)) / n
    for i, (p, (v, box, cap)) in enumerate(zip(paths, it["crops"])):
        r = place(page, p, pymupdf.Rect(area.x0, area.y0 + i * (hh + gap), area.x1, area.y0 + i * (hh + gap) + hh - 14))
        text(page, r.x0, r.y1 + 3, cap, 8, True, TEAL)
    x0, x1 = 816, 1146
    y = 108
    page.draw_line((x0, 104), (x0, 728), color=(0.8, 0.83, 0.82), width=0.4)
    x0 += 14
    for head, key, col in [("DRAWINGS (xelev)", "drawing", DARK), ("MODEL R10", "model", DARK),
                           ("QUESTION", "question", ACCENT)]:
        text(page, x0, y, head, 9, True, TEAL if key != "question" else ACCENT); y += 14
        y = para(page, pymupdf.Rect(x0, y, x1, y + 200), it[key], 9.5, key == "question") + 12
    text(page, x0, y, "LEGEND", 9, True, TEAL); y += 14
    page.draw_line((x0, y + 5), (x0 + 24, y + 5), color=(0.9, 0, 0), width=1.6)
    text(page, x0 + 30, y, "Architect's xelev lines (1:1)", 8.5); y += 14
    text(page, x0 + 30, y, "Image: model R10 elevation export", 8.5); y += 26
    text(page, x0, y, "ARCHITECT'S RESPONSE", 9, True, TEAL); y += 14
    page.draw_rect(pymupdf.Rect(x0, y, x1, min(y + 150, 728)), color=GREY, width=0.5)
    md += [f"## {it['no']}. {it['subject']} – {it['view']}", "",
           f"**Drawings (xelev):** {it['drawing']}", "", f"**Model R10:** {it['model']}", "",
           f"**Question:** {it['question']}", "",
           "Evidence: " + ", ".join(f"`RFI-001_Evidence/{os.path.basename(p)}`" for p in paths), "",
           "**Architect's response:** ", ""]
doc.save(OUT_PDF, garbage=3, deflate=True)
with open(OUT_MD, "w", encoding="utf-8") as fh:
    fh.write("\n".join(md))
print("written", OUT_PDF, len(doc), "pages")
print("written", OUT_MD)
