# JESB — Project Brain

Last updated: 2026-10-08. Working notes for Jade Estates, South Barrington. Keep this file current as decisions land.

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
- Comparison of 2026-10-07 is in `LOT20/comparison_2026-10-07/` (report + overlay images). Main differences: front upper windows 3 → 2, siding horizontal → vertical board and batten, three left-side windows 12" toward the rear, ridges 7.6" / 14" higher, roof vents, fascia/gutters, basement windows and grade. The model has not been changed.
- Comparison method that worked: rasterise DXF lines with PIL (ezdxf's drawing add-on gave black images), export model views with a known scale, brute-force the best x/y shift against an edge map, draw the DWG in red. A vertical best-fit can be pulled off by roof differences; trust the window fit.

- Model v2 (`JESB_Lot20_v2.skp`, `exports_v2/`, change log, `textures/board_batten_white_16in.jpg`): front upper wall windows and board-and-batten siding done. **Still open from the comparison (after v3):** three left-side windows 12" toward the rear; four roof vents; gutters and downspouts; full basement with four 48" x 48" escape windows and a grade line (model stops at the slab, no ground); balcony / covered patio depth (left elevation shows 15"–20" more than the model, right elevation agrees with the model — one DWG elevation may be wrong, measure from the plan); garage door style.
- **Model v3 (`JESB_Lot20_v3.skp`, current; `exports_v3/`, change log): roof rebuilt from the DWG roof plan and elevations.** The nine old roof groups (pids 173449, 173417, 151074, 150944, 150850, 150889, 165195, 151372, 151318) are gone; the roof is now two manifold solid groups in the house group, `Roof - Main (per DWG roof plan, v3)` and `Roof - Garage (per DWG roof plan, v3)`. This settles the roof heights and the 8" roof edge from the comparison; vents and gutters were not added.
- **Lot 20 DWG-to-model transform (exact, walls agree within 0.1"):** roof plan and floor-level plan x + 17273.64, y + 4111.42; elevation y + 2280 = model z. The front elevation uses the same x as the roof plan; left elevation x = -(plan y) - 6230.2. Model walls sit at the brick face (framing line + 5").
- **Lot 20 roof definition (DWG plan coordinates, eave lines 24" outside the framing line):** eave top 264.6 / fascia bottom 256.6 on the main roof, 142.8 / 134.8 on the garage. The roof is the upper envelope of hip bodies, all 6:12 on the main level: M2 (x -4784.84..-4210.84, y -317.42..150.58, ridge 381.6), M1 (east, eaves x -4054.84, y -317.42 / 138.58, ridge 378.6), NW (eaves x -4784.84 / -4431.84, y 162.58), LW left wing (x -4952.84..-4591.34, y -329.42..-47.42), a saddle between LW's north plane and the main south plane (DWG line at y -182.42), F2 (x -4485.34..-4205.84, south eave -333.42), F1 entry (x -4485.34..-4305.34, south eave -345.42), RB (east eave -4040.84, y -169.42..-9.42). Garage: side planes 4:12 (eaves x -4952.84 / -4640.84), front 6:12 (y -713.42), angled eave from (-4640.84,-452.58) to (-4608.91,-333.42) with a valley to the ridge end; front gable x -4880.84..-4712.84, south eave -725.42. `tools/lot20_v3_roof/roofgeom.py` holds this and regenerates the geometry; `build_v3.rb` builds it in SketchUp.
- DWG inconsistencies found on the roof (open, in the v3 change log): left wing drawn 282" wide on the roof plan but 287" on the elevations (ridge 335.1 vs 336.3; model follows the plan); garage roof at the angled wall shows a 201.1" point on the front and right elevations but a level 194.8" ridge on the left elevation and roof plan (model follows the plan, peak 195.7").
- Roof-building method that worked (reusable for other lots): describe each roof block as a convex set of planes, compute the upper envelope in Python as small planar cells, add the cells as faces in SketchUp, erase edges between coplanar faces, drop a vertical face from every free edge to the fascia bottom, close the underside with `find_faces`. Both groups came out manifold on the first run; SketchUp solid tools (`outer_shell`) were not needed.
- Board-and-batten is a texture, not geometry; batten spacing restarts on each wall piece, so battens do not always line up at joints. The 16" spacing comes from the DWG hatch pattern name, not a dimension.
- Interiors and floor plans of Lot 20 have not been compared.

## 7b. ACC material package (`ACC MATERIAL PACKAGE.xlsx`)

- Title: "South Barrington – Selection Tracker – Elevation". Sheet `EXTERIOR` (A1:AF34, 82 embedded sample images) has one column pair per lot: Lot 2 = B, Lot 3 = D, Lot 7 = F, Lot 19 = H, Lot 20 = J, Lot 21 = L, Lot 23 = N, Lot 16 = R, Lot 4 = T, Lot 6 = V, Lot 8 = X, Lot 9 = Z, Lot 10 = AB, Lot 11 = AD. `Sheet2` is a small side table.
- Row 3 status: Lot 2 Phase 1, Lot 3 Approved, Lot 7 Phase 1, Lot 19 Phase 2, Lot 20 Phase 1, Lot 21 Approved. Rows 4–9 name each lot's SketchUp file, video, colour scheme PDF, 3D elevations and old/new architect sets (Lot 2 new set: "LOT 2 - ARCHITECTURAL - PHASE 1 0824.pdf"); those files are not in this folder.
- Rows 10–32, one item every two rows (the row below each is a "selection" checkbox):

| Item | Lot 2 | Lot 20 |
|---|---|---|
| Roof | Charcoal | Charcoal |
| Brick | Whitestone Brickcraft | Glen Gery Aspen White Wirecut |
| Stone | Valders Dovewhite Dimensional Splitface | Valders Dovewhite Dimensional Splitface |
| Siding | White | White |
| Siding dec | — | Black |
| Trims | White | White |
| Soffit / fascia (LP SmartSide) | Black | White |
| Gutters and downspouts | Black | Black |
| Front door | Black | Black |
| Windows / patio doors | Black | Black |
| Garage door colour | Black | Black |
| Garage door style | Long raised with glass on top | Long raised without glass |

- Lot 20's black "siding dec" has not been applied anywhere: the drawings do not show where it goes.

## 8. Log

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
