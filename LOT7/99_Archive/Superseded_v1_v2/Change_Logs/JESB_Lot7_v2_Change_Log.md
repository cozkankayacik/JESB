# JESB Lot 7 — SketchUp Model v2 Change Log

Date: 2026-10-16
Source model: `JESB_Lot7_v1.skp` (unchanged)
Reference: `xelev_lot 7G.dwg` (exterior elevations), read together with roof plan A-220 of `JESB - LOT 7 ARCHITECTURAL PLAN_REVISION1.pdf`
Result: `JESB_Lot7_v2.skp`, images in `exports_v2/`

## How the DWG was compared

The four DWG elevations were laid over orthographic views of the model at the same scale. The overlays are in `exports_v2/dwg_overlay_checks/`, with DWG lines in red, windows in blue and doors in green.

- **Heights:** the DWG was aligned on the windows, which gives model z = DWG y − 1400.5.
  - With this alignment, all main-floor and upper-floor windows, the eaves and the garage doors line up.
  - Only the porch and deck levels differ, by about 1.5".
- **Horizontal position:** each elevation was aligned on its windows.

## Findings that changed the roof

Read together, the DWG side elevations and the A-220 hatch and labels show three roof parts that v1 built wrongly. These are explained below.

1. **Roof over the garage wing (front-left).** This is a **hip**, not a gable with a siding face.
   - A-220 labels it as a hip, a short ridge and a valley.
   - On the side elevations it rises at 6:12 from the front eave (y 3710).
   - From the front it still reads as a triangle, but that triangle is the 6:12 roof plane, in shingles.
2. **The two metal "gables" over the entry.** These are also **hip ends**.
   - Their 6:12 front planes are standing-seam metal; A-220 shows them hatched.
   - The right elevation shows the 6:12 slope and a short ridge.
3. **Garage roof.** The ridge does not stop at the wing. It runs on until it dies into the wing's hip roof, at about y 3830; this matches the DWG right elevation and the A-220 valleys.

## Changes

| Item | v1 | v2 (DWG) |
|---|---|---|
| Main ridge | 404.7 (6:12 front/rear) | **411.3**, ridge 25'-8" long as dimensioned on A-220 and drawn on the front elevation (front/rear planes 6.3:12) |
| Wing over the garage | gable, siding face, ridge 370.7 | **hip** (W/E 9:12, front 6:12), ridge 370.7, shingles |
| Entry projections | vertical metal gable faces at y 3730.2 / 3735.2 | **hip ends**, 6:12 metal fronts at y 3725.2 / 3731.2 |
| East small gable | — | **new**: gable on the east hip face, x 2279.6, y 3922.8..4140.2, 6:12, ridge 342. Siding face with rake boards, base board and king post |
| Garage upper roof | gable face y 3377.2, ridge stops at y 3780 | gable face **y 3372.3**, ridge runs to the wing roof. Rake boards, king post and window casing added |
| Garage gable window | y 3376.6 | on the new gable face (front y 3371.7) |
| West dormer | roof y 3410.1..3575.1; windows z 190.5..249.3 at 31.5 spacing | roof **y 3405.3..3570.3**; windows **z 184.4..243.3** at y 3422.9 / 3456.9 / 3490.8 / 3524.8 (34" spacing); cheek walls at the wall ends |
| East dormer | walls y 3497.8..3638.8, roof 3485.8..3650.8 | walls **3488.2..3629.2**, roof **3476.2..3641.2**; windows z 184.4..243.3 at y 3493.7 / 3527.7 / 3561.6 / 3595.6 |
| East wall, two narrow upper windows | 24×72, y 3953.2 and 4082.0 | **24×60** (z 197.4..257.8), y **3947.7** and **4075.9**; the wall openings and trim moved with them |
| Garage doors (east) | single y 3375.3..3471.3, double 3498.7..3690.7 | single **3365.9..3461.9**, double **3489.9..3681.9**; openings, headers and trim moved with them |
| Covered terrace | roof y 3891.9..4181.5; columns / deck 5" north; deck to x 2480 with stair on the east end | everything 5.1" south; deck **x 2281.8..2426** |
| Terrace stair | on the east end | **on the south side**, x 2351.2..2399.2, 4 treads (12" deep, 6.8" risers) with rails both sides; the south railing is split at the stair |

## Remaining differences (DWG drawings disagree with each other)

- **Main ridge:**
  - The front and rear elevations draw it at 411; the left and right elevations draw it at 407 and 404.
  - The model follows the front elevation and the 25'-8" ridge dimension.
- **Rear elevation hip ends:** these are drawn at 6:12 (ridge 1900..2030). The front elevation and A-220 show 9:12, and the model follows those.
- **Lines the side and rear elevations leave out:**
  - the front projections' ridges;
  - the east gable, as seen from the rear;
  - the garage ridge, as seen from the west.
  
  They appear in the model because it is 3D.
- **Basement windows on the rear:** the three pairs in the model are not drawn on the DWG rear elevation. They were left in place.
- **Grade and foundation lines below the water table:** not modelled. Terrain is not part of this model.

## Exports (`exports_v2/`)

- Four elevations and a perspective (2400×1500 PNG).
- `JESB_Lot7_v2_Views.pdf`.
- `dwg_overlay_checks/`.
