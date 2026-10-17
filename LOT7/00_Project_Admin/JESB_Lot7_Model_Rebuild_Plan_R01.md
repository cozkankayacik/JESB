# JESB Lot 7 – SketchUp Model Rebuild Plan (R01)

Date: 2026-10-16
Status: **for approval**
Prepared for: Projades

## 1. Brief summary

| Item | Lot 7 |
|---|---|
| Project type | Custom single-family house in Jade Estates, South Barrington, IL (Cook County), IECC Climate Zone 5A |
| Design | Purohit Architects, Inc., project 202601.LOT 7, Revision 1 (10/15/2026). DWG floor plans re-issued 10/16/2026. |
| Our scope | **Model the architect's design as drawn.** This is not a redesign: concept options do not apply. Design comments are raised as review items. |
| Floors | 2 storeys plus full basement (walk-out or look-out: **VERIFY** on the grade lines) |
| First floor | Foyer (2-storey), living room, family room (2-storey), kitchen with 48x116" island, walk-in pantry, butler pantry, dining, powder room, owner's entry / mudroom, guest bedroom and bath, covered porch, raised terrace with stair, attached 3-car garage |
| Second floor | Owner's bedroom, owner's bath, owner's walk-in closet, bedrooms 2–5, baths 3–5, laundry, mechanical room, open-to-below areas. Bedroom 5 is over the garage. |
| Ceiling heights | First floor 10'-0" and second floor 9'-0", per the plan room tags. Basement: **VERIFY** from the wall section. |
| Orientation | The front faces **west**, from the elevation titles (Right = South, Left = North, Rear = East). |
| Structure | Wood frame, poured concrete foundation and basement, 6x6 posts, beams per `S-Flor-Beam`. Use the drawings; do not redesign. |
| Exterior | Brick veneer with rowlock and soldier courses, siding, stone, metal accent roofs, shingles. Colours per ACC Material Package, Lot 7 column. |
| Software | SketchUp Pro 2026 and LayOut, V-Ray 7.4. Model built by Ruby scripts so every step is repeatable. |
| Units | Imperial, feet-inches, 1/8" display precision. Model internals in inches. |

## 2. Assumptions (VERIFY = check with the Village or the architect)

