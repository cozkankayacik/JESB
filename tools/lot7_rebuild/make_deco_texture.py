"""Speckled texture for the decorative panels (xelev hatch GENERAL_TEXTURE; ACC Lot 7 'siding dec: White').
Seamless 512 px tile, used at 24 x 24 in.  Usage: python -I make_deco_texture.py <out.png>
"""
import sys, random
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
from PIL import Image, ImageDraw, ImageFilter

random.seed(7)
N = 512
img = Image.new("RGB", (N, N), (236, 233, 226))
d = ImageDraw.Draw(img)
for _ in range(5200):
    x, y = random.randrange(N), random.randrange(N)
    r = random.choice((1, 1, 1, 2, 2, 3))
    g = random.randint(150, 205)
    col = (g, g - 4, g - 12)
    for ox in (-N, 0, N):                 # wrap so the tile is seamless
        for oy in (-N, 0, N):
            d.ellipse([x + ox - r, y + oy - r, x + ox + r, y + oy + r], fill=col)
img = img.filter(ImageFilter.GaussianBlur(0.6))
img.save(sys.argv[1])
print("written", sys.argv[1])
