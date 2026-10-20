# JESB Lot 7 – Exterior Model R16 – Change Log

Date: 2026-10-20
Based on: **the owner's edited R15** (`JESB_Lot7_Model_R15.skp`, saved by the owner 20.10.2026 17:30). All of the owner's changes are kept. The edits were applied to that file by script (`tools/lot7_rebuild/su_edit/r16_edits.rb`). The R01–R15 generator was not re-run.
Source: owner instructions of 20.10.2026, Dominika's review of 19.10.2026, xelev (front and south) and sheet A-300.

## Changes

| # | Item | R15 | R16 |
|---|---|---|---|
| 1 | Lap siding ("white siding", Dominika; DWG note "James Hardie siding – Arctic White or eq., typ.") | ACC Cobble Stone | **White lap siding on all 57 siding faces**: wing gables, garage gable, wing and dormer walls, gablet. Material renamed `Owner - Siding - White Lap (James Hardie Arctic White per DWG, Dominika 19.10)`. Same board texture and size. |
| 2 | Entry steps (front door) | Porch at −0.5 and 5 risers × 7.5 in, running out 55 in to y 365 | Per xelev front and south: the door threshold steps down to a porch at **−7.5**. Then 4 risers of about 7.6 in to grade (−38.1): −15.1 and −22.75 between the piers, and the bottom two steps widened to x 356–456 in front of the piers. Treads are 10 in and the stair ends at y 403.3, as on the south elevation. Black iron railings run on the wide steps, x 358 / 454, as drawn. The lawn is patched where the old, longer stair stood. |
| 3 | Garage bump corner ("please check blueprint", Dominika; DWG screenshot, A-300) | White panel down to the water table | Per the DWG: brick base up to the **sill course (rowlock 22.87–24.87)**, wrapping the front and the south side of the bump. Water table on the bump side. **White corner boards** (5.5 in) at both bump corners from the sill course to the frieze, and a frieze board on the bump side (91.12–98.37). |

## "Please check blueprint" – the second point (garage / main block junction, south)

The model was checked against A-300, xelev and the DWG screenshot; nothing needed to change.
- The DWG draws only the brick wall corner of the main block, with its sill course and water table, and the iron rail of the garage side stair.
- The red marks in the screenshot are downspouts. The owner decided on 17.10.2026 that gutters and downspouts are **not modelled** (DWG note 8: "gutters and downspouts shall be seamless aluminium").
- If they are wanted now, they would be a new item.

## QA

- DWG overlays of the four elevations: `04_Visualization/Exports/R16/QA_Overlay_vs_Architect_DWG/`.
- The entry steps and rails fall on the xelev front and south lines, and the bump corner on the xelev south lines.
- The roof is unchanged, so the A3 set uses the R15 roof plan and A-220 check.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R16.skp`. The owner's R15 is kept as saved.
- Exports and QA: `04_Visualization/Exports/R16/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R16.pdf`