| # | Assumption | Source | Status |
|---|---|---|---|
| A1 | Residential code: 2018 IRC with Village amendments; 2021 IECC with Illinois amendments | Lot 2 set (same Village); confirm on Lot 7 A-001 | VERIFY |
| A2 | Ground snow load 25 psf, frost depth 42", wind 90 mph, seismic B | Lot 2 T1.0 | VERIFY |
| A3 | Zoning, setbacks, height and lot coverage are **not** in our files. No site plan or plat for Lot 7. | – | VERIFY with the Village and the plat |
| A4 | Utilities (well and septic vs municipal) unknown | – | VERIFY |
| A5 | Grade around the house is taken from the elevation grade lines (`A-Elev-Grad`) | xelev DWG | Assumption, shown as such |
| A6 | Wall build-up follows A-400 / `xflr0` wall section. Until that is measured, assume 2x6 exterior, 1/2" sheathing, 1" air space and 3-5/8" brick (≈11-1/8") or siding (≈7"), and 2x4 interior with 1/2" drywall each side (4-1/2"). | A-400 | To be measured |
| A7 | DWG dimensions run to face of stud / framing. Openings are dimensioned to centre line. | Plan dimension strings | To be confirmed in step 1 of the workflow |

## 3. Why the model is being rebuilt

Models v1 and v2 corrected the owner's SketchUp model in place, which left four problems:
- **Exterior only.** The model is a shell, with no floors, interior walls or stairs.
- **Levels off.** The levels sit 11–13" low.
- **Roof from mixed sources.** The roof came from sources that disagree with each other.
- **Unstructured model.** The groups are loose, with no levels, tags or scenes.

The new model is built from the DWG drawings. The owner's model remains a visual reference only.

## 4. Sources and priority

When the drawings disagree, the higher source wins. The conflict is listed as an open question and is not resolved silently.
1. Floor plan DWGs `xflr0/1/2`: walls, openings, dimensions.
2. Elevation DWG `xelev`: heights, window and door sizes, cladding zones, roof heights.
3. Wall section (`xflr0`) and A-400: datums, plates, brick ledge, floor build-up.
4. A-220 roof plan, where it matches 1–3.
5. ACC Material Package, Lot 7 column: materials and colours.

## 5. Model organisation

### 5.1 Setup
- **Template:** Architectural, inches. Units ft-in with 1/8" precision.
- **Geo-location:** South Barrington, IL (≈42.09° N, 88.15° W). True north is rotated so the front faces west.
- **Shadows:** CDT time zone, used for the hero views.
- **Origin:** DWG plan coordinates; z = 0 at the first-floor top of subfloor. The transform is recorded in the change log.

### 5.2 Hierarchy (one top-level group per level)

```
JESB_Lot7_House
├─ B  – Basement      (S-FOUND footings/walls, A-SLAB, A-WALL-INT, A-STAIR, M-EQUIP)
├─ L1 – Level 1       (A-FLOOR, A-WALL-EXT, A-WALL-INT, A-DOOR, A-WIND, A-STAIR, A-CASEWORK)
├─ L2 – Level 2       (same as L1)
├─ RF – Roof          (A-ROOF, A-ROOF-TRIM: fascia, frieze, soffit, gutters)
├─ EX – Exterior      (porch, terrace, guards, columns, steps)
└─ ST – Site          (L-TOPO terrain, L-SITE driveway and walks)
```

### 5.3 Tags

| Tag | Content |
|---|---|
| L-SITE | Driveway, walks, site flatwork |
| L-TOPO | Terrain mesh |
| S-FOUND | Footings, foundation walls, brick ledge |
| S-FRAME | Beams, posts, columns (structural, simplified) |
| A-SLAB | Basement slab, garage slab, porch and terrace slabs |
| A-FLOOR | Floor systems at L1 and L2 |
| A-WALL-EXT | Exterior walls (framing and cladding as separate faces/materials) |
| A-WALL-INT | Interior partitions |
| A-DOOR | Door components |
| A-WIND | Window components |
| A-STAIR | Stairs, handrails, guards |
| A-ROOF | Roof planes |
| A-ROOF-TRIM | Fascia, frieze, soffit, gutters, downspouts |
| A-CASEWORK | Kitchen, bath vanities, laundry (box level) |
| A-FIXT | Plumbing fixtures (simple proxies) |
| M-EQUIP | Furnace, water heater, sump (boxes) |
| ANNO-TEXT | Room names |
| ANNO-DIM | Dimensions for plan scenes |
| REF-DWG | Imported architect DWGs, hidden |

All raw geometry is on Untagged inside groups; tags go on groups and components only.

### 5.4 Components and naming
- **Doors and windows:** one definition per size and type, named by the architect's tag, e.g. `WIN 3060 SH`, `DR 3080 Entry w-(2) 1680 SL`, `OHD 16x8`.
- **Openings:** cut through the wall groups by script.
- **Names:** all groups and components in English. Materials named after the ACC selection, e.g. `Brick - <ACC name>`.

## 6. Modelling order

1. **Grid and levels:** basement slab, L1, L2 and plate heights, from the wall section and elevations.
2. **Foundation and basement:** walls, footings, brick ledge, slab, egress windows and wells, sump.
3. **Floor systems:** L1 and L2 at their true depth, with stair openings and open-to-below areas.
4. **Exterior walls:** from the plot-PDF wall outlines, checked against the dimension strings.
5. **Interior walls** on all levels.
6. **Openings, windows and doors:** sizes from plan tags, heights from the elevations.
7. **Roof:** envelope method (as on Lots 19/20), checked against A-220 and four elevations. Then fascia, frieze, soffit and gutters.
8. **Stairs:** main 18R, basement 16R, garage 5R, terrace 6R. Includes code checks on risers and treads (7-3/4" max riser, 10" min tread) and on headroom.
9. **Casework and fixtures:** kitchen, island, baths and laundry at box level.
10. **Exterior details:** porch, terrace with 42" guards and C1 columns, trim bands, rowlock and soldier courses.
11. **Site:** terrain from the grade lines, driveway, walks.

## 7. Documentation (LayOut)

| Sheet | Content | Scale |
|---|---|---|
| A0.0 | Cover, sheet index, perspective, project data | – |
| A1.0 | Site / roof plan (house only until a plat exists; VERIFY) | 1/8" = 1'-0" |
| A2.0–A2.2 | Basement, first floor and second floor plans (section planes at 4'-0" above each floor) | 1/4" = 1'-0" |
| A3.0–A3.1 | Four elevations | 1/4" = 1'-0" |
| A4.0 | Two building sections and a wall section | 1/4" and 3/4" = 1'-0" |
| A5.0 | Axonometric and hero perspectives | – |

- **Format:** title block per the Projades template (Arial, colours #17332F / #27766E / #B1663C).
- **Sheet size:** the company template is A3. 1/4" plans of this house need ARCH D (24x36), so a decision is needed (see 11).
- **Styles:** cut lines heavy with poché fill, beyond lines medium, hidden lines off.
- **Door and window schedules:** generated from the component names.

## 8. Visualisation (V-Ray 7.4)

- **Palette:** per the ACC list for Lot 7. Interior finishes are not in scope unless asked.
- **Hero views:**
  - front three-quarter, 35 mm, fall afternoon about 4 pm (west light on the front);
  - rear terrace, 28 mm, summer about 7 pm;
  - optional winter snow scene.
- **Elevations:** use the established recipe (`brain.md` section 7, V-Ray notes).

## 9. Quality control (before each milestone)

- [ ] No reversed faces visible; no stray edges.
- [ ] No raw geometry outside groups; no geometry on the wrong tag.
- [ ] Every level group at the correct z; floors and plates match the datums.
- [ ] No z-fighting at cladding and trim.
- [ ] Model purged of unused components and materials.
- [ ] DWG overlay check on four elevations and three plans.
- [ ] Dimension check table, with a target of ¼" on walls.
- [ ] Every drawing conflict listed as an open question.

## 10. File naming

| Item | Name |
|---|---|
| Working model | `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R01.skp`; each revision is a new file |
| LayOut | `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Model_Set_R01.layout` and `.pdf` |
| Exports | `04_Visualization/Exports/R01/JESB_Lot7_R01_<View>.png` |
| Change log | `00_Project_Admin/JESB_Lot7_Model_R01_Change_Log.md` |
| Scripts | `tools/lot7_rebuild/` |

## 11. Open questions (answer before modelling starts)

1. **Scope.** Model the architect's design as drawn, with no concept options or redesign, and raise design and code comments as review items?
2. **Interior depth.** Interior walls, doors, stairs, and casework and fixtures at box level, with no furniture?
3. **Site.** Is there a plat or survey for Lot 7 (lot size, setbacks, grading, utilities)? Without one, the site is limited to terrain from the elevation grade lines.
4. **Sheets.** The Projades A3 template at 1/8" scale, or Projades-styled ARCH D 24x36 sheets at 1/4"? Is Projades the correct company identity, and is there an official logo file?
5. **Renders.** V-Ray hero views in R01, or model and drawings first and renders in R02?
