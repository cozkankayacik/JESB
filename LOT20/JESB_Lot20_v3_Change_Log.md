# JESB Lot 20 — SketchUp Model v3 Change Log

Date: 2026-10-08
Source model: `JESB_Lot20_v2.skp` (unchanged)
Reference drawing: `Lot-20 base rend.dwg` (saved 2026-10-07) — roof plan and the four elevations
Result: `JESB_Lot20_v3.skp`, images in `exports_v3/`

Task: update the roof of the model to the roof in the DWG.

## What was done

The nine separate roof pieces of v2 were removed and the roof was rebuilt from the DWG roof plan, with heights taken from the DWG elevations. The new roof is two solid groups inside the house group:

- `Roof - Main (per DWG roof plan, v3)` — 20 roof planes over the two-storey house
- `Roof - Garage (per DWG roof plan, v3)` — 7 roof planes over the garage

Every hip, valley, ridge and eave line of the DWG roof plan is reproduced (see `exports_v3/dwg_overlay_checks/`, DWG lines in red over the model).

### Heights (inches above the first-floor slab)

| | v2 model | DWG | v3 model |
|---|---|---|---|
| Eave, top edge — main roof | 257.0 | 264.6 | 264.6 |
| Fascia bottom — main roof | — | 256.6 | 256.6 |
| Main ridge | 374.0 | 381.6 | 381.6 |
| East main ridge | 371.0 | 378.6 | 378.6 |
| Rear (north-west) hip | 345.0 | 352.6 | 352.9 |
| Left wing ridge | 328.8 | 336.3 (elevations) | 335.1 (roof plan) |
| Front gable, large | 326.9 | 334.5 | 334.5 |
| Front gable, entry | 302.0 | 309.6 | 309.6 |
| Right-side bump | 297.0 | 304.6 | 304.6 |
| Eave, top edge — garage roof | 135.2 | 142.8 | 142.8 |
| Garage ridge | 187.2 | 194.8 | 194.8 |
| Garage front gable | 163.2 | 170.8 | 170.8 |

- Pitches as drawn: 6:12 on the main roof; on the garage 4:12 on the side slopes and 6:12 on the front hips.
- The roof now has the 8" deep edge the DWG draws (256.6 to 264.6 on the main roof, 134.8 to 142.8 on the garage). This is why every ridge is 7.6" higher than in v2: the v2 roof was a thin surface starting at the wall top.

### Plan (eave positions)

The v2 eaves were between 1" and 25" away from the DWG eave lines. They now follow the DWG roof plan, which draws the eave 24" outside the framing line of the walls. Largest moves:

| Location | Change |
|---|---|
| Rear (north-west) block, north eave | 25" back toward the house |
| Left wing, north eave | 19" further out |
| Left wing, west eave | 6" back toward the house |
| Entry gable and large front gable, front eaves | 10"–12" further out |
| Right-side bump, east eave | 10" further out |
| Garage and garage front gable, front eaves | 9" further out |
| Main roof | 1"–2.5" adjustments |

### Material

- Roof planes: the existing shingle material (`Material3`, charcoal), courses running parallel to each eave.
- Roof edge (fascia) and underside (soffit): left unpainted, so they read white. The ACC list gives White for Lot 20 soffit and fascia.

Nothing else in the model was changed. The saved camera view is the same as in v2.

## Not included

- **Roof vents.** The DWG roof plan shows four small vents near the main ridge. Not added.
- **Gutters and downspouts.** Drawn on the DWG elevations. Not added.

Both were separate items in the comparison of 2026-10-07 and have not been approved yet.

## Open questions

1. **Left wing ridge height.** The roof plan draws the left wing 282" wide (ridge 335.1"); the front, left and rear elevations draw it 287" wide (ridge 336.3"), with the south eave 5" further south. The model follows the roof plan. Which is right?
2. **Garage roof at the angled wall.** The roof plan runs the valley from the wall corner straight to the north end of the ridge, and the left elevation shows a level ridge at 194.8". The front and right elevations instead show a higher point (201.1") where the garage roof meets the two-storey wall. The model follows the roof plan and the left elevation; its highest point there is 195.7". With the roof plan geometry the slope over the angled wall works out at about 3.4:12, not 4:12.
3. **North end of the garage roof.** The roof plan stops the garage roof at the edge of the left-wing overhang. In the model it continues under the overhang to the brick face of the two-storey wall.
4. **Overhang.** The DWG eave is 24" from the framing line, which is 19" from the brick face on brick walls. Confirm this is intended.

## Exports (`exports_v3/`, 2400 x 1500 PNG)

Front, rear, left and right elevations (parallel projection) and one perspective from the front-left, same camera positions as v2.

`exports_v3/dwg_overlay_checks/`: roof plan, front elevation and left elevation of the model with the DWG lines drawn in red.

## Remaining items from the comparison of 2026-10-07

Three left-side windows 12" toward the rear; roof vents; gutters; basement windows and grade; balcony depth; garage door style.
