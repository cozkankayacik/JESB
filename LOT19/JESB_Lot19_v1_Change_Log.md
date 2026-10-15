# JESB Lot 19 — SketchUp Model v1 Change Log

Date: 2026-10-15
Source model: `JESB_LOT19_MODELLING.skp` (owner's model, saved 2026-10-15 13:23; unchanged)
Reference: `JESB - LOT 19  ARCHITECTURAL PLAN_REVISION1.pdf` (Purohit Architects, issued 10.15.2026 "Village ACC review #2"): roof plan A-220 and exterior elevations A-300 / A-310 only, as instructed
Result: `JESB_Lot19_v1.skp`, images in `exports_v1/`

## How the model was compared

The roof plan and the four elevations were taken from the PDF as vector lines at true scale (1/4" = 1'-0") and laid over orthographic views of the model (`exports_v1/drawing_overlay_checks/`, drawing lines in red). The three DWG files in the folder (`xflr0/1/2_lot19.dwg`) are floor-plan xrefs: their walls are AutoCAD Architecture objects that do not export, so they were not usable for the exterior.

- **Walls, windows, doors, porches and the deck already matched the elevations** (window frames line up within about 1"). They were not changed.
- **The roof did not match**: wrong ridge positions and heights on the main roof, the north-east roof, the front-left bay and its west bump, and the entry tower had a flat box instead of a roof.

## Drawing inconsistency — please confirm with the architect

The roof plan A-220 does not agree with the elevations or the floor plans. It draws the whole two-storey house as one rectangular hip roof (eaves about 682" x 532", one 10'-6" ridge, north eave in a straight line across the full width, including over the rear deck). The elevations, which agree with the first and second floor plans (stepped rear walls, Bedroom 2 wing projecting north), show a stepped roof made of several hips with three ridge heights. **The model follows the elevations.** Following A-220 literally would put the roof 12'+ beyond the owner's bedroom wall over the deck.

## Changes made (roof only)

The old roof pieces were removed (six groups and eight loose faces) and the roof rebuilt as two solid groups, 6:12 everywhere, heights and eave lines read from A-300 / A-310:

`Roof - Main (per Rev 1 elevations, v1)` — shingles (`Material5`), eave top 279.7", 8" fascia (272.5"–279.7"), made of these hip blocks:

| Block | Where | Eave lines (model in.) | Ridge |
|---|---|---|---|
| A | west part | x 1170–1620, y 1405.7–1807.7 | 380.2" |
| B | middle | x 1218–1785.5, y 1389.7–1807.7 | 384.2" |
| C | east, highest | x 1369–1852.5, y 1394–1840 | 391.2" |
| D | north-east wing (Bedroom 2) | x 1643.7–1853.7, north eave 1959 | 332.2" |
| E | front-left two-storey bay | x 1218–1410, south eave 1098 | 327.7" |
| F | west bump of that bay | x 1180–1382, y 1154–1318 | 320.7" |

`Roof - Entry Tower (standing seam, per Rev 1, v1)` — metal (`Material6`), hip with eave top 310.2" and 12" fascia (299.0"–310.2"), x 1504.5–1688.5, south eave 1388.5, ridge 356.2", running back into the main roof. It replaces the flat box on the tower.

Overhangs come out at 11"–18" from the wall faces as drawn in the elevations (the roof plan's "2'-0" overhang" notes do not match the elevations either).

Checked: the new roof outline lies on the drawing lines in the front and left elevations; in the rear and right elevations (sheet A-310) the shapes match and the drawing sits about 5" higher overall, which is a registration offset of that sheet (its window heads line up with the model).

## Not changed

- Lower roofs (front porch 4:12 roof, west bump first-floor roof, garage roof, entry canopy): within about 5" of the elevations; left as modelled.
- Gutters, downspouts and roof vents shown on the drawings: not modelled (as in the source model).
- Walls, windows, materials, deck, site.

## Exports (`exports_v1/`, 2400 x 1500 PNG)

Front, rear, left and right elevations, one perspective, `JESB_Lot19_v1_Views.pdf` (four elevations), and `drawing_overlay_checks/` (roof and lower parts of each elevation against Rev 1, plus the A-220 roof plan against the original model).
