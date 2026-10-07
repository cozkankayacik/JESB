# JESB Lot 2 — SketchUp Model v4 Change Log

Date: 2026-10-06
Source model: `JESB_Lot2_v3.skp` (unchanged)
Reference drawing: `Lot 2 _revisions1.dwg` / `Lot 2_revision1.pdf` (revision 10/5/26), sheets 1, 1.1 and 1.2
Result: `JESB_Lot2_v4.skp`, images in `exports_v4/`

## Requests

1. Match the terrain surface and the visible foundation limits to the sheets.
2. Match the cladding above the entry to the drawing: make it brick.

## Changes made

### Terrain

The model had no ground at all; the house stood on SketchUp's background. v4 adds a terrain surface built from the grade lines on the four elevations.

| Location | Grade (model inches, relative to the garage slab at -3) | Source |
|---|---|---|
| Driveway side, along the garage wall | -3 | Left elevation |
| Garage front wall | -3 at the corner rising to 0 | Front elevation |
| Recessed front wall and front bay | -2 and -4 | Front elevation |
| Entry walk, tower and right-hand bay front | -16.2 | Front elevation |
| East wall | -17.9 at the front corner falling evenly to -72 | Right elevation |
| Walk-out level (east wing rear, rear main wall, dining east side) | -72 | Right and rear elevations |
| Dining room rear face | -72 at its east corner rising evenly to +8.8 at its west corner | Rear elevation |
| Patio | +8.8 | Rear and left elevations |
| Garage rear wall | +8.8 at the patio falling to -3 at the west corner | Rear elevation |

- The terrain is one group, `Terrain (grade per elevations, Rev 10-5-26)`, with its own material `Terrain_Grade`. It extends about 35 ft beyond the house on every side and has a vertical edge so the ground reads as solid in elevation views.
- The front walk was lowered to the new grade.

### Visible foundation limits

Checked on all four sides against the elevations.

- **Already matching, left as is:** garage side and front (concrete from grade to +6, stone above); right-hand bay front (stone to -12, concrete to grade); east wall (brick stepping down at -11.9 / -23.9 / -35.9 / -47.9 at the drawn positions); walk-out walls (brick to -66, concrete to -72); dining room rear face (stepped brick at the drawn positions, heights within 1" of the drawing).
- **Entry tower:** the brick stopped at 0 with nothing below. Added the exposed concrete foundation from 0 down to grade, as on sheet 1.
- **Entry stone piers:** stopped at 0. Extended in stone down to grade, as on sheet 1.
- **Entry steps:** two risers added so the steps reach the lower grade (now six risers).

### Cladding above the entry

- The wall above the entry canopy, around the upper window, was unpainted (white). It is now brick, the same brick material as the rest of the front (`white stone brick craft`).

Nothing else was changed. Saved camera view and the hidden reference tag are as before.

## Exports (`exports_v4/`, 2400 x 1500 PNG)

Front, rear, left and right elevations (parallel projection) and one perspective, named as in earlier versions with `v4`.

Re-exported 2026-10-06 from the owner's updated `JESB_Lot2_v4.skp` (saved 4:43 PM):

- The perspective uses the view saved in that file (straight-on from the front, eye level).
- The ground is shown as one dark mass filling the bottom of the frame, with no pale slab or edge line, to match the owner's reference image. This is a display setting applied only while exporting; the model file was not changed.

## Open questions

1. **Entry steps and front door height.** The drawing shows four risers from the stoop down to grade. The model's front door and stoop sit about 12"–16" higher above the stone base than drawn, so reaching the drawn grade took six risers. The door was not moved. Confirm whether the door and stoop should be lowered to the drawn height.
2. **Front yard slope.** The left elevation shows the ground dropping from -3 at the garage corner to about -19.7 roughly 8'-7" in front of it; the front elevation shows -16.2 across the entry. The terrain blends between the two. There is no site or grading plan in the set, so the ground beyond the walls is an interpretation.
3. **Ground away from the house.** Beyond each wall the terrain continues level at the height drawn at that wall. Real lot grading, drainage swales and the street are not in the drawings.
4. **Patio height.** The drawing shows the patio at +8.8; the model's patio deck top is at +16.9. The deck was not changed; the terrain meets it at +8.8.
5. **Dining rear brick steps** are within 1" of the drawn heights and were left alone.
6. **Small mismatches at wall jogs.** Where the front wall steps back, the drawn grade jumps by 2"; the terrain makes that transition over a few inches at the corner.
