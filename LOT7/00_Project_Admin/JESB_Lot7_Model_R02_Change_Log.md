# JESB Lot 7 – Exterior Model R02 – Change Log

Date: 2026-10-16
Based on: R01 (`JESB_Lot7_Model_R01_Change_Log.md`). Everything there still applies except the items below.

## Request

The owner marked the roof detail at the garage front on the front elevation: the lower front gable and its eave returns. It is to follow the elevation drawing (`xelev_lot 7G.dwg`).

## Changes

| Item | R01 | R02 (per the xelev front elevation) |
|---|---|---|
| Lower front gable over the 11" bump of the left garage front (x 0..137.68, face y 14.32) | Missing | Added. 9:12 front gable, eaves x -7.0 / 149.7 (top of fascia 105.6), apex x 71.35 at 164.4. 6" rake overhang; the ridge dies into the main garage gable face. |
| Eave (cornice) returns | – | Added at both feet of the lower gable (17.5" wide, x -7..10.5 and 132.2..149.7) and at the east foot of the garage gable (x 270.5..288) |
| Main garage gable | Eaves x -19 / 295 (second floor plan roof outline), apex x 138 | Eaves x -7 / 288 as drawn. Apex x 140.5 at 216.2, exactly the drawn height. Gable face in the plane of the right front wall (y 25.36), continuing above the lower gable. |
| Bump front face (y 14.32) | Brick | Brick below the water table, white panel above (xelev shows no brick hatch there). Gable infill in panel (decorative-texture hatch on the elevation). |
| Decorative panels | – | Two 26 x 64 panels flanking the bump window (x 17.8..43.8 and 99.0..125.0, z 29..93) |

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R02.skp`. R01 is kept unchanged.
- Exports and QA: `04_Visualization/Exports/R02/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R02.pdf`

## Open question added

10. **Garage gable overhangs.** The elevation gives 7" (west) and 12" (east). The second floor plan's roof outline gives 19" on both sides. The model follows the elevation.
