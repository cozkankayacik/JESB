# JESB Lot 7 – Dominika's Review (19.10.2026) – Check and Update Plan for Model R15

Source: `03_Shared_CAD_and_Models/JESB Lot7 Render Elevations 1019.pdf`, 4 pages. These are mark-ups on the R14 AI visualization.
Checked against: model R14 (exports and DWG overlays in `04_Visualization/Exports/R14/`), the architect's xelev DWG and plan A200 (Rev1 PDF).
Status (20.10.2026):
- **D01–D08 are done in model R15**; see `../JESB_Lot7_Model_R15_Change_Log.md`.
- D09 and D10 wait for the owner's answers to Q1 and Q2.
- D15, D16 and Q3 wait for Dominika.

The mark-ups are on an AI render, not on the model. Each item below was therefore checked twice: is the problem in the model, or only in the render? Is the request supported by the DWG?

## A. Model changes – confirmed by the DWG

| # | Page / location | Mark-up | Check result | Planned change (R15) |
|---|---|---|---|---|
| D01 | Front, right of the lower garage gable | "missing roof" | **Confirmed.** xelev draws a small standing-seam pent roof across the base of the main garage gable: front view x 149.7–288, fascia top z 105.62, top against the wall ≈ 119.4, seams every 12 in. The south view shows its profile: eave at y −7.64, 6:12 up to the wall. The model has no roof there. | Add the pent roof (dark brown bronze standing-seam metal, 6:12, eave 105.62, projecting ~24 in from the garage face y 16.0) between the lower gable and the east rake, with fascia and soffit. |
| D02 | All elevations, under the first-floor windows | "this line is connected with window sill" | **Confirmed.** xelev has two continuous brick bands on all four elevations: water table 12.21–14.87 and a sill course 22.87–24.87. The first-floor window sills sit on top of the sill course at 24.87. The model has one band at 10.7–16.7. | Replace the band with the two DWG bands: water table 12.21–14.87 and sill course 22.87–24.87, continuous and running into the window sills. |
| D03 | Front, apexes of the three garage and wing gables | small rectangles at the apexes | **Confirmed for 2 of 3.** xelev draws a vertical apex trim (king-post block) at the wing gable apex (≈7 in wide, z 266–290) and at the main garage gable apex (z 181–206). It is not drawn on the lower gable. | Add white apex trim at the wing and main garage gables as drawn. Lower gable: see question Q3. |
| D04 | Front, along the rakes of the three gables | red lines parallel to the rakes; "white trim" at the lower gable base | **Confirmed.** xelev (FINE) draws a trim board just inside each rake, and a horizontal board at the base of the lower gable. The model has only the fascia/rake board. | Add white rake frieze boards inside all three gable rakes, and the base board of the lower gable. |
| D05 | North, two basement windows (red boxes) | windows outlined | **Confirmed.** xelev draws each basement window as two sashes with frames: 26 in + 22 in, mullion at 662.6 / 855.3. The model has one plain pane. | Model the basement windows as two-sash sliders with white frames, as drawn. |
| D06 | South and north, both sides of the dormers | X marks | **Confirmed – model error.** The wing wall tops next to each dormer are taken from the dormer roof, so small siding "ears" rise above the wing eave beside the dormer. The DWG has the wing fascia running into the dormer and nothing above. | Cap these wing wall segments at the wing roof only, removing the ears. |
| D07 | North (garage wall, bottom) and front (bottom left, below the bump) | X marks on the low lines | **Confirmed – model error.** The garage slab box shares the garage wall faces (x 0 and y 4.96), so its edges show as two lines near grade on the facade. The DWG has nothing there. | Inset the garage slab behind the wall faces so it no longer shows. |
| D08 | North, fascia; north/rear walls | small X marks on the fascia and on vertical lines in flat brick | **Partly a model issue.** The fascia shows joint lines where roof cells meet, and some flat brick walls show seam lines where wall groups meet (for example north of the bay). The DWG shows plain surfaces. Some of the X's are AI-drawn downspouts (see C). | Merge or hide coplanar seam edges on the fascia and the walls, so flat surfaces show no lines. |

