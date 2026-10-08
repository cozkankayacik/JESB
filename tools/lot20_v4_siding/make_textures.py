# Horizontal siding-board textures for the Lot 20 v4 facade revision (4 courses of 7 in. = 28 x 28 in. tile).
import sys, os
sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")
import numpy as np
from PIL import Image
out = sys.argv[1]
os.makedirs(out, exist_ok=True)
rng = np.random.default_rng(7)
def make(name, base, shadow, light, noise):
    n = 512; course = n // 4
    a = np.zeros((n, n, 3), np.float32) + np.array(base, np.float32)
    a += rng.normal(0, noise, (n, n, 1))
    for c in range(4):
        y0 = c * course
        a[y0:y0 + 3] = np.array(light, np.float32)                    # top of the board catches light
        a[y0 + course - 5:y0 + course] = np.array(shadow, np.float32)  # shadow line under the lap
        ramp = np.linspace(0, 1, course - 8)[:, None, None]
        a[y0 + 3:y0 + course - 5] += ramp * (np.array(shadow, np.float32) - np.array(base, np.float32)) * 0.10
    Image.fromarray(np.clip(a, 0, 255).astype(np.uint8)).save(os.path.join(out, name), quality=93)
make('siding_boards_arctic_white_7in.jpg', (241, 242, 237), (176, 178, 174), (250, 250, 247), 1.2)
make('siding_boards_black_7in.jpg', (38, 38, 40), (10, 10, 11), (66, 66, 68), 1.5)
print('ok', os.listdir(out))
