# JESB Lot 7 – Exterior Model R01 – Change Log

Date: 2026-10-16
Status: **R01 issued for review**. Exterior only, modelled as drawn, no renders (decisions of 2026-10-16, see the rebuild plan).

## 1. Deliverables

| Item | File |
|---|---|
| SketchUp model | `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R01.skp` |
| Model views | `04_Visualization/Exports/R01/`: four elevations, roof plan, four perspectives |
| QA overlays | `04_Visualization/Exports/R01/QA_Overlay_vs_Architect_DWG/`: architect's elevation lines in red over the model views |
| QA close-ups | `04_Visualization/Exports/R01/QA_Detail_Views/`: roof junctions, portico, gablet, garage front |
| A3 review set | `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R01.pdf`. 8 sheets on the Projades A3 title block: A-000 cover, A-101..104 elevations, A-201 roof plan, A-301 perspectives, A-901 QA. |
| Scripts | `tools/lot7_rebuild/`. The whole model is regenerated from the drawings by `lot7_r01.py` (geometry) and `build_r01.rb` (SketchUp), run by `run_build.ps1`. |

## 2. What the model is

A new model built from scratch. Nothing is copied from the owner's model or from v1/v2 except texture images.

- **Frame:** DWG plan coordinates in inches, so the model can be overlaid on the architect's plans 1:1. z = 0 is the top of the main floor (839.20'). Front faces west; the model's north angle is set to 270° and the location to South Barrington, IL.
- **Exterior walls:** traced from the architect's floor plan DWGs (`xflr1`, `xflr2`). The traced line is the outer face (brick face, or siding face on the wing).
  - Walls are true slabs with openings cut through them, 10.5" thick on the first floor and 6" on the upper walls.
  - Each wall rises to the underside of the roof that covers it, so gables, hip eaves and dormer cheeks close without gaps.
- **Openings:** 50 openings.
  - Horizontal position and width come from the plan glazing and door lines.
  - Sill and head heights come from the window units on the elevation DWG (`xelev`): 45 of 46 plan openings matched automatically.
  - Added by hand: the wing gable window, entry door, terrace slider, both garage doors and two basement egress windows.
- **Windows:** white frames, double-hung meeting rails and twin mullions, set 3" back, with white sills in brick walls.
- **Roof:** one envelope of convex hip and gable bodies per roof group, 7.25" fascia, soffit underside. Layout from A-220; heights from `xelev`.

| Roof | Eave (top of fascia) | Notes |
|---|---|---|
| Main hip | 248.87 | Ridge 381.97, 25'-8" long. Ends 9:12; front and rear 6.3:12, from the drawn ridge height |
| North-front corner (small hip) | 248.87 | Main west eave continues to y 388 (north elevation) |
| Portico and front bay projections | 248.87 | Hip ends, standing-seam metal fronts, sides 9:12 |
| South gablet | base 258.9 | Gable face in the south wall plane, 6:12, ridge 313.2 |
| Bonus-room wing over garage | 201.12 | 9:12, ridge 300.85, gable to the front with a 24x32 window |
| Two bay dormers on the wing | 234.5 | Hip, standing-seam metal, 9:12 |
| Garage | 105.62 | 9:12 gable to the front, 19" overhang |
| Guest bedroom bay | 127.1 | Hip, metal, 9:12 |
| Covered terrace | 112.37 | Hip against the house wall, about 5:12 (elevation) |

- **Materials** (ACC Material Package, Lot 7 column):

| Element | Material |
|---|---|
| Roof | Mission Brown shingles |
| Accent roofs | Standing-seam metal |
| Brick | Magnolia (US Brick), on the main block both floors, the garage and the guest bay |
| Wing walls and garage gables | Siding, Cobble Stone |
| Dormer bays | White panel (ACC "siding dec") |
| Trims, frieze, soffit, fascia, windows | White |
| Front door | Brown |
| Garage doors | Brown, cottage style with a glass top row (8'x8' and 16'x8') |

- **Trim and details:**
  - 8" white frieze under the main soffit;
  - brick rowlock water table at z 10.7..16.7;
  - two-storey brick portico piers and entablature;
  - porch stoop with 5 risers;
  - covered terrace with 4 brick piers, beam, 42" guardrails and a 6-riser stair.
- **Site:** terrain only from the elevation grade lines. The four side profiles are blended, and a skirt down to z -100 makes the ground read as a section in the elevations.
  - Garage slab at -38.1 (836.0').
  - Driveway apron and the strip to the street are **assumptions**; there is no site plan.
- **Organisation:**
  - **Groups:** one house group with sub-groups for walls, windows and doors, roofs, porch/terrace/trim, plus a separate site group.
  - **Tags:** A-WALL-EXT, A-ROOF, A-TRIM, A-WIND, A-DOOR, A-SLAB, A-STAIR, L-TOPO, L-SITE.
  - **Scenes:** four elevations, roof plan, four perspectives.
  - **Names:** all names are in English.

## 3. QA

- The architect's elevation lines were overlaid on all four model elevations (sheet A-901). The main roof, ridge, eaves, all windows and doors, the portico, the gablet, the wing, the dormers, the garage doors and the terrace fall on the drawn lines.
- Alignment: front and rear within about 0.1". The south and north elevations are anchored on the main block, which leaves about 5" of drawing inconsistency on the side elevations.
- Close-up QA views are in `QA_Detail_Views/`.

## 4. Open questions (drawing conflicts – owner / architect to decide)

1. **Garage front moved.** The new first floor plan (`xflr1`, 16.10.2026) moves the garage front 9.36" back and shifts the garage door piers. The elevations (`xelev`) and the second floor / roof plans were not re-issued and still show the old position.
   - The model follows the new plan for the walls.
   - The garage roof front was moved back by the same 9.36".
   - On the front elevation the lower garage gables sit about 9–13" off the DWG.
2. **Portico upper window.** The plan shows 60" (`xflr2`); the elevation draws a pair 86" wide. The model follows the plan.
3. **Guest bedroom bay windows.** The plan shows 36"; the north elevation shows 30". The model follows the plan.
4. **Portico and front bay projections.** A-220 draws the metal fronts at about 6:12. The elevations need a steeper front (0.55) for the drawn apex (309.7) to show above the main roof. The model follows the elevations.
5. **Covered terrace roof.** A-220 says 6:12; the elevations show about 5:12 with the eave at 112.37. The model follows the elevations.
6. **Main roof pitch.** Labelled 6:12 front and rear, but the 25'-8" ridge at the drawn height gives 6.3:12. The model follows the drawn ridge height.
7. **Guest bedroom bay roof.** The eave height is derived as 127.1 from the roof/wall line on the north elevation; it is not dimensioned. Please confirm.
8. **No site or grading plan.** The terrain comes only from the elevation grade lines; the driveway is assumed. A plat or grading plan is needed for the site.
9. **Wing front gable window.** The plan places it at x 125–149; the front elevation shows it at x 138–162. The model follows the plan.

## 5. Not modelled (R01 scope)

- Interior.
- Gutters and downspouts.
- Roof vents and louvres.
- Chimney: none drawn.
- Exterior lights.
- Landscaping.
- Renders.
