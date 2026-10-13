# JESB Lot 20 — SketchUp Model v9 Change Log

Date: 2026-10-13
Source model: `JESB_Lot20_v8.skp` as saved by hand on 2026-10-12 14:41 (unchanged)
Result: `JESB_Lot20_v9.skp`, images in `exports_v9/`

Request: the black Hardie panel between the entry door and the window above it appears to pop out; it should be in line with the window and the door.

## Finding

In v8 the three elements were not in one plane:

| Element | Front face (distance behind the panel) |
|---|---|
| Black Hardie panel | on the wall face — reference |
| Window frame above | flush with the panel |
| Double door, leaf face | 2.4" behind the panel |

The panel sat on the face of the wall while the door was set back in the wall opening, so the panel overhung the door by 2.4". In elevation all three already had the same visible width (84", the width of the wall opening). The rendered image exaggerates the step; in the model it was 2.4".

## Change made

The two door leaves were moved 2.3" toward the front, so the door face is now in the plane of the black panel and the window frame (0.05" behind it, to avoid overlapping faces). Door handles project in front of that plane as before.

Nothing else was changed. The panel, the window and the wall opening are as in v8.

## Note

- The door unit is 86.5" wide and the wall opening 84"; the edges of the door are hidden behind the white wall on both sides, as before.
- Any render made from v8 still shows the old step and has to be regenerated from v9.

## Exports (`exports_v9/`, 2400 x 1500 PNG)

Front, rear, left and right elevations, one perspective, and `JESB_Lot20_v9_Views.pdf` with the four elevations.
