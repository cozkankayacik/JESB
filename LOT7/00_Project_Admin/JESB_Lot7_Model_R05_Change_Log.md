# JESB Lot 7 – Exterior Model R05 – Change Log

Date: 2026-10-16
Based on: R04, and through it R01–R03.

## Request

The owner marked the window divisions of the window stack beside the portico on the front (entry) elevation, at the stair. They are to be shown in the model as drawn.

## Source

`xelev_lot 7G.dwg`, front elevation, opening x 293.2..329.2 (plan), wall face y 434.32.

| Element | Drawing | Model R05 |
|---|---|---|
| Second-floor stair window, lower unit | 116.4..156.6, cross grid at the centre and at 136.5 | Same |
| Frame transom between the units | Frames meet at 155.6..157.6 | 2" white frame bar at 156.6 |
| Second-floor stair window, upper unit | 156.6..228.6, cross grid at the centre and at 192.6 | Same |
| Decorative panel | 64.3..113.4 | Unchanged (R03) |
| Stone header over the first-floor window | 53.2..62.8 band | Unchanged (R04, 53.2..61.2) |
| First-floor stair window | 24.9..53.2, cross grid at 39.0 | Unchanged (R04) |

In R04 the second-floor opening was a single tall unit with one cross. R05 splits it into the two drawn units.

The builder now supports stacked units in any opening: the `rows` split heights in `lot7_r01.py` produce a frame transom at each split and a cross grid in every unit, in `build_opening_unit` in `build_r01.rb`.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R05.skp`. R01–R04 are kept.
- Exports and QA: `04_Visualization/Exports/R05/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R05.pdf`
