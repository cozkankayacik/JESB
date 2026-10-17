"""Render support images for the V-Ray elevations:
- textures/grass_lawn.png: seamless lawn texture (1024 px = 60 in), used on the lawn and the terrain section band
- textures/sky_plate_elevation.png: lightly clouded daylight sky, composited behind the orthographic elevations
  (an orthographic camera sees the sky as one flat colour, so the background is a plate)
Usage: python -I make_render_plates.py
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "..", "tmp", "python-libs"))
import numpy as np
from PIL import Image, ImageFilter

TEX = os.path.join(HERE, "..", "textures")
rng = np.random.default_rng(11)


def noise(h, w, cell, wrap=True):
    """Smooth value noise: random grid upsampled bicubically (tileable when wrap)."""
    gh, gw = max(2, h // cell), max(2, w // cell)
    g = rng.random((gh, gw))
    if wrap:
        g = np.pad(g, ((0, 1), (0, 1)), mode="wrap")
        im = Image.fromarray((g * 255).astype(np.uint8)).resize((w + w // gw, h + h // gh), Image.BICUBIC)
        return np.asarray(im, float)[:h, :w] / 255.0
    im = Image.fromarray((g * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
    return np.asarray(im, float) / 255.0


def fbm(h, w, cells, weights, wrap=True):
    out = sum(wt * noise(h, w, c, wrap) for c, wt in zip(cells, weights))
    return out / sum(weights)


# ---------------------------------------------------------------- grass
N = 1024
base = np.array([74, 94, 54], float)
n1 = fbm(N, N, [256, 64, 16], [0.5, 0.3, 0.2])
blades = np.asarray(Image.fromarray((rng.random((N, N)) * 255).astype(np.uint8)).resize((N, N)), float) / 255
blades = np.asarray(Image.fromarray((blades * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.6)), float) / 255
shade = 0.78 + 0.35 * (n1 - 0.5) + 0.45 * (blades - 0.5)
hue = fbm(N, N, [128, 32], [0.6, 0.4]) - 0.5                       # yellow-green / blue-green variation
img = np.stack([base[0] * shade * (1 + 0.25 * hue), base[1] * shade, base[2] * shade * (1 - 0.2 * hue)], -1)
Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(os.path.join(TEX, "grass_lawn.png"))

# ---------------------------------------------------------------- sky plate
W, H = 3200, 1850
y = np.linspace(0, 1, H)[:, None]
top = np.array([96, 140, 196], float)
hor = np.array([214, 226, 236], float)
t = y ** 0.85
sky = top[None, None, :] * (1 - t[..., None]) + hor[None, None, :] * t[..., None]
sky = np.broadcast_to(sky, (H, W, 3)).copy()
# light clouds: wide soft fbm, kept to the upper sky and thinned towards the horizon, flattened vertically
c = fbm(H, W // 2, [420, 180, 70, 24], [0.45, 0.3, 0.17, 0.08], wrap=False)
c = np.asarray(Image.fromarray((c * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC), float) / 255
cov = np.clip((c - 0.56) / 0.2, 0, 1) ** 1.6
cov *= np.clip(1.15 - y * 1.25, 0, 1)
cov = np.asarray(Image.fromarray((cov * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(6)), float) / 255
under = fbm(H, W, [90, 30], [0.6, 0.4], wrap=False)
cloud = np.array([246, 247, 248], float)[None, None, :] * (0.93 + 0.07 * under[..., None])
sky = sky * (1 - 0.85 * cov[..., None]) + cloud * (0.85 * cov[..., None])
Image.fromarray(np.clip(sky, 0, 255).astype(np.uint8)).save(os.path.join(TEX, "sky_plate_elevation.png"))
print("written grass_lawn.png, sky_plate_elevation.png")
