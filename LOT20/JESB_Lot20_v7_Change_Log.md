# JESB Lot 20 — SketchUp Model v7 Change Log

Date: 2026-10-12
Source model: `JESB_Lot20_v6.skp` (unchanged)
Reference: `Lot-20 base rend.dwg` as saved 2026-10-12 12:04, and `Lot-20 second floor_r1.pdf` (second floor plan, revision 1)
Result: `JESB_Lot20_v7.skp`, images in `exports_v7/`

Task: the windows above the garage are to be symmetric; update the model from the DWG.

## What changed in the DWG

Compared with the DWG of 2026-10-07, only the second floor plan changed: the front wall of the wing above the garage now has four windows, dimensioned symmetrically. The DWG elevations were not updated and still show two windows on that wall.

Dimensions on the plan, from the left corner of the wall to the right corner (wall length 313.5"):

29" | window 32" | 14.5" | window 32" | 98.5" | window 32" | 14.5" | window 32" | 29"

## Change made

The four windows on the wall above the garage were moved to these positions. Measured from the left corner of the wall:

| Window | v6 | v7 (DWG plan) |
|---|---|---|
| 1 | 29.5"–61.5" | 29.0"–61.0" |
| 2 | 65.5"–97.5" | 75.5"–107.5" |
| 3 | 207.5"–239.5" | 206.0"–238.0" |
| 4 | 243.5"–275.5" | 252.5"–284.5" |

- The margins at both ends are now equal (29"); in v6 they were 29.5" and 38".
- The two windows of each pair are 14.5" apart (4" in v6). The black Hardie panel between them was kept and is now 14.5" x 30".
- Window size is unchanged: 32" wide x 30" high, heads at 248.3".

Nothing else was changed.

## To confirm

1. **Window height.** The plan gives widths only. The model keeps 30" (2'-6"), the height on the owner's contract elevation; the two windows still drawn on the DWG front elevation are 32" high.
2. **Black panel between the paired windows.** Kept from v6 at the new 14.5" width. The DWG plan shows wall between the windows.
3. **DWG front elevation** still needs to be updated by the architect to four windows.

## Exports (`exports_v7/`, 2400 x 1500 PNG)

Front, rear, left and right elevations, one perspective, and `JESB_Lot20_v7_Views.pdf` with the four elevations.
