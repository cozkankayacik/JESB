# JESB Lot 19 — SketchUp Model v4 Change Log

Date: 2026-10-16
Source model: `JESB_Lot19_v3.skp` (unchanged)
Reference: `xelev_lot19.dwg` (exterior elevations, saved 2026-10-16), compared line for line with the model's orthographic views (`exports_v4/dwg_overlay_checks/`, DWG lines in red)
Result: `JESB_Lot19_v4.skp`, images in `exports_v4/`

## What the check found

| Elevation | Result |
|---|---|
| Front | Everything matches except the **entry door unit** |
| Right (garage side) | Matches; the garage doors differ only in their panel pattern |
| Rear | Matches |
| Left | Matches. Small note: the top of the entry tower roof shows about 4" above the main roof slope in the model; the DWG does not draw it. Not changed. |

## 1. Entry door (front)

In v3 the door was 6'-7" high with short sidelites, small glass strips above, and a grey panel filling the rest of the opening up to the canopy. The DWG shows a taller unit with a row of fixed transoms:

| | v3 | v4 (DWG) |
|---|---|---|
| Door | 39" × 79" | 36" (3'-0") × 100" |
| Sidelites | 17" × 79" + 14" glass above | 18" (1'-6") each, same height as the door |
| Transoms | — | three fixed transoms, 24" (2'-0") high, over sidelite / door / sidelite |
| Top of unit | 125" | 155.8", directly under the canopy |

- The unit fills the opening between the existing grey jambs (72" wide). The same door and window components were reused, re-sized; the door keeps its wood finish and vertical glass strip.
- The grey panel above the door was cut back to the top of the transoms, and the stone wall behind it was opened for the transom row.
- The bottom of the door stays on the existing threshold (z 32). In the DWG the porch floor is about 4" higher than in the model, which is why the door is 100" here rather than 95" as drawn; the head height matches the drawing.

## 2. Garage doors (right side)

Same size and position as in v2/v3. The panel pattern now follows the DWG:

- lower three rows: two raised panels per section (single door 4 across, double door 8 across);
- glass top row: each light divided by three vertical muntins and one horizontal muntin.

Nothing else was changed.

## Exports (`exports_v4/`, 2400 x 1500 PNG)

Four elevations, perspective, `JESB_Lot19_v4_Views.pdf`, an entry detail and a garage detail, and `dwg_overlay_checks/` (front and right of v4 and rear and left of v3 against `xelev_lot19.dwg`, plus a close-up of the entry).
