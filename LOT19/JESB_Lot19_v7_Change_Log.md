# JESB Lot 19 — SketchUp Model v7 Change Log

Date: 2026-10-19
Source model: `JESB_Lot19_v6.skp`, as saved by the owner on 2026-10-19 at 12:06 (unchanged)
Result: `JESB_Lot19_v7.skp`, images in `exports_v7/`

## 1. Rear patio deck railing: light brown metal instead of wood

- New material `ACC Lot 19 - Railing - Light Brown metal`. It is a plain colour, RGB 145 / 118 / 92, the average of the ACC Lot 19 Light Brown sample (I17).
- Applied to:
  - all six `15.Balcony Railing` instances around the deck: rails and balusters, the whole component;
  - the six deck posts.
- Geometry is unchanged.

## 2. Railing on the two steps up to the deck

The steps are at the north-west corner of the deck: grade 21.8 → step 29.3 → deck 36.8. They have 7.5" risers and a 10" tread, run x 1373–1383 and are 59" wide.

On the north (open) side, a new group `Deck steps railing - light brown metal (v7)` was added:

| Part | Size | Position |
|---|---|---|
| Bottom post | 5.1 × 6.2, with cap | on grade at x 1361–1366, 12" past the lower riser |
| Handrail | 1.5" square | sloping with the steps, from the deck corner post down to the bottom post |
| Bottom rail | 1.5" square | 24" below the handrail |
| Balusters | ¾" square | about 4" spacing |

- The old wood post that stood on the step was removed.
- The south side of the steps is the deck itself, 7.5" above the step, with its own railing, so it was left as is.

## Note

- The owner's `ACC Lot 19 - Siding dec - Light Brown` material was changed in v6 to a dark wood texture (RGB 70 / 26 / 4). It still covers the accent panels and the deck boards and was not touched.
- The railing uses the ACC sample colour, so it is lighter than that wood.

## Exports (`exports_v7/`)

- Four elevations and a perspective.
- A rear deck view and a close-up of the steps.
- `JESB_Lot19_v7_Views.pdf`.

Script: `tools/lot19/build_v7.rb`.
