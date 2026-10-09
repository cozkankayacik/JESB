# JESB Lot 20 — SketchUp Model v5 Change Log

Date: 2026-10-09
Source model: `JESB_Lot20_v4.skp` (unchanged)
Reference drawing: `Lot-20 base rend.dwg` (saved 2026-10-07) — roof plan, front, right and left elevations
Result: `JESB_Lot20_v5.skp`, images in `exports_v5/`

Task: revise the roof over the garage by reading the DWG plan together with the elevations.

## What was wrong in v3 / v4

The garage roof followed the roof plan only. The plan stops the garage roof at the edge of the upper roof's overhang, so it does not show how the roof meets the two-storey wall. The front and right elevations do: the roof rises to 201.1" at the wall. In v3 / v4 it reached only 195.7" there, and the front elevation was missing the taller profile behind the main garage ridge.

## Change made

Only the garage roof group was rebuilt (`Roof - Garage (per DWG plan and elevations, v5)`). The main roof and everything else are as in v4.

The part of the garage roof that the plan shows is unchanged: ridge at 194.8", 4:12 side slopes, 6:12 front hip, the small front gable, the valley running from the corner of the angled wall to the north end of the ridge.

New, behind the end of the plan ridge (the last 23" before the two-storey wall):

- The west slope continues past the old ridge line and rises to **201.15"** at the wall, at the point midway between the west eave and the angled east eave. The DWG front elevation draws this apex at 201.1".
- From that apex the roof falls at **4:12** to the east eave at the wall, as on the front elevation.
- The ridge rises from the end of the level ridge (194.8") to that apex, as on the right elevation.
- This adds one small roof facet (about 17 sq ft, between the ridge end, the apex and the east eave at the wall). It sits almost entirely under the overhang of the upper roof.

Checked by drawing the DWG lines over the model views (`exports_v5/dwg_overlay_checks/`): the front elevation now matches line for line, including the taller profile; the right elevation matches the level ridge, the valley and the rise to the wall; the roof plan is unchanged and still matches.

| | v4 | DWG | v5 |
|---|---|---|---|
| Garage ridge | 194.8 | 194.8 | 194.8 |
| Highest point at the two-storey wall | 195.7 | 201.1 | 201.15 |
| East slope at the wall (front elevation) | about 3.4:12 | 4:12 | 4:12 |

## Second change in v5 (same day): siding boards shown as Hardie board panels

Instruction: the "siding boards" of the Kami notes are Hardie board panels like the owner's reference image — smooth flat panels with thin joints, not lap boards. Saved into the same v5 file at the owner's request.

- The two cladding materials are now smooth, without texture: `Hardie Panel - Arctic White` (523 sq ft) and `Hardie Panel - Black` (132 sq ft). They are on exactly the same faces as in v4 (notes F1–F5, R1, S1); colours unchanged.
- Panel joints are drawn as lines on the wall faces, 174 ft in total:
  - vertical joints at the window jambs, running the full height of each bay;
  - horizontal joints at the head of the lower windows and the sill of the upper windows (127.0" and 182.7" above the slab), so the black panels sit exactly in that band;
  - on the tall three-window bay, horizontal joints between the windows (92.75" and 172.75");
  - black panels split into equal panels: two on each front panel, three on the rear panel (in line with the window mullions above).
- The garage bay has vertical joints at the window jambs only.

Assumptions to confirm:

1. **Joint layout.** The Kami notes and the reference image do not give a panel layout for this house. The layout above follows the window lines, as in the reference image; panels come out between 17" and 64" wide.
2. **Joints are lines, not recessed reveals**, at the same level of detail as the rest of the model.
3. The v4 questions about colour matching and the small grey panel above the garage side door still stand. The question about board direction and width no longer applies.

## Third change in v5 (same day): white Hardie panels divided into equal panels

Instruction: divide the Hardie panel boards into equal parts; the white panels were not equal.

The joints that followed the window lines were removed. Every white panel area now has an even grid, all panels of an area the same size (panel size chosen as close as possible to a 48" x 96" sheet):

| Area | Size | Panels | Each panel |
|---|---|---|---|
| Front — garage bay | 120" x 135" | 3 x 1 | 40.0" x 135.3" |
| Front — bay left of the entry | 149" x 251" | 3 x 3 | 49.7" x 83.7" |
| Front — tall window bay right of the entry | 99.6" x 251" | 2 x 3 | 49.8" x 83.7" |
| Right side — panel bay | 112" x 257" | 2 x 3 | 56.0" x 85.7" |

- The narrow side returns of the bays carry the same horizontal joints as the face they belong to.
- Joints stop at window openings, so a joint that falls on a window shows only above and below it. On the tall window bay and the right-side bay the middle joint runs through the window column.
- The black panels were already equal (two panels on each front one, three on the rear one) and are unchanged.
- The joints of the white and black panels no longer line up with each other or with the window edges; that follows from dividing each area equally.

This replaces the joint layout described in the second change above.

## Fourth change in v5 (same day): black Hardie panels

Instruction: the black panels on the front elevation are one piece each; the black panel on the rear elevation is two pieces.

- Front, bay left of the entry and right-hand bay: the centre joint was removed; each black panel is a single 96.0" x 55.7" panel.
- Rear: the two joints were removed and one centre joint added; two equal panels of 91.0" x 45.5".

This replaces what the second and third changes above say about the black panels. The white panels are unchanged.

## Still open

1. **The DWG views do not agree exactly with each other here.** No single flat roof plane fits the plan valley, the 4:12 slope at the wall and the 201.1" apex at once, which is why the extra facet is needed; its own pitch works out at about 7.7:12. The large plane over the angled wall still works out at about 3.4:12 from the plan valley. If the architect intends one plane at a true 4:12, the valley on the roof plan would have to run almost straight west from the wall corner instead of diagonally.
2. **Left elevation.** The DWG draws the ridge level at 194.8" all the way to the wall; the model rises 6" over the last 23". The front and right elevations were followed.
3. **Right elevation valley.** The DWG starts the valley about 16" south of the wall corner shown on the plan; the model starts it at the plan corner.
4. Open items of v3 that are unchanged: left wing width (282" plan vs 287" elevations), overhang reference, vents and gutters not modelled.

## Exports (`exports_v5/`, 2400 x 1500 PNG)

Front, rear, left and right elevations, one perspective, and `JESB_Lot20_v5_Views.pdf` with the four elevations.
`exports_v5/dwg_overlay_checks/`: front, right and left elevations and the roof plan of the garage with the DWG lines in red.
