# JESB Lot 7 – Exterior Model R06 – Change Log

Date: 2026-10-16
Based on: R05, and through it R01–R04.

## Request

The owner compared the model with the A-220 roof plan and marked errors at the north-front corner of the main roof, where the bonus-room wing joins it:
- a box-like small hip with its own eaves sitting on the wing roof;
- a vertical step where the wing ridge reached the main roof.

The roof is to follow the roof plan.

## Cause

R01–R05 used an assumed small hip at that corner: front eave y 388, its east eave at x 46, the same 6.3:12 front pitch as the main roof. It did not match A-220. Its east eave overhung the wing roof as a box, and the main roof stepped where the two met.

## Correction (per A-220)

The north-front corner body of the main roof is now:
- west slope 9:12 from the eave x -12, the main west eave;
- front slope **6:12** from the eave **y 388**, as labelled on A-220;
- east slope 9:12 with its eave at **x 232**.

This reproduces every line A-220 draws there:

| A-220 line | Model R06 |
|---|---|
| Hip from the front-left corner (-12, 388) up to about (110, 573) | Hip (-12, 388) to (110, 571) |
| Short ridge at x about 110, y 573..603 | Ridge at x 110, y 571..592; above 592 the main west hip takes over |
| Hip from about (112, 573) to (223, 433), against the main front plane | (112, 589) to (223, 430) |
| Valley beside it, main front plane against the wing east slope | Computed by the roof envelope |
| Two valleys of the wing meeting at the wing ridge, apex about y 503 | Valleys from (81, 388) and (219, 388) meeting at y 492 on the wing ridge |

The wing ridge now dies cleanly into the main roof; there is no step and no box.

A new QA sheet, A-902, places the A-220 roof plan in red on the model's top view. Apart from the item below, the whole roof agrees with A-220: main hip and ridge, portico and front bay projections, wing and dormers, terrace, garage roofs.

## Remaining roof difference

- **Gablet on the south hip.** It is drawn on the front and south elevations but not on A-220.
  - **Decision 2026-10-16 (owner): keep the gablet as on the elevations.** Closed.
  - A-220 should be updated by the architect to show it.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R06.skp`. R01–R05 are kept.
- Exports and QA: `04_Visualization/Exports/R06/`, including `QA_Overlay_vs_Architect_DWG/JESB_Lot7_R06_Roof_Plan_vs_A-220.png`
- A3 set (9 sheets): `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R06.pdf`
