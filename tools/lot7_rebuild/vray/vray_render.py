"""Render the Lot 7 elevations with V-Ray standalone from the exported .vrscene (see vray_export.rb).
Steps per view: override materials / sun / exposure / sampling in a copy of the vrscene, render with vray.exe using
the SketchUp scene camera, then composite the alpha over the sky plate and crop below the terrain section.
Usage: python -I vray_render.py <vrscene> <out_dir> <rev> [width] [views comma list] [threshold]
"""
import math
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "..", "tmp", "python-libs"))
import numpy as np
from PIL import Image

VRAY = r"C:\Program Files\Chaos\V-Ray\V-Ray for SketchUp\extension\vray\bin"
SKY = os.path.join(HERE, "..", "textures", "sky_plate_elevation.png")
FULL_W, FULL_H = 3200, 1850
CROP_ROW = 1712          # bottom of the terrain section band (z = -100 in) at 3200 x 1850

src, out_dir, rev = sys.argv[1], sys.argv[2], sys.argv[3]
width = int(sys.argv[4]) if len(sys.argv) > 4 else FULL_W
views = sys.argv[5].split(",") if len(sys.argv) > 5 and sys.argv[5] else [
    "Elevation_Front_West", "Elevation_Right_South", "Elevation_Rear_East", "Elevation_Left_North"]
threshold = float(sys.argv[6]) if len(sys.argv) > 6 else 0.01
height = round(width * FULL_H / FULL_W)
MAX_MIN = float(sys.argv[7]) if len(sys.argv) > 7 else 0          # progressive time cap per view, minutes (0 = none)
work = os.path.dirname(src)
os.makedirs(out_dir, exist_ok=True)

SCENE = open(src, encoding="utf-8", errors="surrogateescape").read()


def block_span(text, name):
    m = re.search(r"(?m)^\w+ " + re.escape(name) + r" \{\n", text)
    if not m:
        raise KeyError(name)
    end = text.index("\n}", m.end())
    return m.end(), end


def setp(text, name, **params):
    """Set single-line parameters of plugin `name` (added when missing)."""
    a, b = block_span(text, name)
    body = text[a:b]
    for k, v in params.items():
        line = f"  {k}={v};"
        body, n = re.subn(r"(?m)^  " + re.escape(k) + r"=[^\n]*;$", lambda _m: line, body)
        if n == 0:
            body = body + "\n" + line
    return text[:a] + body + text[b:]


def acolor(r, g=None, b=None):
    g = r if g is None else g
    b = r if b is None else b
    return f"AColor({r}, {g}, {b}, 1)"


M = lambda n: f"_{n}_BRDFVRayMtl"
TEXN = lambda n: f"_{n}_BRDFVRayMtl_SUDiffuse"

BRICK = "ACC_Lot_7___Brick___Magnolia__US_Brick_"
SIDING = "ACC_Lot_7___Siding___Cobble_Stone"
SHINGLE = "ACC_Lot_7___Roof___Mission_Brown"
WHITES = ["ACC_Lot_7___Siding_Dec___White", "ACC_Lot_7___Trims___White",
          "ACC_Lot_7___Soffit_and_Fascia___White__LP_SmartSide_"]


