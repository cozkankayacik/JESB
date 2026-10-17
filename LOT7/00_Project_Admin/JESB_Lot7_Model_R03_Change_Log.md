# JESB Lot 7 – Exterior Model R03 – Change Log

Date: 2026-10-16
Based on: R02 (`JESB_Lot7_Model_R02_Change_Log.md`, R01 for everything else).

## Request

The owner marked with red, on the front elevation, the decorative panels (motifs) to be shown in the exterior model:
- the panels flanking the garage-front window;
- the panel above the right front window.

## Changes

Every panel drawn with the decorative texture hatch on the elevation DWG (`GENERAL_TEXTURE` in `xelev_lot 7G.dwg`) is now modelled as a decorative panel:
- a white frame board, 1" proud of the wall;
- a speckled textured field, 2" inside the frame and 1.5" proud;
- material `Panel - Decorative Texture (siding dec)`, ACC Lot 7 "siding dec: White". The texture is `tools/lot7_rebuild/textures/deco_panel_speckle.png`, tiled at 24".

| Panel | Face | Position (plan) | z |
|---|---|---|---|
| Garage front, west of the window | y 14.32 | x 17.8..43.8 | 29.0..93.0 |
| Garage front, east of the window | y 14.32 | x 99.0..125.0 | 29.0..93.0 |
| Above the stair window | y 434.32 | x 292.8..329.8 | 64.3..113.4 |
| Above the entry door (portico) | y 480.96 | x 369.4..442.4 | 116.4..151.1 |
| Above the right front window | y 429.36 | x 507.0..581.0 | 115.9..151.6 |
| East dormer bay, below the windows | x 282.0 | y 184.0..309.8 | 112.4..150.1 |
| West dormer bay, below the windows | x 16.9 | y 106.3..236.1 | 123.6..152.1 |

- The infill of the lower front gable (R02) now uses the same textured material; it is drawn with the same hatch.
- The two dormer panels are centred on the bay faces. The side elevations are about 5" off against the plan (R01 QA).
- The flat white R02 panels at the garage front are replaced by these framed panels.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R03.skp`. R01 and R02 are kept.
- Exports and QA: `04_Visualization/Exports/R03/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R03.pdf`

## Open question added

11. **Panel finish.** The elevation draws the panels with a speckled texture hatch; the ACC list only says "siding dec: White". Please confirm the actual product and finish. Stucco, a cementitious panel and cast stone are all possible.
