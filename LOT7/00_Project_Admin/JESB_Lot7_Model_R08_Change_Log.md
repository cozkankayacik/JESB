# JESB Lot 7 – Exterior Model R08 – Change Log

Date: 2026-10-17
Based on: R07, and through it R01–R06.

## Request

The owner asked for the ACC Material Package (`ACC MATERIAL PACKAGE.xlsx`) to be learned and its materials entered correctly in SketchUp, for **Lot 7 only**. Gutters and downspouts are not to be modelled.

## Source

`ACC MATERIAL PACKAGE.xlsx`, sheet EXTERIOR. Lot 7 is column F (selection) and G (sample image). The sample images are saved in `00_Project_Admin/ACC_Material_Samples/` and used as textures from `tools/lot7_rebuild/textures/acc_lot7/`.

## Materials in the model (R08)

| ACC item | Lot 7 selection | SketchUp material | How |
|---|---|---|---|
| Roof | Mission Brown | `ACC Lot 7 - Roof - Mission Brown` | ACC sample image, 23.4 x 24.2 in (5 5/8 in exposure) |
| Brick | Magnolia (US Brick) | `ACC Lot 7 - Brick - Magnolia (US Brick)` | ACC sample image, 17.6 x 17.3 in (8 x 2 2/3 in module) |
| Stone | no stone | – | No stone veneer is modelled |
| Siding | Cobble Stone | `ACC Lot 7 - Siding - Cobble Stone` | ACC sample image, 13.6 x 14 in (7 in exposure) |
| Siding dec | White | `ACC Lot 7 - Siding Dec - White` | Plain white. Used for the decorative panels, the garage bump face and the lower gable infill; replaces the R03 speckled texture. |
| Trims | White | `ACC Lot 7 - Trims - White` | Colour |
| Soffit / fascia (LP SmartSide) | White | `ACC Lot 7 - Soffit and Fascia - White (LP SmartSide)` | Colour |
| Gutters and downspouts | White | `ACC Lot 7 - Gutters and Downspouts - White` | Material defined; gutters and downspouts not modelled (owner instruction) |
| Front door | Brown | `ACC Lot 7 - Front Door - Brown` | ACC colour #4B392F |
| Windows / patio doors | White | `ACC Lot 7 - Windows and Patio Doors - White` | Colour; grids as on the elevations |
| Garage door colour | Brown | `ACC Lot 7 - Garage Door - Brown (Cottage, glass on top)` | ACC colour #4B392F |
| Garage door style | Cottage with glass on top | – | Existing door: glass top row and vertical boards on the lower sections. Geometry unchanged in R08. |

The materials of the owner's original model (grey shingles, tan brick, its siding texture) are no longer used.

## Materials outside the ACC package (to confirm)

| Material | Where | Note |
|---|---|---|
| `Not in ACC - Metal Roof - Standing Seam` | Portico and front bay fronts, dormers, guest bay roof (standing seam on the elevations) | Colour not in ACC |
| `Not in ACC - Cast Stone Window Header (ACC: no stone)` | Window and door headers (stone header on the elevations) | ACC says "no stone"; open item 12 |
| `Not in ACC - Railing - Black Iron` | Stair railings | Open item 13 |

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R08.skp`. R01–R07 are kept.
- Exports and QA: `04_Visualization/Exports/R08/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R08.pdf`