## B. Finish changes – conflict with earlier decisions, confirmation needed (Q1, Q2)

| # | Mark-up | Model R14 | Note | Planned change |
|---|---|---|---|---|
| D09 | "white siding" on the wing gable, the main garage gable, the wing side strips (front) and the south gablet | Cobble Stone lap siding (ACC Lot 7) | The DWG elevation note says "James Hardie siding – Arctic White or eq., typ.". ACC selects Cobble Stone. Dominika follows the DWG note. | Change **all** lap siding to white, so that the dormer wing walls on the north and south also match. See Q1. |
| D10 | "white trim" on the first-floor window and door heads (front: entry door, right window, small stair window, lower gable window) | Light beige cast-stone headers (owner decision 17.10.2026) | This reverses the owner's decision of 17.10. | Change all first-floor headers to white trim on all elevations. See Q2. |
| D11 | Lower gable: "white trim" panels flanking the window (red boxes) | Already white framed panels | No change needed. The mark-up is read as confirming white trim panels. | None, unless Dominika means something else. |

## C. Render issues – the model already matches the DWG (pass to Astra, no model change)

| # | Mark-up | Finding |
|---|---|---|
| D12 | South: "please check blueprint" at the garage west corner and at the garage/main-block junction | The AI drew white vertical strips like downspouts or trim. In the model and the DWG these are brick: the bump side wall at the garage corner and the portico pier side at the junction. The model matches the blueprint. |
| D13 | Rear and north: X marks on the wall corners | The AI added downspouts at the corners. There are none in the model or the DWG (owner: no gutters or downspouts). |
| D14 | Rear: "grass" under the covered terrace | The AI drew a dark soil band under the terrace skirt. In the model the lawn meets the skirt. The model will be re-checked and the note passed to Astra. |

## D. Needs clarification from Dominika before changing

| # | Mark-up | Finding |
|---|---|---|
| D15 | South: "please check the stairs layout" (entry stair seen in profile) | The model follows plan A200: covered porch, "DN 5R" towards the front (west), handrails both sides, 5 risers × 7.5 in. The xelev south view does not draw open steps there. It draws a solid brick element from y 367 to 420, up to z 24.87, with the bands – this could be brick cheek walls beside the steps. See Q4. |
| D16 | Front: red arrow from the entry head up to the eave between the portico and the front bay | The intent is not clear. It may mean the brick pier between the entry and the right window should run up to the eave, or that there is a gap in the fascia at that point. See Q5. |

## Questions

- **Q1:** Should all lap siding be white (Arctic White per the DWG note), replacing ACC Cobble Stone? Or only the front gables and the gablet?
- **Q2:** Should the window and door headers change from light beige cast stone (owner decision 17.10) to white trim, on all elevations?
- **Q3:** Should the lower front gable also get the apex trim? It is not drawn in the DWG.
- **Q4:** Entry stair: should it get brick cheek walls (closed sides, as the south DWG view suggests), or stay open with handrails per plan A200?
- **Q5:** What does the arrow from the entry head to the eave junction ask for?

## Execution plan (model R15)

1. Make the confirmed geometry fixes D01–D08 in the generator (`lot7_r01.py` / `build_r01.rb`): pent roof, bands, apex and rake trim, basement windows, dormer-side wall tops, slab inset, seam cleanup.
2. Apply the finish changes D09 and D10 once Q1 and Q2 are answered.
3. Apply D15, D16 and Q3 only after Dominika's answers.
4. Build R15 as a new file (R14 is kept). Run the DWG overlay QA on all four elevations and the roof plan check against A-220, and look at close-ups of each changed area.
5. Write the R15 A3 set, change log and register entry; update brain.md; commit and push.
6. Hand R15 to Astra for renders, with the D12–D14 render notes. Claude does not render.
