# JESB Lot 19 — SketchUp Model v3 Change Log

Date: 2026-10-15
Source model: `JESB_Lot19_v2.skp` as saved by the owner's representative on 2026-10-15 15:33 (unchanged; it includes their own edits, e.g. wood-tone accent panels and black fascia)
Result: `JESB_Lot19_v3.skp`, images in `exports_v3/`

Instructions: add terrain around the model; add the cladding under the eaves marked in red on the front elevation.

## 1. Frieze board under the eaves

The red mark on A-300 points to the band directly under the eave, labelled "5/4" x 8" FRIEZE BOARD, ENG. WD. TRIM, ARCTIC WHITE, OR EQ., TYP."

- Added on every exterior wall that runs up to the main roof: a white board 7.3" high (z 265.2"–272.5", up to the soffit), 0.75" proud of the wall, 29 pieces, 272 ft in total (group `Frieze Board - Arctic White 5/4x8 (v3)`, material `Trim - Arctic White`).
- Not on the entry tower (it has its own frieze under the tower roof) and not under the garage roof (no room between the garage wall top and its fascia, and none is drawn there).
- The undersides of all roofs (soffits) are painted the same Arctic White (`Soffit - Arctic White`).
- Where a window head is higher than the frieze (several upper windows have heads at 271.6"), the window frame stays in front of the board.

## 2. Terrain

- A ground surface around the house, about 35 ft beyond it on every side (group `Terrain (grade from wall bottoms, v3)`, material `Terrain - Lawn`).
- The grade follows the model's own wall bottoms, which already follow the drawn grade (lower at the front and garage, about 15" higher at the rear), and is interpolated smoothly between them on a 24" grid. It sits 2.5" below the wall bottoms so a strip of foundation shows, as on the drawings.
- The lawn is kept below the driveway slab so the driveway stays visible.
- A ground section (skirt) down to z −150" closes the edges, so the elevations show the ground as a solid mass.
- No site plan is in the drawing set, so the lot lines, street and the grade away from the house are not modelled; the surface simply continues at the grade found at the walls.

Nothing else was changed.

## Exports (`exports_v3/`, 2400 x 1500 PNG)

Four elevations, perspective, `JESB_Lot19_v3_Views.pdf`, an aerial site view, a rear perspective and a frieze detail.
