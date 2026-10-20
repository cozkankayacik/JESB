# JESB Lot 7 – Drawing and File Register

Project: Jade Estates, South Barrington, Illinois – Lot 7
Owner: Projades
Architect: Purohit Architects, Inc. (project no. 202601.LOT 7)
Register updated: 2026-10-16

## 1. Folder structure (Projades project standard)

| Folder | Contents |
|---|---|
| `00_Project_Admin/` | `ACC_Material_Samples/` (Lot 7 sample images from the ACC Material Package), this register, the model rebuild plan, Projades brand templates (`Brand_Templates/`, copied from the HoffmanEstate project) |
| `01_Site_and_Reference/Architectural_Set_PDF/` | Architect's issued PDF set |
| `03_Shared_CAD_and_Models/Xrefs/Architect_DWG_2026-10-16/` | Architect's DWG files as received (original names kept, see 3) |
| `03_Shared_CAD_and_Models/Models/00_Owner_Original/` | Owner's original SketchUp model – read only, never edited |
| `03_Shared_CAD_and_Models/Models/01_Working/` | Current SketchUp working model (the rebuild) |
| `04_Visualization/Exports/` | Model exports (elevations, perspectives) per revision |
| `04_Visualization/Working/` | Render work files |
| `05_Presentations_and_Issued/Issued_Sets/` | Projades-branded A3 PDF sets issued for review |
| `99_Archive/Superseded_v1_v2/` | Models v1 and v2, their exports and change logs (superseded 2026-10-16) |
| `99_Archive/Backups/` | SketchUp `.skb` and AutoCAD `.bak` backups (not in Git) |

## 2. Architectural PDF set

`JESB_Lot7_Architectural_Set_Rev1_2026-10-15.pdf`. The architect's original file name was `JESB - LOT 7  ARCHITECTURAL PLAN_REVISION1.pdf`. The set has 10 sheets, 1/4" = 1'-0". Issue history:
- 07/27/2026 issued
- 08/10/2026 issued for preliminary review
- 10/15/2026 Revision 1

| Page | Sheet | Title |
|---|---|---|
| 1 | Cover | Cover sheet, general notes, schedules |
| 2 | A-001 | General notes and specifications |
| 3 | A-100 | Foundation plan, foundation section, structural and rebar schedules |
| 4 | – | First floor plan |
| 5 | – | Second floor plan |
| 6 | A-220 | Roof plan, attic ventilation schedule |
| 7 | A-300 | Exterior elevations: front, right side (south) |
| 8 | A-310 | Exterior elevations: left side (north), rear (east) |
| 9 | A-311 | Building sections |
| 10 | A-400 | Typical wall section and details |

The elevation titles give the compass orientation: the rear faces east, so the **front faces west**.

## 3. Architect DWG files (received 2026-10-16)

The file names are kept exactly as received because the files reference each other as xrefs. `xflr1` attaches `.\xflr2_lot 7G.dwg` and `xflr2` attaches `.\xflr1_lot 7G.dwg`. Renaming them would break the references in AutoCAD.

| File | Content | Status against the 2026-10-16 morning copies |
|---|---|---|
| `xelev_lot 7G.dwg` | Four exterior elevations; plain lines, hatches and dimensions | Unchanged |
| `xflr0_lot 7G.dwg` | Foundation / basement plan and a typical wall section (x 2500..3100) | **Changed** (saved 2026-10-16 15:10) |
| `xflr1_lot 7G.dwg` | First floor plan | **Changed** (saved 2026-10-16 15:10) |
| `xflr2_lot 7G.dwg` | Second floor plan | Unchanged |

Technical notes:
- All four drawings are in inches, AutoCAD 2018 format.
- **Walls, doors, windows and roofs in the floor plans are AutoCAD Architecture objects.** A DXF export does not keep them; it keeps only dimensions, notes, stairs, columns and beams.
- The walls are extracted by plotting a copy of each DWG to a layered vector PDF at 1:48 from the AutoCAD LT core console. In that PDF, 1 pt = 2/3 in. The script is `tools/lot7_rebuild/`.
- Source files are never opened for editing. All processing runs on copies.

## 4. SketchUp models

