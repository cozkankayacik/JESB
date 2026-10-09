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

## Still open

1. **The DWG views do not agree exactly with each other here.** No single flat roof plane fits the plan valley, the 4:12 slope at the wall and the 201.1" apex at once, which is why the extra facet is needed; its own pitch works out at about 7.7:12. The large plane over the angled wall still works out at about 3.4:12 from the plan valley. If the architect intends one plane at a true 4:12, the valley on the roof plan would have to run almost straight west from the wall corner instead of diagonally.
2. **Left elevation.** The DWG draws the ridge level at 194.8" all the way to the wall; the model rises 6" over the last 23". The front and right elevations were followed.
3. **Right elevation valley.** The DWG starts the valley about 16" south of the wall corner shown on the plan; the model starts it at the plan corner.
4. Open items of v3 that are unchanged: left wing width (282" plan vs 287" elevations), overhang reference, vents and gutters not modelled.

## Exports (`exports_v5/`, 2400 x 1500 PNG)

Front, rear, left and right elevations, one perspective, and `JESB_Lot20_v5_Views.pdf` with the four elevations.
`exports_v5/dwg_overlay_checks/`: front, right and left elevations and the roof plan of the garage with the DWG lines in red.
