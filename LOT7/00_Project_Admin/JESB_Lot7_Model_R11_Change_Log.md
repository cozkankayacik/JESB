# JESB Lot 7 – Exterior Model R11 – Change Log

Date: 2026-10-17
Based on: R10.
Source: the owner's answers to RFI-001 (17.10.2026). "Architect's drawing" means `xelev_lot 7G.dwg` (16.10.2026).

## Owner answers and model changes

| RFI-001 | Owner answer | R11 |
|---|---|---|
| 01 / 02 Garage front | Follow the architect's drawing (elevations) | Garage front moved **9.36 in forward**, back to the position of the elevations and the previous plan issue: bump face y 4.96 (was 14.32), main garage face y 16.0 (was 25.36). The garage roofs, eave returns, decorative panels, the front window, the garage slab and the driveway all follow. Result on the south elevation: the walls fall on the xelev lines within 0.6 in. |
| 03 Main roof, rear view | Follow the architect's drawing | **Not changed – the owner must decide (see below).** |
| 04 Terrace roof pitch | Keep as modelled | Unchanged (0.44 ≈ 5.3:12). |
| 05 Terrace slider | Follow the elevation | Slider unit x 678.86–750.86, head **84.0 in (7'-0")**; it was 96.0 in. The stone header follows. |
| 06 South upper-east window | Keep as modelled | Unchanged. |
| 07 Guest bay windows | Keep as modelled | Unchanged (36 in). |
| 08 Wing gable window | Follow the elevation | Moved to x 138–162; it was 124.96–148.96. 24 x 32 in, z 226–258. Its casing follows. |
| 09 Entry door | Follow the elevation | **Six-panel leaf** as drawn (xelev ARDOOR): 2 x 3 raised panels with outer bevel, leaf 36 in. Sidelights and transom are unchanged. |

## Still different after R11 (for information, not changed)

- **North elevation, garage end.** The north elevation draws the garage front about 10 in further west than the south elevation, and its wing wall about 5 in further west. R11 follows the south elevation. The two side elevations of xelev disagree with each other here.
- **Lower front gable projection.** Both side elevations draw the lower front gable's front plane about 11 in in front of the model's rake (y ≈ −12 against −1.04). The owner's instruction covered the walls only, so the roof is unchanged.
- **Garage door heights (new finding).** The south elevation draws the 8 ft-wide garage door **6 ft high** (z −38.1 to 33.9) and the 16 ft door 8 ft high. The model has both at 8 ft (plan sizes). The 8 ft door is also drawn about 3 in further west (49–145 against 52–150).

## RFI-001.03: why it was not changed

An orthographic front view and an orthographic rear view of the same roof always show the same outline, mirrored. The front elevation (and A-220) draws the main ridge about 311 in long. The rear elevation draws it about 131 in long, at the same ridge height. No single roof can show both, so following the rear elevation means the front elevation and A-220 no longer match.
- Option A: keep the A-220 and front-elevation roof (as R10).
- Option B: rebuild the main roof to the rear elevation. The ridge becomes about 131 in and the end hips about 6:12, so the front elevation then also shows the short ridge, which differs from the front drawing and A-220.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R11.skp`
- Exports and QA: `04_Visualization/Exports/R11/`, including `QA_Overlay_vs_Architect_DWG`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R11.pdf`
- The V-Ray renders are still R10. They are to be re-rendered once item 03 is decided.