| File | Status |
|---|---|
| `JESB_Lot7_Owner_Model_2026-10-15.skp` | Owner's original model. Original file name `JESB_SKETCHUP_LOT7.skp`. Reference only. |
| `99_Archive/.../JESB_Lot7_v1.skp`, `JESB_Lot7_v2.skp` | Earlier corrections of the owner model (roofs, dormers, windows). Superseded by the rebuild. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R01.skp` | Exterior model R01 rebuilt from the DWGs. See `JESB_Lot7_Model_R01_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R02.skp` | R01 + lower front gable over the garage bump with eave returns. See `JESB_Lot7_Model_R02_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R03.skp` | R02 + decorative textured panels. See `JESB_Lot7_Model_R03_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R04.skp` | R03 + stone headers, window casings and surrounds, grid muntins. See `JESB_Lot7_Model_R04_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R05.skp` | R04 + front stair window as two stacked units. See `JESB_Lot7_Model_R05_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R06.skp` | R05 + roof at the wing / main roof junction per A-220. See `JESB_Lot7_Model_R06_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R07.skp` | R06 + continuous headers over window groups, stair railings. See `JESB_Lot7_Model_R07_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R08.skp` | R07 with all finishes per the ACC Material Package (Lot 7). See `JESB_Lot7_Model_R08_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R09.skp` | R08 + owner decisions: metal roofs dark brown bronze, cast-stone headers kept. See `JESB_Lot7_Model_R09_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R10.skp` | R09 with true standing-seam texture on the metal roofs. AI render input package in `04_Visualization/Working/AI_Render_Package_R10/`. See `JESB_Lot7_Model_R10_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R11.skp` | R10 + owner answers to RFI-001: garage front, slider, wing gable window and entry door per the elevations. Roof per A-220. See `JESB_Lot7_Model_R11_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R12.skp` | R11 + RFI-001.03: main roof end hips 6:12 per the rear elevation (ridge 131 in). See `JESB_Lot7_Model_R12_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R13.skp` | R12 + covered terrace deck and skirt in white lap siding (Siding Dec - White). See `JESB_Lot7_Model_R13_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R14.skp` | R13 + lower front gable projection and garage gable rake per the side elevations. See `JESB_Lot7_Model_R14_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R15.skp` | R14 + Dominika review items D01–D08, then edited by the owner (20.10.2026 17:30). See `JESB_Lot7_Model_R15_Change_Log.md`. |
| `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R16.skp` | **Current.** The owner's R15 + white lap siding, entry steps per xelev, garage bump corner per DWG. See `JESB_Lot7_Model_R16_Change_Log.md`. |

## 5. Issued sets

| File | Content |
|---|---|
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R01.pdf` | R01 review set, 8 A3 sheets (16.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R02.pdf` | R02 review set, 8 A3 sheets (16.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R03.pdf` | R03 review set, 8 A3 sheets (16.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R04.pdf` | R04 review set, 8 A3 sheets (16.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R05.pdf` | R05 review set, 8 A3 sheets (16.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R06.pdf` | R06 review set, 9 A3 sheets incl. A-902 roof plan QA (16.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R07.pdf` | R07 review set, 9 A3 sheets (16.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R08.pdf` | R08 review set, 9 A3 sheets (17.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R09.pdf` | R09 review set, 9 A3 sheets (17.10.2026) |
| `04_Visualization/Renders/R10/JESB_Lot7_R10_Render_Elevation_*.png` | V-Ray photoreal elevations, 4 views at 3200 x 1712 (17.10.2026). The DWG cross-check is in `QA_Render_vs_DWG/`. |
| `05_Presentations_and_Issued/RFI/PROJADES_JESB_Lot7_RFI-001_Elevations_vs_Model_2026-10-17.pdf` | RFI-001 to Purohit Architects: 9 elevation-vs-model differences, 10 A3 pages (17.10.2026). Text and evidence in `00_Project_Admin/RFI/`. The owner answered all 9 items on 17.10.2026; see `00_Project_Admin/RFI/JESB_Lot7_RFI-001_Response_Log.md`. Closed: R11/R12. |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R10.pdf` | R10 review set, 9 A3 sheets (17.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R11.pdf` | R11 review set, 9 A3 sheets (17.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R12.pdf` | R12 review set, 9 A3 sheets (17.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R13.pdf` | R13 review set, 9 A3 sheets (17.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R14.pdf` | R14 review set, 9 A3 sheets (17.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R15.pdf` | R15 review set, 9 A3 sheets (20.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R16.pdf` | R16 review set, 9 A3 sheets (20.10.2026) |
| `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Visualization_A3_R14.pdf` | Projades A3 visualization set, 6 sheets (V-000 to V-105), in English, laid out from the AI renders in `04_Visualization/Renders/R14_AI/` (17.10.2026). The source PDF in that folder is unchanged. |
| `04_Visualization/Renders/R13/JESB_Lot7_R13_Render_Elevation_*.png` | V-Ray photoreal elevations from model R13, 4 views at 3200 x 1712 (17.10.2026). DWG cross-check in `QA_Render_vs_DWG/`. |
