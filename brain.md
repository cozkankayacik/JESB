# JESB — Project Brain

Last updated: 2026-10-15. Working notes for Jade Estates, South Barrington. Keep this file current as decisions land.

## 1. Project

- **Jade Estates** — residential development in South Barrington, Illinois. Owner: Projades (same owner as Derby Estates, `C:\Projects\DerbyEstates`).
- Two lots are in this folder: **Lot 2** (a new two-storey single-family house with a walk-out basement and a 3-car garage; sections 2–6) and **Lot 20** (section 7a).
- Architect of record: **John Anthony Nelson**, John Nelson – Architect, Inc. (CBO, Architect, NCARB), 1420 Whispering Spring Circle, Palatine IL 60074. IL# 001-009966, expires 11/30/26. Initials "JN" = checked.
- Drafting: **Serrato Smart Solutions** — Jesus Serrato, 847.815.8557. Drawn by "LE".
- Status: preliminary. Title block date 1/24/26; revision row dated 10/5/26, issued for "ACC meeting, preliminary items". Project number is unfinished ("2026-").
- Work so far: Lot 2 SketchUp model taken from v1 to v4 against the 10/5/26 set, elevation exports, V-Ray and AI renders, a review report; Lot 20 DWG-vs-model comparison and model v2 (see section 8).
- The development has more lots than the two in this folder: the ACC tracker lists Lots 2, 3, 4, 6, 7, 8, 9, 10, 11, 16, 19, 20, 21, 23 (section 7b).

### Working conventions (from the user)

- The user chats in Turkish (sometimes English); **all deliverables and files are in English**.
- Each model revision is a **new file** `JESB_LotN_v[X+1].skp` with its own `exports_vX/` (four elevations + one perspective PNG) and a change log listing changes and open questions.
- Touch nothing outside the requested revision. Where the DWG is unclear, do not assume; record an open question and let the owner decide.
- Detail level follows the existing model: do not add gutters, downspouts, fascia or soffits unless asked.
- The user edits the models in SketchUp themselves and drops reference images into the export folders. Never save over their files; open a copy.
- Keep this file current and commit + push after each piece of work (section 2, Git).

## 2. Files

| Path | What it is |
|---|---|
| `LOT2/Lot 2 _revisions1.dwg` | **Current working drawing.** AC1032 (2018 format), 715 KB, saved 2026-10-06. Note the space before `_revisions1`. |
| `LOT2/Lot 2_revision1.pdf` | 11-sheet plot of the set, 36x24, plotted 2026-10-05 from AutoCAD LT 2027. |
| `LOT2/JESB_LOT2_SKETCHUP.skp` | Original SketchUp 2026 model (2026-09-09), treated as **v1**. Keep untouched. |
| `LOT2/JESB_Lot2_v2.skp` | v1 plus the 10/5/26 exterior revisions (entry tower roof, garage doors). Superseded by v3. |
| `LOT2/JESB_Lot2_v3.skp` | v2 plus owner decisions: all roofs rebuilt with 12" overhang, garage doors at plan positions, driveway widened. Superseded by v4. |
| `LOT2/JESB_Lot2_v4.skp` | **Current model.** v3 plus terrain from the elevation grade lines, entry foundation/piers/steps down to grade, brick above the entry canopy. |
| `LOT2/JESB_Lot2_vN_Change_Log.md` (v2, v3, v4) | What changed in each version and the open questions. |
| `LOT2/exports_vN/` (v2, v3, v4) | Four elevations and one perspective PNG per version. |
| `LOT2/exports_v4_new/` | User-created folder: v4 views, `JESB_Lot2_v4_Elevations.pdf`, `renders_vray/` (V-Ray renders + PDF), `renders/` (AI visualizations from another session). |
| `LOT2/Reviews/2026-10-06/` | EN/TR review of Lot 2 made by another session. |
| `LOT20/` | Lot 20 drawings, model, v2 model, comparison report (section 7a). |
| `ACC MATERIAL PACKAGE.xlsx` | ACC material list, sheet EXTERIOR, one column per lot (section 7). |
| `tools/session1_scripts/` | Ruby / Python / PowerShell / .scr scripts from the first session (SketchUp inspect, revise, export, V-Ray, DXF overlay, PDF build). Reference copies: they contain hard-coded paths to that session's temp scratchpad, so adjust paths before reuse. |
| `tmp/python-libs/` | PyMuPDF, ezdxf, numpy for the Codex-runtime Python (section 7). |
| `session_archive/` | Transcript export of the first JESB session (run from the Derby Estates project, deleted there 2026-10-07) and the five images the user sent in it. |

**Git:** https://github.com/cozkankayacik/JESB.git, branch `main`, since 2026-10-07. Git LFS for dwg / skp / pdf / png / jpg / xlsx. Ignored: `tmp/`, `session_archive/`, `*.bak`, `*.skb`, `*.err`, `*.log`, `*.dxf`. Commit and push after each meaningful piece of work, with brain.md updated in the same commit. System `git` is not on PATH; use `C:\Users\ozkan\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\git\cmd\git.exe`. No README.

## 3. The house (from the 10/5/26 set)

| Area | sf |
|---|---|
| First floor | 2,511 |
| Second floor | 2,512 |
| **Total living** | **5,023** |
| Garage | 916 |
| Unfinished basement | 2,391 |

- **First floor:** foyer (open to above), flex, office, powder, mudroom, pantry, kitchen with island, dining (rear bump-out), family room (open to above), Bedroom 5 with bath and W.I.C., 3-car garage, rear patio.
- **Second floor:** master bedroom, master bath, two master W.I.C.s, Bedroom 2 / 3 / 4, Bath 3 / 4 / 5, laundry, W.I.C.s.
- **Basement:** unfinished, walk-out at the rear, rough-in bath, ejector pit, 75-gal water heater, 90% gas furnace. Garage and porch areas unexcavated.
- **Overall footprint:** about 78'-4" wide; garage wing about 22'-8" x 40'.
- **Exterior:** brick veneer with stone veneer base and stone entry surround on the front; Hardie panels on the rear with brick at the walk-out level; 8" frieze board and fascia, aluminum gutters, fiberglass shingles.
- **Roof:** hip roof, 6:12 pitch, pre-engineered trusses at 24" o.c.
- **Structure:** wood frame, TJI floor joists at 16" o.c., LVL headers and beams, steel W-beams (W10x19 in basement, W12x26 and W14x30 at first floor), steel pipe columns on concrete pads.
- **Key elevations:** T/first floor about 100'-4 3/4" datum; T/second floor about 111'-8"; top plate about 120'-9".

### Design criteria and codes (sheet T1.0)

- Ground snow load 25 psf; wind 90 mph (3-second gust); seismic category B; frost depth 42"; weathering severe; ice barrier underlayment required.
- Loads: roof 30 live / 10 dead; floor 40 live / 10 dead (60 for stairs and exterior decks); walls 20 wind.
- 2018 IRC with amendments; South Barrington Residential Building Code (Title 8, Area A); Illinois Plumbing Code; 2021 IECC with Illinois amendments; Illinois Radon Resistant Construction Act; 2017 NEC.
- Third-party duct tightness test and blower-door test (max 5 ACH) required.

## 4. Sheet index

| Sheet | Content |
|---|---|
| T1.0 | Title page, general notes, insurance requirements, codes, square footage, climatic criteria. Index says "site plan" but none is drawn. |
| 1 | Front elevation, roof plan, lintel schedule, loads, firestopping notes |
| 1.1 | Rear elevation |
| 1.2 | Left and right side elevations |
| 2 | Foundation plan |
| 3 | First floor plan |
| 4 | Second floor plan, light and ventilation schedule |
| 5 | First and second floor electrical plans, legend, notes |
| 6 | Building sections A-A, B-B, C-C; waste/vent and water riser diagrams |
| 7 | Wall sections and details (radon system, stair, post, ground electrode, island venting, tub insulation) |
| 8 | Specifications |

## 5. DWG anatomy

