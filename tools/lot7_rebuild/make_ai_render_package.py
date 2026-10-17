"""Build the AI render input package for the Lot 7 exterior elevations.
For each elevation: the clean SketchUp elevation (geometry reference), one or two matching perspectives
(depth / hardscape reference, SketchUp header band cropped off) and a prompt file. Also copies the ACC Lot 7 finish
samples as material references.
Usage: python -I make_ai_render_package.py R10
Output: LOT7/04_Visualization/Working/AI_Render_Package_<rev>/
"""
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "tmp", "python-libs"))
import numpy as np
from PIL import Image

REV = sys.argv[1] if len(sys.argv) > 1 else "R10"
ROOT = r"C:\Projects\JESB\LOT7"
EXP = os.path.join(ROOT, "04_Visualization", "Exports", REV)
OUT = os.path.join(ROOT, "04_Visualization", "Working", f"AI_Render_Package_{REV}")
ACC = os.path.join(HERE, "textures", "acc_lot7")

BASE = f"""Create a premium photorealistic architectural elevation of JESB LOT 7 {REV} from the supplied SketchUp elevation (image 1). Treat the elevation as the geometry reference and the supplied perspective(s) as the depth and hardscape reference only. Preserve the exact building silhouette, roof forms, opening positions, window divisions, grouped headers, sills, trims, stairs, railings and terrain profile. Preserve all existing material assignments and their boundaries.

Target the visual finish of a carefully art-directed Corona Renderer architectural image: natural daylight, soft indirect illumination, restrained highlights, detailed contact shadows, realistic material roughness and correctly scaled textures. Keep white surfaces detailed and neutral.

Materials, exactly as assigned in the model (ACC Material Package, Lot 7, plus owner decisions):
- Main and wing roofs: Mission Brown asphalt architectural shingles (matte, laminated shingle texture). They are NOT metal.
- Accent roofs only (the small dark brown roofs with vertical seams): dark brown bronze standing-seam metal, seams running down the slope, restrained reflections.
- Walls: Magnolia brick (light cream / grey blend, fine mortar joints, real brick scale ~8 in x 2 2/3 in).
- Gable and upper wall siding: Cobble Stone horizontal lap siding (light greige, ~7 in exposure).
- Trims, fascia, soffit, frieze, window casings and the plain decorative panels: white. The plain white panels stay solid panels; never turn them into windows.
- Window and patio-door frames: white, with thin dark grid muntins exactly as drawn.
- Window and door headers: light beige cast stone, one continuous piece over each window group.
- Front door and garage doors: brown; garage doors are cottage style with a glass top row.
- Stair and terrace railings: black iron. Steps and terrace base: light concrete.
- Driveway: dark asphalt, footprint and grade as in the model.

Use only natural grass, the existing hardscape and a lightly clouded sky around the building. The flat dark green band below the grade line in the SketchUp elevation is the terrain section: render it as the lawn ground meeting the building exactly along the drawn grade line. Glass should show subtle sky reflections and believable depth, without invented furniture or vegetation reflections. Garage glazing must not reveal residential furnishings.

Maintain the source elevation projection (orthographic, straight-on, no perspective), straight verticals, complete building framing and crisp architectural detail. No redesigned geometry, additional materials, gutters or downspouts, trees, shrubs, people, vehicles, props, text, watermarks, exaggerated bloom or oversharpening. Match exposure, material appearance and presentation across all four elevations."""

VIEWS = [
    ("01_Front_West", "Elevation_Front_West", ["Perspective_Front_SW"],
     "Front (west) elevation: main entry with brown front door, side lights and transom, entry steps with black iron "
     "railings, tall stacked stair window, two-storey brick fronts with dark bronze standing-seam accent roofs, garage "
     "wing on the left with stacked white gables and lap siding, covered terrace with railing at the right end."),
    ("02_Right_South", "Elevation_Right_South", ["Perspective_Front_SW", "Perspective_Rear_SE"],
     "Right side (south) elevation: two brown garage doors with glass top row facing the asphalt driveway, two side "
     "stairs with black iron railings, dormer with four windows and a standing-seam roof, main hip roof with the small "
     "sided gablet, covered terrace with railing on a light concrete base. Perspective 1 shows the driveway and garage "
     "doors, perspective 2 the terrace."),
    ("03_Rear_East", "Elevation_Rear_East", ["Perspective_Rear_NE", "Perspective_Rear_SE"],
     "Rear (east) elevation: two-storey brick wall with grouped windows under continuous cast-stone headers on the "
     "first floor, covered terrace with railing on the left, main hip roof in shingles."),
    ("04_Left_North", "Elevation_Left_North", ["Perspective_Front_NW"],
     "Left side (north) elevation: brick walls, bay with three windows under a standing-seam accent roof, dormer with "
     "four windows above the garage wing roof, two lower-level windows near grade at the left, main hip roof in shingles."),
]

MATS = [
    "ACC_Lot7_Roof_Mission_Brown.png", "ACC_Lot7_Brick_Magnolia_USBrick.png", "ACC_Lot7_Siding_Cobble_Stone.png",
    "ACC_Lot7_Garage_Door_Style_Cottage_Glass_Top.png", "ACC_Lot7_Front_Door_Brown.png",
]


def crop_header(path, dst):
    """Drop the SketchUp grey header band at the top of the perspective exports."""
    im = Image.open(path).convert("RGB")
    a = np.asarray(im).astype(int)
    top = next((i for i in range(a.shape[0] // 3) if (a[i] >= 250).all()), 0)
    im.crop((0, top, im.width, im.height)).save(dst)


os.makedirs(OUT, exist_ok=True)
md = os.path.join(OUT, "00_Material_References")
os.makedirs(md, exist_ok=True)
for f in MATS:
    shutil.copy2(os.path.join(ACC, f), md)
shutil.copy2(os.path.join(HERE, "textures", "metal_standing_seam_dark_bronze.png"),
             os.path.join(md, "Owner_Metal_Roof_Standing_Seam_Dark_Brown_Bronze.png"))

for folder, elev, persps, note in VIEWS:
    d = os.path.join(OUT, folder)
    os.makedirs(d, exist_ok=True)
    shutil.copy2(os.path.join(EXP, f"JESB_Lot7_{REV}_{elev}.png"),
                 os.path.join(d, f"JESB_Lot7_{REV}_{folder}_1_Input_Elevation.png"))
    for i, p in enumerate(persps, 2):
        crop_header(os.path.join(EXP, f"JESB_Lot7_{REV}_{p}.png"),
                    os.path.join(d, f"JESB_Lot7_{REV}_{folder}_{i}_Reference_{p}.png"))
    refs = ", ".join(f"image {i} = {p.replace('_', ' ')}" for i, p in enumerate(persps, 2))
    text = f"{BASE}\n\nThis view - {note}\nAttached: image 1 = elevation (geometry, keep exactly); {refs} (depth and hardscape only, do not copy their camera). Optional finish swatches from 00_Material_References: brick, lap siding, shingle, standing-seam metal, doors (colour and texture only).\n"
    with open(os.path.join(d, f"JESB_Lot7_{REV}_{folder}_Prompt.txt"), "w", encoding="utf-8") as fh:
        fh.write(text)
    print("written", folder, len(persps) + 2, "files")
print("package", OUT)
