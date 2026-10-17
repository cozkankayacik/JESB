# JESB Lot 7 – Exterior Model R14 – Change Log

Date: 2026-10-17
Based on: R13.
Source: the owner's instruction "fix to the DWG, if you are sure", given for the three remaining differences after RFI-001.

## Changed (certain)

| Item | R13 | R14 | Evidence (xelev) |
|---|---|---|---|
| Lower front gable over the garage bump: front of its roof | y −1.04 (6 in rake overhang) | **y −11.64**: the gable projects 20.0 in ahead of the main garage gable, about 16.6 in beyond the bump wall. Its eave returns run from the gable front back to the wall. | South elevation: front line at −11.64 (z 98.4–164.3), main gable rake at 8.36. North elevation: −16.23 and 3.77. Both views give the same **20.0 in** projection; the north view carries its ~4.6 in global offset. |
| Main garage gable rake front | y 10.0 | **y 8.36** (1.6 in) | South elevation, vertical rake line at z 113.6–216.2. |

## Not changed (not certain) – for the owner and architect

| Item | Why it was not changed |
|---|---|
| 8 ft garage door height (DWG elevation 6 ft, model 8 ft) | The first floor plan (Rev1 PDF, page 4) labels the door **"8'-0" x 8'-0" OVHD"**. The plan and the elevation conflict, so the model keeps the labelled 8 ft. Please confirm with the architect. |
| North elevation garage end (~10 in) | The north and south elevations contradict each other. The south view agrees with the plan within 0.6 in; the north view is ~4.6 in off overall and ~10 in at the garage wall. Both cannot be met, so the model follows the south view. |

## Note for the owner (not acted on)

The elevation sheets carry the note "JAMES HARDIE SIDING – ARCTIC WHITE OR EQ., TYP.". The ACC package selects Cobble Stone for the Lot 7 lap siding, and the model follows ACC.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R14.skp`
- Exports and QA: `04_Visualization/Exports/R14/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R14.pdf`
- Renders: none by Claude (owner instruction). Astra renders from R14.
