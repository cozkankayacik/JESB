# JESB Lot 7 – V-Ray Renders R10 – Cross-check against the Architect's DWG (xelev)

Date: 2026-10-17
Overlays: `JESB_Lot7_R10_Render_Elevation_*_vs_DWG.png`. The red lines are the xelev outlines, windows, doors, grade and band lines at 1:1.
Scale: 2.984 px per inch.

## 1. Render vs model

`JESB_Lot7_R10_Render_Framing_Check.txt` compares the render silhouette with the SketchUp R10 export on all four views. The bounding-box offset is at most 2 px (0.7 in), which is the width of a SketchUp edge line. The renders show the model exactly: no geometry was changed or added.

## 2. Model vs DWG: differences found

These differences come from the model, so they also appear in the SketchUp exports. None were changed. Each one waits for an owner or architect decision.

| # | View | Item | Model R10 | DWG (xelev) | Difference | Note |
|---|---|---|---|---|---|---|
| 1 | North (left) | West end of the garage wing (front wall, eave) | Wall ends ~20 in short of the DWG line | Wall and eave further west | ~18–22 in | Linked to the open garage-front item: xflr1 moved 9.36 in, xelev did not. |
| 2 | South (right) | Same west end of the garage wing | Wall ends short of the DWG line | Further west | ~9–16 in | The two side elevations disagree with each other (~20 in vs ~12 in). |
| 3 | Rear (east) | Main hip roof ridge | Ridge ~306 in long: 9:12 end hips per A-220. It matches the **front** elevation. | Ridge only ~131 in long: ends drawn at ~6:12 | ~175 in | **The DWG front and rear elevations disagree.** The model follows A-220 and the front elevation. |
| 4 | South, rear | Covered terrace hip roof | Ridge ~10–13 in lower (pitch 0.44 ≈ 5.3:12) | Steeper, ≈ 6:12 | ~10–13 in at the ridge | Eave height matches. Part of the open "pitches" item. |
| 5 | South | Terrace slider door | Head ~10 in higher | Head lower | ~10 in | Width and position match. |
| 6 | South | Upper-right window (2nd floor, east end) | ~75 in wide, ~8 in further west | ~72 in wide | 5–8 in | |
| 7 | North | Guest bedroom bay, 3 windows | ~35 in wide each | ~29–30 in wide each | ~5 in per window | Open item "GBr windows 36 vs 30". |
| 8 | Front (west) | Small window in the wing gable | Left of the DWG position | Further right | ~13 in | Open item "wing gable window position". |
| 9 | Front (west) | Front door | Flat brown leaf | Six-panel door | Detail | Door frame, sidelights and transom match. |

Everything else checked matches within line width:
- eaves, ridges and gable outlines;
- window positions and divisions;
- band and water-table lines;
- grade lines;
- dormers;
- accent roofs.

The stairs, railings and garage doors are not on the xelev layers used for this check.
