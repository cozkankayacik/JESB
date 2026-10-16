# JESB Lot 7 — SketchUp Model v1 Change Log

Date: 2026-10-16
Source model: `JESB_SKETCHUP_LOT7.skp` (unchanged)
References:
- `JESB - LOT 7 ARCHITECTURAL PLAN_REVISION1.pdf`: roof plan A-220 (outline, pitches, gables) and elevations A-300 / A-310 (heights).
- `xelev_lot 7G.dwg`: exterior elevations, used as a cross-check.

Result: `JESB_Lot7_v1.skp`, with images in `exports_v1/`.

Only the exterior and the roofs were changed. The interior and floor plans were not used.

## 1. Roofs (rebuilt per A-220)

All old roofs were removed and rebuilt from the roof plan lines. These were the main roof, the entry tower front roof, the main fascia band, the garage upper roof and the west dormer roof.

The roof plan was registered to the model walls, and the eaves sit about 12" outside the walls. Fascia is 7.3" deep, with white soffits.

| Roof | Plan / pitch | Eave top | Ridge |
|---|---|---|---|
| Main | Hip, 9:12 at the west/east ends, 6:12 front/rear, x 1629.5..2292.6, y 3739.2..4246.5 | 277.9 (was 271.9) | 404.7 |
| Cross gable over the garage wing | 9:12 gable, x 1629.5..1877.1, siding gable face at the front | 277.9 | 370.7 |
| Two front gables over the entry | 9:12, x 1968.6..2126.6 and 2135.0..2236.1, **metal** gable faces, as drawn | 277.9 | 337 / 316 |
| Garage upper | 9:12 gable, x 1658.5..1924.6, siding gable face at the front | 230.8 | 330.6 |
| West garage dormer | 9:12 hip | 263.5 | 325.4 |
| East garage dormer (new) | 9:12 hip, mirror of the west one | 263.5 | 325.4 |
| Covered rear terrace (new) | 6:12 hip, x 2283.8..2436.6, y 3891.9..4181.5 | 141.4 | 213.8 |

- The frieze band under the main eave was raised 5.7" to meet the new soffit.
- The garage upper walls were stretched up to the new garage eave (to z 223.5).

## 2. Garage dormers

- **West dormer:** walls raised 24.6" and the four windows raised 25" (now z 190.5..249.3), with cheek walls down to the garage roof.
- **East dormer:** added per A-220 and the right elevation. It has a wall box, cheek walls and four windows mirrored from the west dormer.

## 3. Garage gable window

The small window on the front garage gable was moved up and centred on the ridge to match A-300 (now about x 1780..1804, z 255..288). It now sits in front of the new gable face.

## 4. Covered rear terrace

- New hip roof (see table above).
- Four 16×16 brick columns, z 23.3..134.1.
- The deck, railings and stairs (22 parts) were moved 60.3" south so they sit under the roof, as drawn in the plan.

## Remaining differences (not changed)

- **First floor and garage heights:** relative to the upper floor, the first floor and garage are about 11–13" lower in the model than in the drawings. The upper floor, the windows and the roofs were matched to the drawing; the lower floors were left as they are.
- **Lower garage roof:** not changed.
- **Windows and doors:** not audited one by one. The overlay checks show the upper windows match.
- **Rear main roof pitch:** A-300 draws the rear main roof with 6:12 ends, while plan A-220 says 9:12. The plan was followed.
- **Cross gable ridge:** visible on the right elevation in the model; the 9:12 plan pitch makes it rise above the main hip's side slope.

## Exports (`exports_v1/`)

- Four elevations and a perspective (2400×1500 PNG).
- `JESB_Lot7_v1_Views.pdf`.
- `pdf_overlay_checks/`: the model's elevations with the A-300/A-310 lines overlaid in red.
