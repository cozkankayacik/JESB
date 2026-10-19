# JESB Lot 19 — SketchUp Model v6 Change Log

Date: 2026-10-19
Source model: `JESB_Lot19_v5.skp`, as saved by the owner on 2026-10-19 at 10:19 (unchanged).
Reference: `ACC MATERIAL PACKAGE.xlsx`, sheet EXTERIOR, Lot 19 (columns H/I).
Result: `JESB_Lot19_v6.skp`, with images in `exports_v6/`.

Only materials were changed. No geometry was touched.

## 1. Accent panels between the windows: ACC "Siding dec — Light Brown"

- The ACC sample (cell I17) is a light brown lap siding, with an average colour of RGB 145 / 118 / 92.
- It was added as a new material, **`ACC Lot 19 - Siding dec - Light Brown`**. The texture is the sample image at 19.3 × 20.2 in., which gives three boards with a 7" exposure. The boards run horizontally.
- It is applied to the 8 panel faces between the windows:

  | Elevation | Panel faces |
  |---|---|
  | Front | 3 (left window column and right window stack) |
  | Rear | 3 |
  | Left | 2 |

- These faces previously used `Material8`, a pale wood texture added on 2026-10-19. `Material8` is unchanged on the entry door, the garage doors and the rear deck and posts.

## 2. Cobble Stone siding a little lighter

- Both Cobble Stone siding materials have their textures blended 22 % towards white. The pattern and texture size are unchanged.

  | Material | Texture size | Average colour before (RGB) | Average colour after (RGB) |
  |---|---|---|---|
  | `Material9` (main siding) | 24 × 23.9 in. | 188 / 181 / 165 | 203 / 197 / 184 |
  | `Material3` | 8.1 × 14.6 in. | 181 / 174 / 163 | 197 / 192 / 183 |

- For comparison, the ACC Cobble Stone sample averages RGB 183 / 180 / 162. The siding is now intentionally lighter than the sample, as requested.

## Not changed

- **ACC items also listed as Light Brown:** the front door and the garage doors are still `Material8` (pale wood). They can be switched to the same Light Brown if wanted.

## Exports (`exports_v6/`)

- Four elevations and a perspective (2400 × 1500 PNG).
- A front panel close-up.
- `JESB_Lot19_v6_Views.pdf`.

Script: `tools/lot19/build_v6.rb`.
