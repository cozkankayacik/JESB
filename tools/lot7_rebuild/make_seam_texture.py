"""Standing-seam metal roof texture, dark brown bronze (owner decision 2026-10-17).
One 16 in panel per tile, seams run along the texture v axis (= down the slope after align_texture).
Output: textures/metal_standing_seam_dark_bronze.png (512 x 512 px = 16 x 16 in).
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "tmp", "python-libs"))
import numpy as np
from PIL import Image

W = H = 512                      # 32 px per inch
BASE = np.array([74, 56, 42], float)
x = np.arange(W)
shade = np.zeros(W)
# flat pan: very soft cross-panel gradient and two faint stiffening ribs
shade += 0.04 * np.cos((x / W) * 2 * np.pi)
for rib in (W / 3, 2 * W / 3):
    shade += 0.05 * np.exp(-((x - rib) / 3.0) ** 2)
# seam at the tile edge (x = 0 / W): 1 in wide, lit flank then shadow flank
d = np.minimum(x, W - x)                        # px from the seam centre line
seam = d < 16
shade[seam] += 0.22 * np.cos(d[seam] / 16 * np.pi / 2)
shade[(x >= W - 22) & (x < W - 16)] -= 0.18      # shadow cast beside the seam
rng = np.random.default_rng(7)
img = np.empty((H, W, 3))
noise = rng.normal(0, 0.012, (H, W))
for c in range(3):
    img[:, :, c] = BASE[c] * (1 + shade[None, :] + noise)
out = os.path.join(os.path.dirname(__file__), "textures", "metal_standing_seam_dark_bronze.png")
Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(out)
print("written", out)
