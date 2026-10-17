"""White lap siding texture for the covered terrace deck (owner 2026-10-17: "siding deck white" = ACC Lot 7 Siding Dec
- White). Made from the ACC Cobble Stone lap siding sample: same laps and shading, recoloured to the ACC white
(246, 248, 248) so the board scale matches the siding on the house.
Output: textures/acc_lot7/ACC_Lot7_Siding_Dec_White_Lap.png
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "tmp", "python-libs"))
import numpy as np
from PIL import Image

src = os.path.join(HERE, "textures", "acc_lot7", "ACC_Lot7_Siding_Cobble_Stone.png")
out = os.path.join(HERE, "textures", "acc_lot7", "ACC_Lot7_Siding_Dec_White_Lap.png")
g = np.asarray(Image.open(src).convert("L"), float)
rel = g / g.mean()                                   # lap shadows / grain relative to the mean tone
white = np.array([246, 248, 248], float)
img = white[None, None, :] * (1 + 0.6 * (rel[..., None] - 1))
Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(out)
print("written", out, img.shape)