- Model space units: inches (architectural). One paper layout, `Layout1`, with 2 viewports. Internal sheet-set name: "Lot 2 Projades walk out NEW_recover".
- About 7,000 lines, 1,100 polylines, 95 MTEXT, 57 hatches, 96 block inserts. 52 layers.
- Layer scheme by number prefix: `1-*` elevations (WALL, WINDOW, DOOR, TRIM, GUTTERS, HATCH, NOTES), `2-*` foundation (FOOT, WALL, STRUCT, FIXT), `3-*` floor plans (WALL, DOOR, WIN, CABINET, STAIR, ELEC, FIXT, STRUCT, TITLE, NOTES), `4-*` roof, `5-REVISIONS`. Plus `A-Area`, `A-Flor-Dims`, `A-Wall-*`, `Data`, `!grid`, `!ELEV-HTS`.
- Room names are MTEXT on `3-TITLE`; drawing titles on `1-NOTES`, `2-TITLE`, `3-TITLE`.
- Blocks: `GUTTER` (21), `SWG-*` door swings, `Sink Bowl`, `16080 OHDOOR 16P` (two 16' overhead doors), `4040 BSMT ESC WND` (basement escape window), appliances.
- A block still holds an older first-floor plan with different room names (BEDROOM / SUITE, DEN, "3-CAR GARAGE", FOYER, 2-2x12 headers).

## 5a. SketchUp model anatomy

- House sits at about x 2752–3703, y 6425–7145, z -73..392 (inches). Front faces -Y, garage doors face -X (side-load, "left" elevation). A scale figure (`Sree`) stands at the origin, far from the house.
- Everything is on `Layer0`; the tags named like DWG layers come from an old hidden import (`Lot 2 Shah S Barrington WD base.dwg`). No scenes.
- Walls, windows and trims are loose top-level groups (`Group#n`). Eave level z = 260.79, pitch 6:12, shingle material `Material3`.
- Roofs in v3: `Group#53` (pid 212244) contains one solid, `Roof - Main (12in overhang, Rev 10-5-26)`; plus top-level `Roof - Dining (12in overhang)` (eave z 138.04, 4:12 sides) and `Roof - Rear Lean-to (12in overhang)` (eave z 122.04). Eaves are 12" off the model's exterior wall faces.
- The main roof is a union of 6:12 hip rectangles (west, main, front bay, rear bump, east wing, right bay, entry tower capped at the east-wing ridge height) merged with `Group#outer_shell`. That reproduces the DWG roof plan exactly; rebuild it the same way if walls move.
- DWG-to-model offset for the roof plan is (-7873.70, +4684.40). West and front walls match the DWG wall lines exactly; east and rear main walls are about 5" further out, the rear garage wall and the north wall of the east wing about 10".
- Garage doors: component `Garage Doors` (wraps `Big Garage Door`), 16' x 8', two instances, openings at y 6567.40–6759.40 and 6784.40–6976.40 (plan positions). Driveway slab is loose top-level faces, y 6562.07–6981.73.
- Hidden tag `REF_DWG_Rev_2026-10-05` holds the 10/5 DWG, roof plan aligned to the house.
- **Vertical datum:** DWG elevation Y minus 246.14 = model z (garage door bottom / slab = -3, top of stone sill = 51, eave = 260.8). The model's lower walls were built from these elevations: brick steps and concrete limits on the east and rear already matched.
- **Elevation-to-model horizontal mapping:** front elevation X - 7916.70 = model x; right elevation X - 5886.97 = model y; left elevation 16565.04 - X = model y; rear elevation: anchor on the dining room (X 13691.14 = model x 3349.6, X decreasing with model x increasing).
- **Terrain (v4):** group `Terrain (grade per elevations, Rev 10-5-26)`, material `Terrain_Grade`, a grid mesh from a piecewise grade function, cells inside the footprint skipped, with a perimeter skirt to z -150. Key grades: -3 driveway side, 0/-2/-4 front left, -16.2 entry and right bay, -17.9 to -72 along the east wall, -72 walk-out, +8.8 patio. The model had no ground before v4.
- Entry: front door and stoop sit 12"–16" higher than drawn (pre-existing, not corrected); stoop has six risers in v4. Boxes added below z 0: tower foundation (concrete), two pier bases (stone), two step blocks.
- Materials: `Material` = stone veneer, `Material1` = brick, `Material5` = siding, `Material3` = shingles, `Material2` = deck, default (unpainted) faces read as white concrete.

## 6. Open observations

Noticed while reading the set; none confirmed with the user or architect yet.

1. T1.0: left half of the sheet is blank and the drawing index lists a site plan that is not there.
2. T1.0: title block sheet name reads "Exterior Elevations" instead of a title-page name.
3. Project number incomplete ("2026-") on every sheet.
4. Revision clouds on sheet 1 (front elevation and roof plan, right side) and sheet 3 (garage side wall) — presumably the 10/5 changes.
5. `A-Area` layer has four area labels (1,935 / 1,761 / 1,808 / 1,077 sf) that do not match the T1.0 table; likely leftovers from an earlier plan. One area field shows `####`.
6. Sheet-title mismatches: index says sheet 1 is "Exterior Elevations & Roof Plan" but that title is on 1.2; sheet 3 is titled "First Plan".
7. General notes contain renovation boilerplate ("modify existing ductwork", "existing supply to remain") although this is new construction.
8. Sheets 5, 7 and 8 were read as text only, not reviewed visually.

9. Sheet 4 ventilation schedule: master bath requires 202.4 CFM, selected 200 CFM (from the 2026-10-06 review).

### Lot 2 review of 2026-10-06 (`LOT2/Reviews/2026-10-06/`, made by another session against v3)

- EN and TR reports plus `Evidence/` (all 11 PDF pages as images, v3 elevations, ventilation close-up), `Data/` (DWG text/block data, model bounds, roof lines, PDF text) and copies of the v2/v3 change logs.
- Seven findings: (1) terrain/exposed foundation misleading in the model — **addressed in v4**; (2) no site or grading plan in the set — open, architect; (3) 8" fascia/frieze and gutters not modelled — open, and deliberately not added so far; (4) white surface above the entry instead of brick — **fixed in v4**; (5) ventilation schedule 202.4 vs 200 CFM — open, architect; (6) stale `A-Area` labels — open, architect; (7) sheet titles, project number, renovation boilerplate — open, architect.
- Its recommended order: align DWG and SKP wall boundaries and settle the overhang reference face; complete terrain, driveway and walk-out grades; match cladding and eave details and re-export; then the drawing corrections.

### Lot 2 open decisions (model)

1. Correct stone (to Valders Dovewhite), trims/sills/corner boards (to white), soffit/fascia (black) and add black gutters/downspouts per the ACC list, then re-render? A larger stone sample image is needed; the one in the workbook is 226x212 px.
2. Lower the front door and stoop 12"–16" to the drawn height (drawing shows four risers, model needs six)?
3. Patio deck top: +16.9 in the model, +8.8 drawn.
4. 12" overhang measured from the wall face (used) or the framing line (roof plan reading)?
5. Model walls 5"–10" outside the DWG lines at the rear and east; rear garage pier 51" vs 46".
6. Flat patch (about 12" x 17") on top of the entry tower roof as drawn — ask the architect.
7. Driveway margin 5.3" beyond the door jambs and all ground away from the walls are assumptions; no site plan.

## 7. Tooling notes

- AutoCAD LT 2022 (`C:\Program Files\Autodesk\AutoCAD LT 2022\accoreconsole.exe`) and SketchUp 2026 are installed. The DWG was last plotted from LT 2027 on another machine; LT 2022 opens it fine.
- **Always run accoreconsole on a copy of the DWG**, never the source: a `DXFOUT` + `QUIT` script re-saves the drawing. LT is script-only (.scr), no LISP.
- Python: `C:\Users\ozkan\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe` with `sys.path.insert(0, r"C:\Projects\JESB\tmp\python-libs")` gives PyMuPDF and ezdxf (copied from `C:\Projects\DerbyEstates\tmp\python-libs` on 2026-10-07 so JESB does not depend on the Derby folder). System `python` is only the Store stub; no poppler.
- PDF: title-block and note text is real text; room labels and dimensions are SHX geometry. Read those from the DWG/DXF or by rendering pages with PyMuPDF.
- The `.skp` is a zip container; `meta/model_thumbnail.png` gives a quick preview without opening SketchUp.
- **Driving SketchUp without the UI:** `SketchUp.exe -RubyStartup <script.rb> <model.skp>` runs a Ruby script against the model; wait in a `UI.start_timer` until `active_model.path` is set, write a done-file, then kill the process from PowerShell. Works for inspection, edits, `model.save(new_path)`, `model.import(dwg, false)` and `view.write_image`. Always work on a copy and save to a new name.
- SketchUp's DWG import moves the drawing's minimum corner to the origin, so DWG coordinates are not preserved; align by measuring a known layer (e.g. `4-ROOF`) after import.
- **V-Ray 7.4 for SketchUp is installed and scriptable** (docs: `C:\Program Files\Chaos\V-Ray\V-Ray for SketchUp\extension\documentation`). Recipe: `ctx = VRay::Context.active`; inside `ctx.scene.change { }` set `/SettingsOutput` `img_width`/`img_height`, `/SettingsColorMapping` `adaptation_only = 0` (otherwise the saved PNG is linear and looks dark), `/SettingsImageSampler` thresholds 0.01, `/CameraPhysical` `shutter_speed` about 520; `VRay::Command.render_production`; poll `ctx.renderer.state` until `:idleDone`; `ctx.renderer.save_vfb_image(path)` (one argument; also writes `.Alpha.png`). Parallel-projection cameras render correctly. About 60–70 s per 2400x1500 elevation. `VRay::Licensing.license?` returned false but renders came out clean.
- Sun for elevations: set `shadow_info['ShadowTime']` (21 June, hour giving ~38° altitude) and rotate `NorthAngle` per view so the sun comes from the viewer's front-left. The sky is a flat grey in parallel views, so a gradient sky is composited behind using the alpha file (`tools/session1_scripts/post_render.py` logic: +0.45 stop, slightly cooler white balance, sky gradient, PDF).
- **ACC material package, Lot 2 (EXTERIOR sheet, B10:B32):** roof Charcoal; brick Whitestone Brickcraft; stone Valders Dovewhite Dimensional Splitface; siding White; trims White; soffit/fascia Black; gutters and downspouts Black; front door Black; windows/patio doors Black; garage doors Black, "long raised with glass on top". Model vs list: stone texture is a tan "fond du lac machine cut veneer" (list: near-white Valders Dovewhite); trims/sills/corner boards are grey `M03_Pewter_Shine` (list: white); soffits unpainted white and no fascia (list: black); gutters and downspouts not modelled. Roof, brick, siding, windows, doors and garage doors agree.
- The automation runner force-closes every SketchUp process when it finishes. The user also works in SketchUp directly, so check that SketchUp is not open before running it, and always open a copy of their file.
- `Face#pushpull` extrudes along the face normal: make the base face point up before a positive pushpull, and check the resulting bounds.
- A terrain surface with no thickness disappears in elevation exports (seen edge-on); give it a skirt.
- `model.import` zooms to extents, which changes the camera that gets saved with the file. Capture the camera before importing and restore it before `model.save`; check the perspective export's file size (a ~50 KB PNG means the house is a speck).
- `entities.transform_by_vectors` is the safe way to move wall jambs or wall tops inside an existing group.

## 7a. Lot 20

- Folder `LOT20/`: `Lot-20 base rend.dwg` (current, cleaned base without clouds/dimensions, saved 2026-10-07), `Lot-20-ACC response.pdf` (11 sheets, 10/5/26), `JESB_LOT20_SKETCHUP_MODEL.skp` (52 MB, 2026-09-09).
- House: two storeys plus full basement, 3-car side-load garage wing (16' + 9' doors on the right side, one 9' on an angled wall, a 9' door at the rear), rear balcony over a covered patio. Rooms: foyer, den, dining, kitchen, pantry, mudroom, family room, bedroom suite on the first floor; owner's suite, bedrooms 2 and 3, loft, laundry, balcony above.
- DWG layout (model space, inches): elevations along y -2280 (= slab level) at x about -6540..-5440 (left), -5020..-3960 (front), -3560..-2460 (right), -2280..-1240 (rear); roof plan x -4953..-4041, y -725..163; foundation, first and second floor plans at y 499..1435 (x -6124.., -4929.., -3729..).
- SketchUp: the whole house is one top-level group (pid 198219) at x 12315–13223, y 3330–4347, z 0–374; front faces -Y; sub-groups per wall, window and roof piece. A scale figure sits at the origin, so frame views on the house group, not on model bounds.
- Comparison of 2026-10-07 is in `LOT20/comparison_2026-10-07/` (report + overlay images). Main differences: front upper windows 3 â†’ 2, siding horizontal â†’ vertical board and batten, three left-side windows 12" toward the rear, ridges 7.6" / 14" higher, roof vents, fascia/gutters, basement windows and grade. The model has not been changed.
- Comparison method that worked: rasterise DXF lines with PIL (ezdxf's drawing add-on gave black images), export model views with a known scale, brute-force the best x/y shift against an edge map, draw the DWG in red. A vertical best-fit can be pulled off by roof differences; trust the window fit.

- Model v2 (`JESB_Lot20_v2.skp`, `exports_v2/`, change log, `textures/board_batten_white_16in.jpg`): front upper wall windows and board-and-batten siding done. **Still open from the comparison (after v3):** three left-side windows 12" toward the rear; four roof vents; gutters and downspouts; full basement with four 48" x 48" escape windows and a grade line (model stops at the slab, no ground); balcony / covered patio depth (left elevation shows 15"–20" more than the model, right elevation agrees with the model — one DWG elevation may be wrong, measure from the plan); garage door style.
- **Model v3 (`JESB_Lot20_v3.skp`, current; `exports_v3/`, change log): roof rebuilt from the DWG roof plan and elevations.** The nine old roof groups (pids 173449, 173417, 151074, 150944, 150850, 150889, 165195, 151372, 151318) are gone; the roof is now two manifold solid groups in the house group, `Roof - Main (per DWG roof plan, v3)` and `Roof - Garage (per DWG roof plan, v3)`. This settles the roof heights and the 8" roof edge from the comparison; vents and gutters were not added.
- **Lot 20 DWG-to-model transform (exact, walls agree within 0.1"):** roof plan and floor-level plan x + 17273.64, y + 4111.42; elevation y + 2280 = model z. The front elevation uses the same x as the roof plan; left elevation x = -(plan y) - 6230.2. Model walls sit at the brick face (framing line + 5").
- **Lot 20 roof definition (DWG plan coordinates, eave lines 24" outside the framing line):** eave top 264.6 / fascia bottom 256.6 on the main roof, 142.8 / 134.8 on the garage. The roof is the upper envelope of hip bodies, all 6:12 on the main level: M2 (x -4784.84..-4210.84, y -317.42..150.58, ridge 381.6), M1 (east, eaves x -4054.84, y -317.42 / 138.58, ridge 378.6), NW (eaves x -4784.84 / -4431.84, y 162.58), LW left wing (x -4952.84..-4591.34, y -329.42..-47.42), a saddle between LW's north plane and the main south plane (DWG line at y -182.42), F2 (x -4485.34..-4205.84, south eave -333.42), F1 entry (x -4485.34..-4305.34, south eave -345.42), RB (east eave -4040.84, y -169.42..-9.42). Garage: side planes 4:12 (eaves x -4952.84 / -4640.84), front 6:12 (y -713.42), angled eave from (-4640.84,-452.58) to (-4608.91,-333.42) with a valley to the ridge end; front gable x -4880.84..-4712.84, south eave -725.42. `tools/lot20_v3_roof/roofgeom.py` holds this and regenerates the geometry; `build_v3.rb` builds it in SketchUp.
- DWG inconsistencies found on the roof (open, in the v3 change log): left wing drawn 282" wide on the roof plan but 287" on the elevations (ridge 335.1 vs 336.3; model follows the plan); garage roof at the angled wall shows a 201.1" point on the front and right elevations but a level 194.8" ridge on the left elevation and roof plan (model follows the plan, peak 195.7").
- Roof-building method that worked (reusable for other lots): describe each roof block as a convex set of planes, compute the upper envelope in Python as small planar cells, add the cells as faces in SketchUp, erase edges between coplanar faces, drop a vertical face from every free edge to the fascia bottom, close the underside with `find_faces`. Both groups came out manifold on the first run; SketchUp solid tools (`outer_shell`) were not needed.
- Board-and-batten is a texture, not geometry; batten spacing restarts on each wall piece, so battens do not always line up at joints. The 16" spacing comes from the DWG hatch pattern name, not a dimension.
- Interiors and floor plans of Lot 20 have not been compared.

## 7b. ACC material package (`ACC MATERIAL PACKAGE.xlsx`) – read fully 2026-10-17

- Title "South Barrington – Selection Tracker – Elevation". Sheet `EXTERIOR` (A1:AF34).
- **Lot columns:** each lot is a merged column pair. The left column holds the selection text, the right column the sample image.
  - Lot 2 = B/C, Lot 3 = D/E, **Lot 7 = F/G**, Lot 19 = H/I, Lot 20 = J/K, Lot 21 = L/M, Lot 23 = N/O, **Lot 16 = P/Q** (not R).
  - Lots 4, 6, 8, 9, 10, 11 (T, V, X, Z, AB, AD) are empty, selection 0.
- **Rows:**
  - row 3: status (Lot 2 Phase 1, Lot 3 Approved, Lot 7 Phase 1, Lot 19 Phase 2, Lot 20 Phase 1, Lot 21 Approved);
  - rows 4–8: SketchUp, video, colour scheme PDF, 3D elevations, blueprint names (those files are not here);
  - rows 9–31: odd rows are the item, the next row is "SELECTION" (1 = selected/confirmed, 0 = not).
  - Items: Roof, Brick, Stone, Siding, Siding dec, Trims, Soffit/Fascia (LP SmartSide), Gutters and downspouts, Front door colour, Windows/patio doors, Garage door colour, Garage door style.
- **Images:** 92 on EXTERIOR plus 15 on Sheet2. They are shared colour swatches, for example `image13` black, `image15` / `image14` whites, `image18` brown, `image11` Cobble Stone siding, `image16` black window, `image25` white window, `image28` brown window, `image6` cottage door, `image31` long-raised door.
- **Sheet2:** an unassigned lot or option.
  - Roof Charcoal, brick Cloud Grey Velour (Cloud Ceramics), stone White Country Squire (Buechel).
  - Siding Cobble Stone, siding dec Teratone, trims Cobble Stone, soffit/fascia Black, gutters Black.
  - Front door Teratone, windows Black, garage door Teratone, cottage with glass on top.
- **Tools:** `tools/acc_dump.py` dumps all cells and images with their anchor cells; `tools/acc_contact_sheet.py` makes a labelled contact sheet.

| Item | Lot 2 | Lot 3 | **Lot 7** | Lot 19 | Lot 20 | Lot 21 | Lot 23 | Lot 16 |
|---|---|---|---|---|---|---|---|---|
| Roof | Charcoal | Barkwood | **Mission Brown** | Grey | Charcoal | Barkwood | Barkwood | Charcoal |
| Brick | Whitestone Brickcraft | Avalon usbrick | **Magnolia usbrick** | Sand Dunes usbrick | Glen Gery Aspen White Wirecut | Bellevidere Brickcraft | White Plains Velour GlenGery | – (0) |
| Stone | Valders Dovewhite Dim. Splitface | no stone | **no stone** | Eden Machine Cut Veneer | Valders Dovewhite | Eden Windsor | White Country Squire Buechel | Eden Machine Cut (0) |
| Siding | White | White | **Cobble Stone** | Cobble Stone | White | Cobble Stone | Cobble Stone | Cobble Stone (0) |
| Siding dec | – (0) | White | **White** | Light Brown | Black | Cobble Stone | White | Natural Oak |
| Trims | White | White | **White** | Cobble Stone | White | Cobble Stone | White | Cobble Stone |
| Soffit/fascia | Black | White | **White** | Black | White | Brown | White | Black |
| Gutters/downspouts | Black | Brown | **White** | Black | Black | Brown | Brown | Black |
| Front door | Black | Brown | **Brown** | Light Brown | Black | Brown | Brown | Black |
| Windows/patio doors | Black | Brown | **White** | Black | Black | Brown | Brown | Black |
| Garage door colour | Black | Brown | **Brown** | Light Brown | Black | Brown | Sandstone (0) | Black |
| Garage door style | Long raised + glass top | Short raised, no glass | **Cottage + glass top** | Long raised + glass top | Long raised, no glass | Long raised + glass top | Cottage + glass top | Long raised + glass top |

- Lot 7 sample images are in `LOT7/00_Project_Admin/ACC_Material_Samples/` and `tools/lot7_rebuild/textures/acc_lot7/`, named by item.
  - Mission Brown is a brown-taupe blend architectural shingle (average RGB 94,83,75).
  - Magnolia is white and cream brick with grey and rust (207,202,195).
  - Cobble Stone is a light greige lap siding (184,180,163).
  - The brown is #4B392F.
  - The white window sample is a 6-over-6 double hung (colour reference only; Lot 7 grids follow the elevations).
- Lot 20's black "siding dec" has not been applied anywhere: the drawings do not show where it goes.
- **Owner instruction 2026-10-17:** material work for now is Lot 7 only. Do not model gutters or downspouts ("böyle şeylerle uğraşma"); keep to the materials.

## 7c. Lot 19

- Folder `LOT19/`: owner's model `JESB_LOT19_MODELLING.skp` (SketchUp, 26 MB), `JESB - LOT 19  ARCHITECTURAL PLAN_REVISION1.pdf` (Purohit Architects, 10 sheets, issued 10.15.2026 for Village ACC review #2; A-220 roof plan, A-300/A-310 elevations, 1/4" = 1'-0"), `xflr0/1/2_lot19.dwg` (floor-plan xrefs — walls are AutoCAD Architecture objects that do not survive DXFOUT; useless for the exterior), `cobble stone siding.png`.
- Model frame: inches, +x east, +y north, front faces south (-y). No house group — everything is loose top-level groups. Exterior wall faces at z 230: west 1181.5, east 1835.4, north 1794.7 (x 1184–1380) / 1822.2 (x 1380–1654) / 1952.2 (Br 2 wing x 1649–1829), south 1405–1417; front-left two-storey bay x 1232–1400, south 1109.4, west bump x 1194.4. Wall plates z 279. Materials: `Material5` shingles, `Material6` standing-seam metal, `Material9` siding (cobble stone siding.png), `Material` brick.
- **PDF vectors are the usable reference**: `tools/lot19/pdf_vectors.py` extracts the roof plan / elevations in model inches (page rotation 270 handled with `page.rotation_matrix`; 1 pt = 2/3 in. at 1/4"); alignment offsets come from `overlay_pdf.py` (FFT cross-correlation of drawing lines vs model edge maps, both at 2 px/in.). Sheet A-310 sits ~5" higher than A-300 after alignment.
- **A-220 roof plan contradicts the elevations and floor plans** (single 682 x 532 hip over everything, straight north eave over the deck). Elevations were followed; flagged in the v1 change log.
- **v1** (`JESB_Lot19_v1.skp`, current; `exports_v1/`; change log): roof rebuilt from the elevations as an envelope of hip blocks A–F (`tools/lot19/roof19.py`, same method as Lot 20 v3) + entry tower hip roof in metal (eave 310.2, 12" fascia) replacing the flat box. Walls/windows already matched and were not touched. Lower roofs within ~5", not changed. Exports with `tools/lot19/export_views.rb` (fixed framing centre 1505/1478/210, height 700) + `tools/lot19/mkpdf_views.py`.

## 7d. Lot 7

- Folder `LOT7/`: owner's model `JESB_SKETCHUP_LOT7.skp`, `JESB - LOT 7  ARCHITECTURAL PLAN_REVISION1.pdf` (A-220 roof plan, A-300/A-310 elevations, 1/4"), `xelev_lot 7G.dwg` + `xflr0/1/2_lot 7G.dwg` (note the "lot 7G" names).
- Model frame: inches, front faces south (-y); house x ~1630..2480, y ~3377..4246. Garage wing at the west/front (gable to the south), covered terrace at the rear east. Materials: `Material5` shingles, `Material1` siding, `Material metal`, `D01_Frost_White` soffit, `Brick_05_1K`.
- A-220 vectors map to the model **unrotated** (page up = +y, right = +x) and need +(11, -14.5) in. after correlation (the correlation locked onto the old roof, not the walls — check eaves ~12" outside the wall cuts with `tools/lot7/plot_plan_compare.py`). Heights: align on upper-floor window heads/sills, the DWG main-floor datum gives heights 13" low.
- **v1** (`JESB_Lot7_v1.skp`, current; `exports_v1/`; change log): all upper roofs rebuilt from A-220 (`tools/lot7/roof7.py` -> `roof7.json`, `tools/lot7/build_v1.rb`), east garage dormer added, west dormer raised, covered rear terrace roof + 4 brick columns with the deck moved 60.3" south, garage gable window re-placed. Open: first floor/garage ~11–13" low vs drawings, lower garage roof untouched, windows not audited. Exports `tools/lot7/export_views.rb` (centre 1950/3800/210, height 700) + `mkpdf_views.py`.

- **v2** (`JESB_Lot7_v2.skp`, current; `exports_v2/` + `dwg_overlay_checks/`; change log): matched to `xelev_lot 7G.dwg`. DWG -> model: z = Y - 1400.5 (window alignment; the main-floor datum gives 13" low — the model's floors/door sit ~12" lower than drawn but windows/eaves/garage doors match on windows), horizontal offsets in scratch `align2.json` (south C dx 118, north A dx -15, west B dx -154, east D dx 177; earlier correlation offsets for north/east were wrong — check on windows). Roofs `tools/lot7/roof7_v2.py`, build `tools/lot7/build_v2.rb` (from v1). **Lesson: a triangle on a front elevation is not necessarily a gable face** — check the side elevations (6:12 slope = hip end) and the plan hatch (hatched triangle in plan = sloped roof plane). Openings are moved by translating the wall-group vertices inside a y band (`band_move`), windows are nested in the wall groups.

- **2026-10-16 evening — Lot 7 restart.** The user judged v1/v2 not sufficient: the model is to be rebuilt from scratch from the DWG plans, in more depth, everything in English, with careful folders and formats, using the company's (Projades) templates and title blocks. LOT7 was reorganised to the Projades folder standard taken from `C:\Projects\HoffmanEstate` (`00_Project_Admin`, `01_Site_and_Reference`, `03_Shared_CAD_and_Models/{Xrefs,Models}`, `04_Visualization`, `05_Presentations_and_Issued`, `99_Archive`); paths are listed in `LOT7/00_Project_Admin/JESB_Lot7_Drawing_Register.md`. v1/v2 and their exports are in `99_Archive/Superseded_v1_v2/`; scripts in `tools/lot7/` still point at the old paths. Rebuild plan: `LOT7/00_Project_Admin/JESB_Lot7_Model_Rebuild_Plan_R01.md` (awaiting approval; new naming `JESB_Lot7_Model_R01.skp`).
- Architect DWGs keep their original names (`xflr1` and `xflr2` xref each other via `.\`). New issue 2026-10-16: `xflr0` and `xflr1` changed, `xelev` and `xflr2` unchanged.
- **Getting AEC walls out of the floor plans:** DXFOUT drops AutoCAD Architecture walls, doors and windows. The LT 2022 core console does load the AEC object enablers, so `-PLOT` of a copy to `DWG To PDF.pc3` gives a **layered vector PDF** with the walls. Settings: paper `ANSI full bleed E (34.00 x 44.00 Inches)` (exact name; script answers must not be quoted), portrait, window -200,-150 to 1000,1050, scale `1=48`, offset 0,0, `monochrome.ctb`. Script lines with spaces work unquoted for the device and paper prompts; an xref name with a space cannot be typed (use a wildcard).
- Elevation sheet titles say "Right side–South", "Left side–North", "Rear–East", so the Lot 7 front faces **west**. Old v1/v2 models used front = -y.
- **Company template (Projades):** `HoffmanEstate/00_Project_Admin/Brand_Templates`: A3 landscape 420x297, 10 mm border, title block at the bottom, Arial / Arial Bold, colours #17332F #27766E #B1663C, text wordmark "PROJADES". A copy is in `LOT7/00_Project_Admin/Brand_Templates/`. GStudio (Derby) is a landscape consultant's sealed title block; never use it.

- **Lot 7 model R01** (`LOT7/03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R01.skp`, **current**). Built from scratch, exterior only, in **DWG plan coordinates** (inches, z = 0 at the main floor 839.20', DWG elevation y 1429.31). Decisions of 2026-10-16: model as drawn, no interior, terrain from the grade lines only, A3 Projades PDFs, no renders. Pipeline in `tools/lot7_rebuild/`:
  - `pdf_plan_extract.py`: plot PDF to plan segments. The transform X = px/1.5 - 200, Y = (H - py)/1.5 - 150 is exact.
  - `openings.py`: plan glazing spans plus elevation window units. Windows on xelev are exploded lines on layer `ARWINDOW`/`ARDOOR`, clustered by connectivity.
  - `grade_profiles.py`.
  - `lot7_r01.py`: roof envelope bodies, wall slabs with a top profile = underside of the covering roof group, boxes, terrain â†’ `r01_spec.json`.
  - `build_r01.rb`.
  - `run_build.ps1`: opens a copy of the owner's model only to reuse its textures, then erases everything.
  - `overlay_check.py`: QA overlay of xelev on the exports.
  - `make_a3_set.py` + `sheets_r01.json`: A3 set in the Projades layout.
- Lot 7 drawing mappings: elevation x = plan x + 6482.98 (front/west), 4411.64 - plan x (rear/east), plan y + 7598.36 (south), 6134.36 - plan y (north). The side elevations are about 5" inconsistent. A-220 roof plan PDF page 6: plan = (pt·2/3 - 171.0, -pt_y·2/3 + 1332.82) with `rotation_matrix`; it is not rotated or mirrored against the plans. Automatic line voting failed on it (gutter hatch); anchor on the main eave rectangle instead.
- Lot 7 key heights (z): main eave top 248.87 (fascia 7.25), ridge 381.97; wing eave 201.12, ridge 300.85; bay dormers 234.5; garage eave 105.62; garage slab -38.1; terrace eave 112.37; gablet base 258.9, ridge 313.2; main plate 121.12, L2 floor 133.75, upper plate 242.87. Grades: front -38, rear -76, north -59.6..-76.
- **SketchUp API lesson (R01):** a group or definition that is created empty and filled *after* other geometry work in the same operation can be silently deleted ("reference to deleted Entities"); a placeholder edge or cpoint does not help. Build each group's geometry immediately after `add_group`, and compute topology (free edges, undersides) in Python instead of reading it back from SketchUp. Merge coplanar faces with tolerance (dot > 0.99999, plane distance < 0.05).
- **Wall-top rule that works:** sample the roof groups covering the wall's *interior* side (0.3" inside). First-floor walls stop at the lowest such group envelope, upper walls at the highest. Use the envelope (max of the group's bodies), not single bodies.

## 8. Log

- **2026-10-19** — Lot 19 model v7 (`LOT19/JESB_Lot19_v7.skp`, **current**; `exports_v7/`; change log), from the owner's v6 saved 12:06 (they re-textured `ACC Lot 19 - Siding dec - Light Brown` to a dark wood, now also on the deck boards). Rear deck railing (6 × `15.Balcony Railing`, whole definition incl. nested `skp39D2`) and 6 posts -> new plain `ACC Lot 19 - Railing - Light Brown metal` (RGB 145/118/92 = ACC I17 average). Deck steps (NW corner, x 1373–1383, risers 7.5, tread 10, y 1938–1997): post on the step removed, new metal stair railing on the north side (bottom post x 1361–1366 on grade, handrail at 0.75 slope from deck post 355024, bottom rail, ¾" balusters). Script `tools/lot19/build_v7.rb`. Deck geometry: Group#65 353190 (deck top 36.8, grade 21.8).

- **2026-10-19** — Lot 19 model v6 (`LOT19/JESB_Lot19_v6.skp`, **current**; `exports_v6/`; change log), from the owner's v5 saved 2026-10-19 10:19 (they had added `Material8`, a pale wood screenshot texture, on accent panels, entry door, garage doors and deck). Materials only: the 8 accent panel faces between windows (groups 352505, 351512, 348235, 334843, 334452, 347116, 346879) -> new `ACC Lot 19 - Siding dec - Light Brown` (ACC I17 image29, 19.3 x 20.2 in., horizontal lap); Cobble Stone `Material9` / `Material3` textures lightened 22 % towards white at the same size. Door/garage doors left on Material8 (ACC says Light Brown too — offered). Script `tools/lot19/build_v6.rb`. Tip: `material.texture.image_rep.save_file` exports an embedded texture; replace a texture with `mt.texture = file` then restore `texture.size` so existing UVs stay.

- **2026-10-17** — Lot 7 **model R12** (`JESB_Lot7_Model_R12.skp`).
  - The owner answered RFI-001.03 with "use the DWG", meaning the rear elevation. The main roof end hips are now `P_END` = 0.5 (6:12) and the ridge is 131 in; the rear elevation matches.
  - The front elevation and A-220 roof (9:12, ridge 308 in) no longer match, which the owner accepted. R11 keeps the A-220 roof.
  - The R12 renders were stopped when the R13 change came in.
- **2026-10-20** — Lot 7 **model R16** (`JESB_Lot7_Model_R16.skp`, **current**).
  - **The owner edited R15 by hand** (17:30). From now on, continue on the owner's model with scripted edits (`tools/lot7_rebuild/su_edit/*.rb`, run via `vray/run_su.ps1` on a copy and saved as the next R). **Do not re-run the generator** (`lot7_r01.py` / `build_r01.rb`): it would wipe the owner's edits.
  - R16 changes:
    - Lap siding is white (Dominika plus the DWG note "Arctic White"). This answers Q1.
    - Entry steps follow xelev: porch at −7.5, 4 risers, the bottom two wide in front of the piers, rails at x 358 / 454.
    - Garage bump corner follows the DWG: brick base, sill course, corner boards.
  - The second "check blueprint" point (garage/main junction) is downspouts in the DWG. Gutters and downspouts are not modelled (owner, 17.10), so nothing was changed there.
  - Still open: Q2 (headers to white?), Q3, Q5.
- **2026-10-20** — Lot 7 **model R15** (`JESB_Lot7_Model_R15.skp`). The changes come from Dominika's review of 19.10, mark-ups made on the R14 AI render; the check and plan are in `LOT7/00_Project_Admin/Reviews/`.
  - D01: garage front pent roof (`PG` body).
  - D02: water table 12.21–14.87 and sill course 22.87–24.87.
  - D03, D04: gable rake friezes and apex trim, using the new spec list `plates` (polygon trim in a wall plane).
  - D05: two-sash basement windows (`mull`).
  - D06: dormer side eaves in their own roof group, so the wing roof runs under them; plain wing walls use the `DORMERS` exclusion.
  - D07: garage slab inset.
  - D08: fascia merged; coplanar seams are split and hidden in `hide_wall_seams`.
  - Waiting:
    - Q1: all lap siding white (DWG note "Arctic White") vs ACC Cobble Stone.
    - Q2: headers to white trim vs the 17.10 cast-stone decision.
    - Q3: apex trim on the lower gable.
    - Q4: entry stair, cheek walls vs open.
    - Q5: arrow at the entry and eave junction.
  - Lesson: many mark-ups on AI renders are render artifacts (downspouts, white strips). Always check them against the model export and the DWG first.
- **2026-10-17** — **Owner: no more rendering by Claude; Astra takes the renders.**
  - No V-Ray render was running when the instruction came.
  - The pipeline in `tools/lot7_rebuild/vray/` is kept for reference only.
  - Open Lot 7 differences after R14:
    - Small garage door: the elevation draws 6 ft, but the plan labels "8'-0" x 8'-0" OVHD"; the model keeps 8 ft.
    - North vs south elevation garage end: ~10 in, contradictory drawings; the model follows the south view.
- **2026-10-17** — Lot 7 **model R14** (`JESB_Lot7_Model_R14.skp`). The owner said "fix to the DWG if sure".
  - The lower front gable now projects 20 in ahead of the main garage gable, as both side views agree (`LG_FRONT_Y` −11.64).
  - The garage gable rake is at 8.36 (`G_RAKE_Y`).
  - The garage door and the north end were not changed (not certain); reasons are in the R14 change log.
  - The elevation sheets note "James Hardie siding Arctic White"; the ACC says Cobble Stone. Reported to the owner, not acted on.
- **2026-10-17** — Lot 7 **model R13** (`JESB_Lot7_Model_R13.skp`).
  - The owner said: "siding deck white" for the covered terrace. The raised terrace deck and skirt are now white lap siding (`ACC Lot 7 - Siding Dec - White - Terrace Deck`, texture from `make_white_siding.py`).
  - The V-Ray renders are in `Renders/R13/`.
  - The phrase "siding dec white" was ambiguous. The owner meant the covered terrace, not the decorative panels or the lap siding on the house.
- **2026-10-17** — Lot 7 **model R11** (`JESB_Lot7_Model_R11.skp`). The owner answered RFI-001 (log: `00_Project_Admin/RFI/JESB_Lot7_RFI-001_Response_Log.md`).
  - The garage front is per the elevations (`geometry.GARAGE_BUMP_Y` 4.96 / `GARAGE_FACE_Y` 16.0; xflr1's 9.36 in shift undone).
  - Slider head is 84 in, the wing gable window is at x 138–162, and the entry door has six panels (build_r01.rb).
  - Items 04, 06 and 07 are kept as modelled.
  - **Item 03 is open:** the rear-elevation ridge (131 in) is geometrically incompatible with the front elevation and A-220 (311 in). The owner has to choose A or B.
  - The V-Ray renders are still R10 and will be re-rendered after item 03.
  - The run scripts now close only their own SketchUp instance; another process keeps a `source_copy` SketchUp open.
- **2026-10-17** — Lot 7 **V-Ray elevation renders R10**, in `LOT7/04_Visualization/Renders/R10/`. The owner found the earlier output poor and asked for V-Ray.
  - V-Ray for SketchUp (Chaos) is installed. It has a Ruby API (`VRay::Context.active`, `VRay::Command.export_vrscene`). Standalone `vray.exe` is in `...\V-Ray for SketchUp\extension\vray\bin`; set `VRAY_PLUGINS=<bin>\plugins` and pass `-camera=<scene name>`.
  - The scripted pipeline and its gotchas are in `tools/lot7_rebuild/vray/README.md`: orthographicWidth must be halved; the sky is a plate composited behind the image; `-camera` uses the scene's own CameraPhysical.
  - Renders take about 6 min per view at 3200 px. Run them detached with `Start-Process` and `Wait-Process`; the background tool times out at 10 min.
  - The owner asked for a cross-check of the renders against the DWG: `vray/render_dwg_check.py`, output in `Renders/R10/QA_Render_vs_DWG/`. Each render matches the model within 2 px.
  - The owner said not to change the model yet. **RFI-001** (English, Projades A3, `tools/lot7_rebuild/make_rfi.py`) is in `05_Presentations_and_Issued/RFI/` and `00_Project_Admin/RFI/`. It is waiting for the architect's answers; the model stays at R10 until then.
  - The terrace roof pitch was read as ≈5:12 in R01, but the overlay shows ≈6:12, matching the A-220 note. RFI item 04 proposes 6:12.
  - Nine model-vs-xelev differences were reported to the owner and **not fixed** in R10 (the owner answered later; see R11): garage west end 10–20 in; rear-elevation ridge contradicts the front elevation and A-220; terrace roof pitch; slider door head; south upper window; guest bay window widths; wing gable window; front door panels.
- **2026-10-17** — Lot 7 **model R10** (`JESB_Lot7_Model_R10.skp`, **current**).
  - The metal roofs use our own standing-seam texture (`make_seam_texture.py`). The owner seam texture read as tiles.
  - The owner gave a photoreal elevation prompt for an AI image tool (Corona look; grass, sky and the existing hardscape only; no trees, cars or props) and decided to keep the driveway as an assumption.
  - The AI input package is in `LOT7/04_Visualization/Working/AI_Render_Package_R10/`, made by `make_ai_render_package.py`. The owner runs the image tool; results go to `04_Visualization/Renders/R10/`.
- **2026-10-17** — Lot 7 **model R09** (`JESB_Lot7_Model_R09.skp`). Owner decisions:
  - Metal roofs dark brown bronze (tinted seam texture).
  - Headers stay light beige cast stone.
  - **Waiting for the owner before rendering:** engine (V-Ray proposed), views, light and season, site context (trees?), railings black iron?, the open drawing conflicts, delivery folder and format. Take no action on these until the owner answers.
- **2026-10-17** — Lot 7 **model R08** (`JESB_Lot7_Model_R08.skp`):
  - All finishes come from the ACC package (Lot 7, section 7b), with the sample images as textures at real scale, named `ACC Lot 7 - <item> - <selection>`.
  - Non-ACC materials are named `Not in ACC - ...`: metal roofs, cast-stone headers, railings.
  - Owner's original textures no longer used; gutters and downspouts not modelled (owner instruction).
  - Lesson: PowerShell `Get-Content`/`Set-Content` on UTF-8 files without `-Encoding UTF8` produces mojibake (`—` → `â€”`). Edit text files with the Edit tool, or pass the encoding; `tools/fix_mojibake.py` repairs them.
- **2026-10-16** — Lot 7 **model R07** (`JESB_Lot7_Model_R07.skp`):
  - Windows side by side (gap â‰¤ 13", same height) form a group with one continuous stone header and one surround (`opening_groups` in `lot7_r01.py`). Openings are sorted by (z0, z1, a), because the full-height rear wall carries both storeys.
  - Iron stair railings on the entry steps (widened to 363..449) and the terrace stair, via `stair_rail()` â†’ spec `sloped` bars, `sloped_bar()` in Ruby.
- **2026-10-16** — Lot 7 **model R06** (`JESB_Lot7_Model_R06.skp`): owner flagged roof errors at the wing / main junction. The north-front corner body A2 is now W 9:12 from -12, S **6:12 from y 388**, E 9:12 with eave **x 232**; this reproduces every A-220 line there (corner hip, short ridge x 110, cricket hip, wing valleys). The old x-46 hip was a guess and wrong. Owner decision: **keep the south gablet** (elevations), even though A-220 does not show it. New QA `roofplan_check.py` overlays A-220 on the model top view (sheet A-902). `next_sheets.py` derives the next revision's sheet list. Lesson: read the hip/valley/ridge *directions* on the roof plan and solve the planes from them (hip direction gives the pitch ratio); do not invent bodies to close a corner.
- **2026-10-16** — Lot 7 **model R05** (`JESB_Lot7_Model_R05.skp`): the front stair window is split into two stacked units (116.4..156.6 / 156.6..228.6) with a 2" transom and a cross in each, as drawn. Openings take `rows` (split heights) in the spec.
- **2026-10-16** — Lot 7 **model R04** (`JESB_Lot7_Model_R04.skp`), on owner request:
  - stone headers (8" cast stone over the first-floor openings);
  - window casings and second-floor surrounds (xelev layer `FINE`, green);
  - thin grid muntins on all windows, a cross per unit (xelev red `A-Elev-Glaz-Munt` / `A-Elev-Decking`);
  - frieze moved to 228.6..238.1.
  - Code: the "window / door surrounds" block in `lot7_r01.py`; muntins in `build_opening_unit` (`build_r01.rb`).
  - Material `Cast Stone - Window Header` is an assumption (ACC says "no stone").
- **2026-10-16** — Lot 7 **model R03** (`JESB_Lot7_Model_R03.skp`): the owner marked the decorative panels ("motifs") on the front elevation. All 7 `GENERAL_TEXTURE` panels of xelev were modelled as a white frame plus a speckled field (`DECO_PANELS` in `lot7_r01.py`; texture `tools/lot7_rebuild/textures/deco_panel_speckle.png` at 24"). The lower-gable infill uses the same material. The other red DWG layers remain unmodelled options: `A-Elev-Glaz-Munt` window grids (a cross per sash), `A-Elev-Door-Half` garage-door square panels, `A-Elev-Decking` / `A-Flor-Hral` stair rails.
- **2026-10-16** — Lot 7 **model R02** (`JESB_Lot7_Model_R02.skp`): the owner marked the garage-front roof on the front elevation. Changes:
  - lower 9:12 front gable over the 11" bump (eaves x -7/149.7, apex 164.4) with eave returns;
  - garage gable eaves at x -7/288 (apex 216.2, as drawn);
  - bump face as white panel with two decorative panels.
  - Files: `R02` exports, A3 set and change log. The pipeline takes `-Rev` in `run_build.ps1`; sheets in `sheets_r02.json`.
  - Lesson: in xelev the hatch `GENERAL_TEXTURE` is the white "siding dec" panel, `_USER` is siding, `PBRICK` is brick.
- **2026-10-16** — Lot 7 **model R01** issued:
  - model, exports and QA in `LOT7/04_Visualization/Exports/R01/`;
  - A3 set `LOT7/05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R01.pdf` (8 sheets);
  - change log `LOT7/00_Project_Admin/JESB_Lot7_Model_R01_Change_Log.md`, with 9 open drawing conflicts. The main one: the new xflr1 moves the garage front 9.36" back but xelev was not updated.

- **2026-10-16** — Lot 7: folder reorganised to the Projades standard, drawing register and rebuild plan R01 written, new DWGs surveyed (DXF + layered plot PDFs in scratch; `tools/lot7_rebuild/dxf_survey.py`). No model work yet; waiting for approval of the plan.

- **2026-10-16** — Lot 7 model v2 (`LOT7/JESB_Lot7_v2.skp`, **current**). See 7d. Wing over garage and entry projections rebuilt as hip ends (metal fronts on the entry), east gablet added, main ridge 411.3, garage roof continued into the wing, dormers/windows/garage doors/terrace moved to DWG positions, terrace stair moved to the south side, gable trim added.

- **2026-10-16** — Lot 7 model v1 (`LOT7/JESB_Lot7_v1.skp`, **current**; `exports_v1/` with views PDF and `pdf_overlay_checks/`; change log). See section 7d. Lessons: a gable body clipped by a half-plane beyond where its ridge dies into the main roof leaves a vertical end face poking through — clip at the ridge/roof intersection (`ymax(4060)` for the cross gable); when searching for a component to move, search one level into top-level groups and with generous z limits (the gable window was group 461201 at z 240..272, missed by a z>250 filter).

- **2026-10-16** — Lot 19 model v5 (`LOT19/JESB_Lot19_v5.skp`, **current**; `exports_v5/`; change log): entry tower piers above the canopy (z 194.18..298.12) extended to the window surround per xelev front elevation (left pier group 333607 front y 1394.60 to x 1558.40; right 334788 front y 1398.86 to x 1637.56); seam edges hidden and texture re-projected from the old face via UVHelper. Script `tools/lot19/build_v5.rb`. Lesson: when splicing a coplanar extension onto an existing face, orient faces before merging and hide any edge that survives; copy UVs with `get_UVHelper` + `position_material`.

- **2026-10-16** — Lot 19 model v4 (`LOT19/JESB_Lot19_v4.skp`, **current**; `exports_v4/`; change log). New reference `LOT19/xelev_lot19.dwg` (the architect's exterior elevations as plain lines, unlike the floor-plan xrefs; DXF-exportable). In the DXF the four elevations sit side by side: right/garage side x 2400..3850, rear 3900..4850, left 4900..6150, front 6250..7700, all with y - 1401.7 = model z; horizontal offsets found by FFT correlation against the model's 2 px/in ortho views (front +26 px, right -359, rear +204, left -177 at x0 of each range). Scripts `tools/lot19/xelev_survey.py`, `xelev_extract.py`, `xelev_align.py`. Check result: only the entry door unit and the garage door panel pattern differed. v4: entry unit rebuilt (sidelite 18 | door 36 | sidelite 18, door/sidelites z 32..131.8, three transoms 131.8..155.8; grey panel above raised; wall Group#17 notched for the transoms); garage doors with 2 panels per section and muntins in the glass row. Build `tools/lot19/build_v4.rb`. Repeat lesson: take plane positions from the faces themselves before splitting faces with add_line.

- **2026-10-15** — Lot 19 model v3 (`LOT19/JESB_Lot19_v3.skp`, **current**; `exports_v3/`; change log), built on the user's hand-edited v2 (15:33; they changed accent panels to wood tone and fascia to black). Added: frieze board 5/4x8 Arctic White under the main eaves (z 265.2..272.5, 0.75 proud, exterior walls found by raytest from 7 probes per wall — one probe is blocked by window frames), soffits painted white, terrain mesh (24 in. grid, IDW from exterior wall-bottom samples minus 2.5 in., kept 1.5 in. under flatwork, skirt to -150 with hidden vertical joints). Script `tools/lot19/build_v3.rb`. Reusable recipe for terrain on other lots: sample the bottoms of exterior cladding faces, IDW, mesh via `Geom::PolygonMesh` + `add_faces_from_mesh`.

- **2026-10-15** — Lot 19 model v2 (`LOT19/JESB_Lot19_v2.skp`, **current**; `exports_v2/`; change log), from v1 per the owner's red mark-up: main roof notched at the entry tower walls (x 1517.6..1678.3, y up to 1462.8) so its fascia no longer crosses the tower face; garage roof rebuilt (eave top 132.5, 4:12 sides, 6:12 south ends; hips G1 x 1170..1466 south 975.8 and G2 x 1170..1324 south 963.1); window added on the bay's east wall (mirror of the west window about x 1297.41); garage doors now single 8x8 (y 1009.5..1105.5) then double 16x8 (y 1136..1328), custom panel doors, centre pier moved. Generator `tools/lot19/roof19.py` now supports per-plane pitch, open north ends and holes; build `tools/lot19/build_v2.rb`. Lot 19 model note: windows and doors are just placed on continuous wall faces (no openings cut), so moving/adding them needs no wall surgery. Ruby lesson: assigning a Capitalised name inside a method is a syntax error (dynamic constant) and SketchUp then silently exits without running the script.

- **2026-10-15** — Lot 19 started: model v1 = roof rebuilt to the Revision 1 elevations (see 7c). User instruction: use only the exterior model and the roof plan / elevation drawings as reference.
- **2026-10-13** — Lot 20 model v9 (`LOT20/JESB_Lot20_v9.skp`, **current**; `exports_v9/`; change log) = the user's hand-edited v8 (14:41 on 10/12) with the entry double door moved 2.3" forward. Complaint (in English, with a crop of an AI render): the black Hardie panel between the entry door and the window above 'pops out'. Cause in the model: the panel (user's own edit, face on the entry wall plane y 3854.07, x 12836.26..12920.26, z 118.16..138.93) and the window frame (front y 3854.03) were flush, but the door leaf face was at y 3856.44, 2.4" back; the AI render exaggerated that step. Fix: doors 131211/131212 translated so the leaf face is at y 3854.12. Lessons: component bounds of the door include the handle (1.2" proud) — measure the leaf by its large front face; keep an element that is wider than its wall opening 0.05" behind the wall plane rather than coplanar. When a render shows a defect, check the model first: the render follows model depth offsets. Script `tools/lot20_v9_entry/build_v9.rb`.

- **2026-10-12** — Lot 20: the user edited `JESB_Lot20_v8.skp` again (saved 14:41; rear side) and asked for the rear elevation PDF output to follow it. `exports_v8/` PNGs and `JESB_Lot20_v8_Views.pdf` re-exported from a copy. Working pattern today: the user edits the current model by hand in SketchUp, then asks for the exports/PDF to be refreshed from it — run `tools/lot20_export_views.rb` on a copy named `JESB_Lot20_vN_*.skp`, then `mkpdf_views.py`.

- **2026-10-12** — Lot 20: the user edited `JESB_Lot20_v8.skp` themselves (saved 14:24; visible on the front: the wall between the entry door and the window above it is now black) and asked for the front elevation PDF output to follow it. All five PNGs in `exports_v8/` and `JESB_Lot20_v8_Views.pdf` re-exported from a copy (model not saved by me). The v8 change log describes v8 as delivered, not the user's later hand edits.

- **2026-10-12** — **Lot 20 direction change: back to v5.** Instruction: return to `JESB_Lot20_v5.skp` and add only black gutters. Result `LOT20/JESB_Lot20_v8.skp` (**current**; `exports_v8/`; change log) = the v5 file as hand-edited by the user on 2026-10-12 13:39 + group `Gutters - Black (v8)` (5 x 5 in, 334 ft). No downspouts. **v6 and v7 are superseded** (four windows above the garage, sill / frieze removal, extra black panels, seamless white panels, downspouts are all NOT in the current model); do not build on them unless asked. The owner style rules noted from the 10/10 feedback are therefore not applied at present. Script `tools/lot20_v8_gutters/build_v8.rb`.

- **2026-10-12** — Lot 20: the user edited `JESB_Lot20_v7.skp` themselves (saved 12:36) and asked for the v7 exports to be redone from it. Five PNGs in `exports_v7/` and `JESB_Lot20_v7_Views.pdf` re-exported from a copy (model not saved by me). Differences against my v7 exports are small (front, rear, right and perspective; left identical); what exactly was edited was not identified. Generic export script for any Lot 20 version: `tools/lot20_export_views.rb` (prefix from the file name, fixed framing) + `tools/lot20_v3_roof/mkpdf_views.py`.

- **2026-10-12** — Lot 20 model v7 (`LOT20/JESB_Lot20_v7.skp`, **current**; `exports_v7/`; change log). The architect's `Lot-20 base rend.dwg` was re-issued (saved 2026-10-12 12:04) with `Lot-20 second floor_r1.pdf`: only the second floor plan changed — four symmetric windows on the wall above the garage, dimensioned 29 | 32 | 14.5 | 32 | 98.5 | 32 | 14.5 | 32 | 29 (wall 313.5"); the DWG elevations still show two windows. v7 moves the four windows to those positions (from the framing corner x 12344.80: 29.0, 75.5, 206.0, 252.5); size kept 32 x 30; black panel between each pair kept, now 14.5" wide. Second floor plan to model: x + 18473.64 (plan sits 1200" right of the first-floor/roof-plan x). To see what changed between two DWG issues, export both to DXF and diff the line segments (`scratch cmp.py` logic: explode inserts, round to 0.1, set difference) — it pinpointed the change in seconds. The DXF of the old issue is no longer valid for the second floor plan. Script `tools/lot20_v7_windows/build_v7.rb`.

- **2026-10-12** — Lot 20 v6 downspouts repositioned in place: each sits 2" from the end line of its wall (owner's representative wants them tight to wall ends/corners, not floating in the wall); no. 4 at the rear end of the left-wing wall (wall x 12344.76, end y 4040.07), no. 7 moved to the garage's right side wall x 12613.76 at the front corner (door starts y 3444.5). Exact centres are in `tools/lot20_v6_feedback/update_v6_c.rb`. Exports and PDF refreshed.

- **2026-10-12** — Lot 20 v6 updated in place (follow-up instructions): black Hardie strip (4" x 30") between the two windows of each pair above the garage; rear black panel made one piece (no Hardie panel has a joint now); seven black 3" x 4" downspouts added, group `Downspouts - Black (v6)` — positions are my proposal at corners (list in the v6 change log; the DWG shows only two, on the right elevation). Exports, PDF and change log refreshed. Script `tools/lot20_v6_feedback/update_v6_b.rb`. Lot 20 elevation exports now use the fixed framing centre (12776.80, 3838.76, 187.33), height 813.694, because the gutters widened the house bounds.

- **2026-10-12** — Lot 20 model v6 (`LOT20/JESB_Lot20_v6.skp`, **current**; `exports_v6/` with five PNGs and `JESB_Lot20_v6_Views.pdf`; change log). Source: `LOT20/JE Lot 20 ACC and Render Feedback - 2026 10 10.pdf`, a 6-slide PowerPoint export by the **owners of Lot 20, Tim & Aurora Trento**, marking up the v3 renders "to match the agreed contract drawing set JESB – LOT 20 ARCHITECT SET – TIM – Rev 2026 05 18" (that set is not in the folder). Applied: (1) upper wall above the garage — four windows in two pairs, 32 x 30, heads at 248.33, at 29.5 / 65.5 / 207.5 / 243.5 in from the wall's left corner x 12344.76 (scaled from the owner's plan; the ACC had asked for two); (2) all 12 window sills removed, whole house; (3) header band above the lower left-side brick window removed; (4) frieze: projecting band at the top of the garage front wall removed, brick raised to 135.25; (5) black Hardie panel between windows added at the entry (door head to upper window sill, z 118.0..138.8) and on the two strips of the tall window bay; (6) joint lines removed from all white Hardie panels ("no or minimal seams" — this overrides the equal-panel grid of 10/09); rear black panel keeps its one centre joint; (7) black 5" x 5" gutters along all eaves, group `Gutters - Black (v6)`, 334 ft, no downspouts. Script `tools/lot20_v6_feedback/build_v6.rb`.
- **Owner style rules for Lot 20 (from that feedback):** no window sills, no frieze board, no soldier course / rowlock / stone band / decorative trim; Hardie Architectural Panel white on the bays and black between windows, with no or minimal seams; black gutters.
- SketchUp API lessons from v6: (a) a closed loop drawn in the middle of a face does **not** cut a hole — split the face edge to edge, erase the opening pieces, then erase the helper edges between the remaining coplanar faces; (b) edges added at rounded coordinates miss the face by a few thousandths and silently do not split it — always take the plane position from a vertex of the face (upper wall front y 3798.9481, back y 3806.0731); (c) the upper-wall windows have a solid wall face behind them (no opening at the back).

- **2026-10-09** — Lot 20 v5 updated in place: black Hardie panels per the owner — front panels one piece each (96.0 x 55.7), rear panel two equal pieces (91.0 x 45.5, joint at x 12930.8). Exports, PDF and change log refreshed. Script `tools/lot20_v5_hardie_panels/black_panels.rb`. Note: erasing a joint edge leaves collinear vertices on the neighbouring edges, so do not test panel faces by vertex count.

- **2026-10-09** — Lot 20 v5 updated in place again: the owner wants the Hardie panels divided into **equal** panels (the window-aligned joints gave unequal white panels). Old joint edges removed (edges between two coplanar faces of `Hardie Panel - Arctic White`), then an even grid per white face: columns = width/48" rounded, rows = height/96" rounded — garage bay 3x1 (40.0 x 135.3), bay left of the entry 3x3 (49.7 x 83.7), tall window bay 2x3 (49.8 x 83.7), right-side bay 2x3 (56.0 x 85.7). Black panels unchanged (already equal). Exports, PDF and change log refreshed. Script `tools/lot20_v5_hardie_panels/equal_panels.rb`. **Preference:** for this owner panel cladding is laid out in equal panels per area, not aligned to window lines.

- **2026-10-09** — Lot 20 v5 updated in place (the user asked for it to be saved into the v5 file): the "siding boards" of the Kami notes are **Hardie board panels** — smooth flat fibre-cement panels with thin joints, per the owner's reference image — not lap boards. The two materials were renamed `Hardie Panel - Arctic White` / `Hardie Panel - Black`, texture removed (plain colour); same faces as v4. Panel joints drawn as edges on the wall faces (vertical at window jambs, horizontal at z 127.0 and 182.7, i.e. lower window head and upper window sill; 92.75 / 172.75 on the tall three-window bay; black panels split in two or three). Adding the edges split the wall faces, so the face pids listed for v4 no longer cover whole areas; find the panel faces by material name instead. `exports_v5/` PNGs and PDF refreshed, v5 change log extended. Script `tools/lot20_v5_hardie_panels/build_panels.rb` (includes a helper that clips a joint line to the inside of a face with openings via `Face#classify_point`). The lap textures in `LOT20/textures/siding_boards_*_7in.jpg` are now used by v4 only.
- Terminology for this owner: "siding boards" on the mark-ups = Hardie board panels (flat panels with reveal joints); the vertical board-and-batten elsewhere is called "board & batten siding" on the drawings.

- **2026-10-09** — Lot 20 model v5 (`LOT20/JESB_Lot20_v5.skp`, **current**; `exports_v5/` with five PNGs, `JESB_Lot20_v5_Views.pdf` and `dwg_overlay_checks/`; change log). The user asked for the garage roof to be revised from the DWG plan *and* elevations. Only the garage roof group was rebuilt, now `Roof - Garage (per DWG plan and elevations, v5)`. Finding: the roof plan stops the garage roof at the upper roof's overhang (y -333.42), so it does not show the last 23" to the two-storey wall; the front and right elevations show the roof rising there to 201.1" (apex midway between the west eave and the angled east eave, 4:12 down to the east eave). v3/v4 followed the plan only and reached 195.7". v5 keeps everything the plan shows and adds one facet through the plan ridge end (-4796.84,-333.42, +52), the east eave at the wall (-4602.75,-310.42, 0) and the apex (-4777.79,-310.42, +58.35 = 201.15"); the west plane runs up to the new rising ridge. In the generator this is body `G3 = min(W, T2)` added to the garage envelope (`tools/lot20_v5_garage_roof/roofgeom_v5.py`, `build_v5.rb`, `overlay5.py`). Right-elevation mapping for Lot 20: elevation x = plan y - 2773.4. Lesson: when the plan and elevations seem to disagree, first check whether the plan is merely hiding the area under a higher roof.
- Remaining DWG inconsistency at the garage (in the v5 change log): no single plane fits the plan valley, a 4:12 slope at the wall and the 201.1" apex; the big plane over the angled wall is about 3.4:12 and the new facet about 7.7:12. The left elevation draws the ridge level to the wall.

- **2026-10-08** — Lot 20 model v4 (`LOT20/JESB_Lot20_v4.skp`, **current**; `exports_v4/` with five PNGs and `JESB_Lot20_v4_Views.pdf`; change log). Source of the change: `LOT20/Kami Export - Lot-20-ACC response.pdf`, the owner's Kami mark-up of sheets 1, 1.1, 1.2 (the red notes are flattened into the page; read them by rendering the pages with PyMuPDF and diffing words against `Lot-20-ACC response.pdf`). Seven notes, all applied: every stucco / grey panel area (`Material6`, a hardie-panel texture) becomes siding boards — Arctic White on the garage front bay, the bay left of the entry, the tall three-window bay right of the entry and the right-side bay; Black on the panels between window rows (front left bay, front right bay, rear glazed bay). New materials `Siding Boards - Arctic White` and `Siding Boards - Black` (textures in `LOT20/textures/`, horizontal boards, 7" exposure — direction and size are my assumption, flagged in the change log). Faces were painted by persistent id inside the house group: white 125173, 125205, 125199, 127288, 132014, 132021, 157982, 157989, 157985; black 127831, 131648, 165484. Wall group 127795 has `Material6` as its group material, so unpainted faces in it still inherit grey; do not change the group material. Built on the user's v3 of 12:07 (lawn, driveways, decks included). Scripts in `tools/lot20_v4_siding/`.

- **2026-10-08** — Lot 2 rear elevation: the user wanted the deck to show as in their perspective screenshot `exports_v4_new/JESB_Lot2_v4_Elevation_Rear_new.jpg`. `JESB_Lot2_v4_Elevation_Rear.png` re-exported with the deck drawn: camera stays orthographic; the deck top (loose slab, Material2, x 2944.4..3145.4, y 7008.6..7141.2, top z 16.9) is drawn as a 34" band (depth x sin 15°) plus its 8" front edge on the near face of the ground. Export-only, model not saved; PDF rebuilt. **This is now part of the Lot 2 export convention for the rear elevation** (script `tools/lot2_export_rear_deck.rb`). Tried and rejected: pitching the parallel camera down 10° — it shows the deck but also the roof tops and reads as an axonometric, not an elevation.

- **2026-10-08** — Lot 2: the user updated `JESB_Lot2_v4.skp` again (saved 15:03) and asked for current elevation files in `LOT2/exports_v4_new/` (no renders). The four elevation PNGs were re-exported from a copy with the standing export convention (dark terrain skirt, driveway profile on the left elevation; model not saved) and `JESB_Lot2_v4_Elevations.pdf` rebuilt from them. Script: `tools/lot2_export_elevations.rb` + `tools/lot2_mkpdf_elevations.py`. Model state seen: driveway asphalt faces x 2330..2755, y 6562..6982; terrain group and named v4 groups still present; the model style now shows a banded sky/horizon background in exports. The older `exports_v4/` folder and the AI `renders/` were not touched.

- **2026-10-08** — Lot 20 render hardscape. Another session made AI (ImageGen) elevation renders of v3 in `LOT20/exports_v3/renders/` (four PNGs 1586x992 + `JESB_Lot20_v3_Render_Elevations.pdf`, with its own archives and a `model_site_reference/` folder holding `horizontal_faces.json` of the model). The user asked for the hard surfaces in those renders to follow the v3 model. Done by compositing, not regenerating (no image model in this session): driveway outlines from the model projected in one-point perspective below the grade line; front and right got lawn + driveway in place of the blank ground, rear and left had their driveway strips redrawn. House part of the renders untouched. Previous files in `renders/archive_before_hardscape_update/`; notes in `renders/Render_Hardscape_Update_Notes.txt`; the Desktop copy of the PDF was replaced with the new one. Scripts `tools/lot20_v3_roof/render_hardscape.py` and `render_pdf_update.py`.
- Lot 20 site in the user's v3 (model inches): lawn slab x 12190.7..13397.7, y 3326.3..4417.4; front driveway (Asphalt_06_1K) L-shape (12614.8,3446.0) (12789.9,3446.0) (12789.9,3330.2) (12948.7,3330.2) (12948.7,3764.4) (12614.8,3764.4); rear driveway x 12361.7..12493.0, y 4040.1..4417.4; rear deck platform x 12508.8..13043.8, y 4242.9..4346.1. Render pixel mappings (scale px/in, anchor, grade row) are in `render_hardscape.py`.

- **2026-10-08** — Lot 20: the user edited `JESB_Lot20_v3.skp` themselves (saved 12:07): lawn and driveway ground slabs (top-level groups, z -8.8..0) and three `deck` components at the rear were added, and the saved view is now a front-right perspective; the roof groups are unchanged. On request, the five views were re-exported from that file (copy, not saved) into `LOT20/exports_v3/` and combined into `exports_v3/JESB_Lot20_v3_Views.pdf` (11x17 landscape, four pages: front, left, rear, right; the user had the perspective page removed, so view PDFs are elevations only unless asked otherwise). Script: `tools/lot20_v3_roof/export_views.rb` + `mkpdf_views.py`. Elevation framing still uses the house group bounds, so the ground slabs run past the frame edges a little.

- **2026-10-08** — Lot 20 model v3: roof updated to the DWG roof (user task list "JESB Lot20 project — to do"). Whole roof rebuilt from the roof plan with heights from the elevations; eaves moved to the DWG lines (up to 25"), 8" roof edge added, all ridges 7.6" higher. Verified by overlaying DWG lines on the top, front and left views (`LOT20/exports_v3/dwg_overlay_checks/`). Vents and gutters not added. Four open questions in `LOT20/JESB_Lot20_v3_Change_Log.md`. Scripts in `tools/lot20_v3_roof/`.

- **2026-10-08** — Brain file brought up to date with everything learned so far: working conventions, the 2026-10-06 review findings and their status, consolidated Lot 2 open decisions, Lot 20 open items, and the ACC tracker structure with the Lot 2 and Lot 20 selections. No model or drawing changes.

- **2026-10-07** — Git repository initialised and pushed to github.com/cozkankayacik/JESB (user request: upload all work there, commit and push regularly).
- **2026-10-07** — (Another session, 15:09–15:44, reconstructed from its files.) Lot 2 rear elevation re-exported with the projecting patio slab visible (`exports_v4/JESB_Lot2_v4_Elevation_Rear_new.png`, `exports_v4_new/…Rear_new.jpg`); AI (ImageGen) rear render redone from it (`renders/JESB_Lot2_v4_Render_Rear_new.png`, then `_v2` with the smooth white band right of the deck replaced by lap siding); rear page of `renders/JESB_Lot2_v4_Render_Elevations.pdf` updated. Model not changed.

- **2026-10-07** — JESB moved to its own project session. The first session ("JESB projesi öğren") ran under the Derby Estates project and was deleted there; its transcript and user images are in `session_archive/`, its 42 automation scripts in `tools/session1_scripts/`, the Python libraries in `tmp/python-libs/`. Memory notes for JESB now live in the JESB project memory. Pending from that session, not yet answered by the user: (a) Lot 2 — whether to correct stone, trims, soffit/fascia and gutters to the ACC list and re-render; front door/stoop height; patio height; (b) Lot 20 — the remaining comparison items (three left-side windows, roof heights, vents, fascia/gutters, basement windows and grade, balcony depth, garage door style).

- **2026-10-07** — Lot 20 model v2 (`LOT20/JESB_Lot20_v2.skp`, `exports_v2/`, change log): owner approved items 1 and 2 only. Front upper wall: three windows → two 32x32 at DWG positions with sills (wall group pid 127795, window groups 127474 and 127793 moved/scaled, 127794 removed). Siding: `Material5` texture swapped to `LOT20/textures/board_batten_white_16in.jpg`, 16" tile. Remaining comparison items untouched. Technique note: to close an opening, erase the reveal faces, then erase the opening's edges on the outer face (the face heals); adding a patch face and trying to merge did not work.
- **2026-10-07** — Lot 20: compared the current DWG with the SketchUp model on request; report and overlays saved under `LOT20/comparison_2026-10-07/`. No model edits.

- **2026-10-07** — V-Ray renders of the four elevations made from the user's v4 (model not saved): `LOT2/exports_v4_new/renders_vray/` (four 2400x1500 PNGs + `JESB_Lot2_v4_Elevations_Render.pdf`). Model materials as they are. `ACC MATERIAL PACKAGE.xlsx` (project root, sheet EXTERIOR, column B = Lot 2) read and compared; mismatches reported to the user, not applied. A separate `exports_v4_new/renders/` folder with AI-generated (ImageGen) visualizations and notes appeared at the same time from another session; not touched.
- **2026-10-07** — Left elevation re-exported with the driveway visible in front of the garage doors, and `exports_v4_new/JESB_Lot2_v4_Elevations.pdf` (four elevations, 11x17, one per page, built with PyMuPDF from the PNGs) rebuilt. In elevation the flat driveway is hidden behind the terrain edge, so the export draws the slab's own profile (y 6562–6982, z -10.25 to -3.19, asphalt material) on the near face of the ground; export-only, model not saved. In the user's v4 the driveway slab now runs west to x 2330.
- **2026-10-06** — User created `LOT2/exports_v4_new/` and asked for the views from the latest SKP there. The latest SKP is still `JESB_Lot2_v4.skp` (4:43 PM, byte-identical to the copy already exported), so the same five views were added. The folder also holds three `image-*.png` files the user put there; they are copies of the rear elevation (twice) and the perspective.
- **2026-10-06** — User edited `JESB_Lot2_v4.skp` themselves (saved 4:43 PM; saved view is now a straight-on front perspective, geometry otherwise as delivered) and asked for `exports_v4` to be redone from it with the ground looking like their screenshot. Re-exported without saving the model. **Export convention from now on:** perspective = the view saved in the file; elevations framed with centre z 195 and height 690 so the frame bottom meets the terrain block; terrain skirt temporarily painted dark (66,72,55) with its rim and bottom edges hidden so the ground reads as one dark mass. A `LOT2/Reviews/2026-10-06/` folder (EN/TR review, data, evidence) also appeared; it was not made in this session.
- **2026-10-06** — Model v4: terrain added from the elevation grade lines; visible foundation limits checked on all sides (most already matched; entry tower foundation, pier bases and two step risers added); wall above the entry canopy set to brick. Open: door/stoop height vs drawing, front yard slope and ground beyond the walls (no grading plan), patio height (+16.9 model vs +8.8 drawn).
- **2026-10-06** — Owner decisions on the v2 questions: keep the flat entry canopy; 12" overhang on the whole roof; move both garage doors to plan positions; widen the driveway; keep the door style. Model v3 made accordingly (see v3 change log). Remaining open: whether 12" is from the wall face (used) or the framing line; model walls larger than DWG at rear/east; flat patch on the tower roof; driveway margin; rest of the elevations not audited.
- **2026-10-06** — Model v2 made from v1: flat slab on the entry tower replaced by the DWG hip roof, tower walls lowered to the eave; south garage opening widened to 16' and both doors now the same 16' x 8' component; 10/5 DWG imported on a hidden tag. Exports and change log written. Eight open questions are listed in the change log (overhang 7" vs 12", door positions, driveway width, door style, and others) — none answered yet.
- **2026-10-06** — First read of the folder. PDF text extracted, DWG exported to DXF from a copy and inspected, sheets T1.0, 1, 1.1, 2, 3, 4, 6 viewed. Brain file created. Source files untouched.