def materials(t):
    # textured finishes: low glossy reflection + bump from their own colour map (mortar / shingle edges / laps)
    t = setp(t, M(BRICK), reflect=acolor(0.10), reflect_glossiness=0.42, bump_map=TEXN(BRICK), bump_amount=0.6)
    t = setp(t, M(SIDING), reflect=acolor(0.16), reflect_glossiness=0.55, bump_map=TEXN(SIDING), bump_amount=0.4)
    sw = "ACC_Lot_7___Siding_Dec___White___Terrace_Deck"           # R13: white lap siding on the terrace deck
    if re.search(r"(?m)^\w+ " + re.escape(M(sw)) + r" \{", t):
        t = setp(t, M(sw), reflect=acolor(0.2), reflect_glossiness=0.6, bump_map=TEXN(sw), bump_amount=0.4)
    t = setp(t, M(SHINGLE), reflect=acolor(0.10), reflect_glossiness=0.45, bump_map=TEXN(SHINGLE), bump_amount=0.7)
    t = setp(t, M("Terrain___Lawn"), reflect=acolor(0.04), reflect_glossiness=0.3,
             bump_map=TEXN("Terrain___Lawn"), bump_amount=0.8)
    t = setp(t, M("Terrain___Section"), reflect=acolor(0.04), reflect_glossiness=0.3,
             bump_map=TEXN("Terrain___Section"), bump_amount=0.8)
    # painted whites: neutral, below 0.8 albedo so they keep detail in sun
    for n in WHITES:
        t = setp(t, M(n), diffuse=acolor(0.74, 0.74, 0.72), reflect=acolor(0.22), reflect_glossiness=0.62)
    t = setp(t, M("ACC_Lot_7___Windows_and_Patio_Doors___White"), diffuse=acolor(0.72, 0.71, 0.70),
             reflect=acolor(0.3), reflect_glossiness=0.7)
    t = setp(t, M("Owner___Cast_Stone_Window_Header___Light_Beige"), diffuse=acolor(0.56, 0.52, 0.44),
             reflect=acolor(0.06), reflect_glossiness=0.35)
    for n in ["ACC_Lot_7___Front_Door___Brown", "ACC_Lot_7___Garage_Door___Brown_groove"]:
        t = setp(t, M(n), reflect=acolor(0.25), reflect_glossiness=0.62)
    t = setp(t, "_ACC_Lot_7___Garage_Door___Brown__Cottage__glass_on_top__VRay_Mtl",
             reflect=acolor(0.25), reflect_glossiness=0.62)
    t = setp(t, M("Not_in_ACC___Railing___Black_Iron"), reflect=acolor(0.3), reflect_glossiness=0.58)
    t = setp(t, M("Concrete"), diffuse=acolor(0.46, 0.45, 0.42), reflect=acolor(0.05), reflect_glossiness=0.35)
    t = setp(t, M("Asphalt"), reflect=acolor(0.06), reflect_glossiness=0.35)
    t = setp(t, M("Interior___Dark"), diffuse=acolor(0.025))
    # dark brown bronze standing seam: metal, restrained (fairly rough) reflections
    t = setp(t, "_Owner___Metal_Roof___Standing_Seam___Dark_Brown_Bronze_VRay_Mtl", metalness=1,
             reflect=acolor(1), reflect_glossiness=0.62)
    # glass: clear, thin walled, fresnel reflections of the sky
    t = setp(t, "_Glass_VRay_Mtl", diffuse=acolor(0), reflect=acolor(1), reflect_glossiness=1, fresnel=1,
             fresnel_ior=1.52, fresnel_ior_lock=0, refract=acolor(0.55), refract_ior=1.52, refract_glossiness=1,
             refract_thin_walled=1, refract_affect_shadows=1)
    return t


def sun_transform(view_name, t):
    """Sun 40 deg up, 35 deg to the viewer's left of the facade normal (same light on every elevation)."""
    a, b = block_span(t, "_RenderView_" + view_name)
    m = re.search(r"transform=Transform\(Matrix\(Vector\(([^)]*)\), Vector\(([^)]*)\), Vector\(([^)]*)\)\)", t[a:b])
    right = np.array([float(v) for v in m.group(1).split(",")])
    back = np.array([float(v) for v in m.group(3).split(",")])          # camera +Z = towards the viewer
    n = back / np.linalg.norm(back)
    az, alt = math.radians(35), math.radians(40)
    h = math.cos(az) * n - math.sin(az) * right
    z = math.cos(alt) * h + math.sin(alt) * np.array([0, 0, 1.0])
    z /= np.linalg.norm(z)
    x = np.cross([0, 0, 1.0], z); x /= np.linalg.norm(x)
    y = np.cross(z, x)
    f = lambda v: ", ".join(f"{c:.6f}" for c in v)
    p = z * 1000
    return f"Transform(Matrix(Vector({f(x)}), Vector({f(y)}), Vector({f(z)})), Vector({f(p)}))"


