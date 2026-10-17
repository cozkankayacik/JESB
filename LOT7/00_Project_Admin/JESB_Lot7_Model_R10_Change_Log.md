# JESB Lot 7 – Exterior Model R10 – Change Log

Date: 2026-10-17
Based on: R09.

## Change

| Item | R09 | R10 |
|---|---|---|
| Accent metal roofs: portico, front bay fronts, dormers, guest bay | The owner's seam texture was tinted dark bronze, but it read as a checkered tile pattern in the elevations. | New standing-seam texture `tools/lot7_rebuild/textures/metal_standing_seam_dark_bronze.png`: 16 in panels, 1 in raised seams running down the slope, dark brown bronze RGB 74/56/42. Script: `make_seam_texture.py`. |

The material name is unchanged: `Owner - Metal Roof - Standing Seam - Dark Brown Bronze`. No geometry changed, and the QA overlays against xelev and A-220 are unchanged.

## AI render input package

The owner asked for photorealistic elevations through an AI image tool, keeping the driveway as an assumption. The package is in `04_Visualization/Working/AI_Render_Package_R10/`:
- one folder per elevation, each with the input elevation, the reference perspective(s) and the prompt;
- ACC finish swatches;
- a README.

The prompts state that the main roofs are asphalt shingles and only the accent roofs are metal.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R10.skp`
- Exports and QA: `04_Visualization/Exports/R10/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R10.pdf`
