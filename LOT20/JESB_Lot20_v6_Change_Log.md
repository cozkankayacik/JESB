# JESB Lot 20 — SketchUp Model v6 Change Log

Date: 2026-10-12
Source model: `JESB_Lot20_v5.skp` (unchanged)
Reference: `JE Lot 20 ACC and Render Feedback - 2026 10 10.pdf` — owner feedback by Tim & Aurora Trento, 6 slides, dated 10/10/2026. The slides mark up the v3 renders; the corrections are "to match the agreed contract drawing set JESB – LOT 20 ARCHITECT SET – TIM – Rev 2026 05 18".
Result: `JESB_Lot20_v6.skp`, images in `exports_v6/`

## Corrections requested and what was done

| # | Slide | Requested | Done in v6 |
|---|---|---|---|
| 1 | 2 | Upper wall above the garage: four windows instead of the two the ACC asked for | Four windows in two pairs |
| 2 | 3–6 | No window sills, whole house | All 12 sills removed |
| 3 | 4 | No soldier course, rowlock, stone band or decorative trim (left side, above the lower brick window) | Header band removed |
| 4 | 3 | No frieze board | Projecting band at the top of the garage front wall removed; brick now runs up to the roof |
| 5 | 3, 5 | Between windows: black J. Hardie Architectural Panel, no or minimal seams | Added at the entry and on the tall window bay; existing black panels kept |
| 6 | 3, 6 | White J. Hardie Architectural Panel, no or minimal seams | All joint lines removed from the white panels |
| 7 | 3–6 | Black gutters | Black gutters added along every eave |

### 1. Four windows above the garage

- The two 32" x 32" windows of v2–v5 were removed and the wall closed.
- Four windows, each 32" wide x 30" high (2'-6" as dimensioned on the contract elevation), heads at 248.3" in line with the other upper windows.
- Positions measured from the left (garage-side) corner of that wall, scaled from the owner's floor plan on slide 2: 29.5"–61.5", 65.5"–97.5", 207.5"–239.5", 243.5"–275.5". The two windows of a pair are 4" apart.
- Rooms served, per the owner's plan: 1 master shower, 2 toilet, 3 closet, 4 second bathroom.

### 2–4. Sills, header band, frieze

- Removed: 12 window sills on all four sides (including the two added in v2 and the long sill under the rear glazing) and the 8" header band above the lower brick window on the left side.
- Garage front, left of the bay: the 9.2" band that projected 4.1" at the top of the wall was removed and the brick wall raised to the underside of the roof. Two flush bands at the top of the garage walls (bay return and garage-door wall) now carry the material of the wall below.

### 5. Black panels between windows

- Entry: the wall between the head of the front door and the sill of the window above it (112" x 20.8") is now `Hardie Panel - Black`.
- Tall three-window bay: the two strips between the stacked windows (54" x 8") are now `Hardie Panel - Black` (they were plain black before).
- Unchanged: the black panels on the two front window bays (one piece each) and on the rear (two pieces).

### 6. White panels without seams

- The equal-panel joint lines drawn in v5 were removed from all white panel areas (garage bay, bay left of the entry, tall window bay, right-side bay). They now read as plain white surfaces.

### 7. Black gutters

- A 5" x 5" black gutter runs along every eave of the main roof and the garage roof, 334 ft in total, with its top at the roof edge. The white fascia shows 3" below it.

Nothing else was changed: roofs, other windows, site and the saved camera view are as in v5.

## To confirm

1. **Window positions above the garage** are scaled from the small plan on slide 2 (accuracy about ±1"). The contract drawing set of 2026-05-18 is not in the project folder; with it the positions can be set exactly.
2. **Seams.** "No or minimal seams" was taken as no visible joints on the white panels. The rear black panel is 182" wide and keeps the single centre joint set on 10/09; say if it should be seamless too. Real panels of this size will need joints somewhere.
3. **Gutters.** Only gutters were added. Downspouts are not modelled (the DWG shows them; the ACC list has them black as well). The gutter is a simple box profile.
4. **Frieze.** Only the garage front had a projecting band in the model. The architect's DWG still labels an 8" frieze board and a stone sill; those notes now conflict with the owner's instruction.
5. **ACC window request.** The ACC had asked for two windows on this wall; this version follows the owner's four-window proposal, which still needs ACC approval.

## Exports (`exports_v6/`, 2400 x 1500 PNG)

Front, rear, left and right elevations, one perspective, and `JESB_Lot20_v6_Views.pdf` with the four elevations.