CAMERA = dict(exposure=1, ISO=100, f_number=11, shutter_speed=125, white_balance="Color(1, 0.92, 0.82)", vignetting=0)


def settings(t):
    t = setp(t, "_CameraPhysical", **CAMERA)
    t = setp(t, "_SettingsColorMapping", type=6, bright_mult=0.8, dark_mult=1, gamma=2.2, affect_background=0)
    t = setp(t, "_SettingsImageSampler", type=3, progressive_minSubdivs=1, progressive_maxSubdivs=60,
             progressive_threshold=threshold, progressive_maxTime=MAX_MIN)
    t = setp(t, "_SettingsOutput", img_width=width, img_height=height, bmp_width=width, bmp_height=height,
             rgn_width=width, rgn_height=height, r_width=width, r_height=height, img_noAlpha=0)
    t = setp(t, "_SettingsEnvironment", gi_tex_mult=0.8)
    t = setp(t, "_SettingsGI", on=1, primary_engine=2, secondary_engine=3, ao_on=1, ao_amount=0.6, ao_radius=10, ao_subdivs=8)
    t = setp(t, "_SunLight", intensity_multiplier=1, size_multiplier=2.5, clouds_on=0, turbidity=2.8)
    return t


base = settings(materials(SCENE))
sky_full = Image.open(SKY).convert("RGB")
for v in views:
    scene_name = v.replace("_", " ")
    t = setp(base, "_SunLight", transform=sun_transform(v, base))
    # vray.exe reads orthographicWidth as twice the width V-Ray for SketchUp means (measured: building at half size)
    a, b = block_span(t, "_RenderView_" + v)
    ow = float(re.search(r"orthographicWidth=([\d.]+);", t[a:b]).group(1))
    t = setp(t, "_RenderView_" + v, orthographicWidth=f"{ow / 2:.6f}")
    # -camera uses the scene's own CameraPhysical: give it the same exposure settings
    t = setp(t, "_CameraPhysical_" + v, **CAMERA)
    vrs = os.path.join(work, f"render_{v}.vrscene")
    with open(vrs, "w", encoding="utf-8", errors="surrogateescape") as fh:
        fh.write(t)
    raw = os.path.join(work, f"raw_{v}.png")
    env = dict(os.environ, VRAY_PLUGINS=os.path.join(VRAY, "plugins"))
    cmd = [os.path.join(VRAY, "vray.exe"), f"-sceneFile={vrs}", f"-imgFile={raw}", "-display=0", "-autoClose=1",
           f"-imgWidth={width}", f"-imgHeight={height}", f"-camera={scene_name}", "-verboseLevel=1"]
    print("render", v, width, "x", height, flush=True)
    r = subprocess.run(cmd, env=env, capture_output=True, text=True, errors="replace")
    if r.returncode != 0:
        print(r.stdout[-3000:], r.stderr[-2000:])
        raise SystemExit(f"vray failed on {v}")
    den = raw.replace(".png", ".denoiser.png")
    rgba = Image.open(den if os.path.exists(den) else raw).convert("RGBA")
    alpha = Image.open(raw).convert("RGBA").getchannel("A")          # alpha from the raw beauty pass
    sky = sky_full.resize((width, height), Image.LANCZOS)
    comp = Image.composite(rgba.convert("RGB"), sky, alpha)
    crop = round(CROP_ROW * width / FULL_W)
    comp = comp.crop((0, 0, width, crop))
    # gentle print contrast around mid grey (no sharpening, no bloom)
    arr = np.asarray(comp, float) / 255.0
    arr = np.clip(0.5 + (arr - 0.5) * 1.06, 0, 1)
    comp = Image.fromarray((arr * 255 + 0.5).astype(np.uint8))
    name = f"JESB_Lot7_{rev}_Render_{v}.png"
    comp.save(os.path.join(out_dir, name))
    print("written", name, flush=True)
