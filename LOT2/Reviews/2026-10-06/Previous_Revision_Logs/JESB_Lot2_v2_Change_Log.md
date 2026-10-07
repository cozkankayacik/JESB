# JESB Lot 2 — SketchUp Model v2 Change Log

Date: 2026-10-06
Source model: `JESB_LOT2_SKETCHUP.skp` (2026-09-09, treated as v1, unchanged)
Reference drawing: `Lot 2 _revisions1.dwg` / `Lot 2_revision1.pdf` (revision 10/5/26, sheets 1, 1.2 and 3)
Result: `JESB_Lot2_v2.skp`, images in `exports_v2/`

## Changes made

### 1. Roof — entry tower

The flat roof in the model was the grey slab on top of the entry tower (the bay with the stacked windows, right of the front door). The 10/5 revision cloud on sheet 1 replaces it with a hip roof tied into the main roof.

- Removed the flat slab on the tower.
- Lowered the tower walls from 284.45" to the main eave level (260.79"), so no wall stands above the roof.
- Added the DWG roof form over the tower, 6:12 pitch, shingle material of the existing roof:
  - front plane rising from the tower eave,
  - narrow west return plane with a hip and a valley into the main front plane,
  - valley into the west plane of the right-hand bay roof,
  - east plane of the right-hand bay extended up to meet the new front plane,
  - small flat patch at ridge height where the planes meet, as drawn on the roof plan,
  - eave soffit under the new overhang.
- Detail level matches the existing roof: single surfaces, no fascia, gutters, downspouts or soffit detailing.
- New geometry is one group, `Roof - Entry Tower (Rev 10-5-26)`, inside the existing roof group.

### 2. Garage doors

- South opening widened from 8'-0" to 16'-0" (height stays 8'-0"). The DWG tags both doors `16080 OVHD`, so 16' x 8' was used, not the 16' x 7' fallback.
- Wall, stone base, sill band and header over the opening adjusted to the new width. Pier between the two doors is 25", as on the plan.
- The 8' door was removed and replaced with a second instance of the existing 16' door component `Garage Doors`. Both garage doors now use that one component.
- The north door and its opening were already 16' x 8' and were not moved.

### 3. Reference DWG

- The revised DWG is imported on a hidden tag, `REF_DWG_Rev_2026-10-05`, with its roof plan aligned to the house. Turn the tag on to compare. It adds about 1 MB to the file.

Nothing else in the model was changed. The saved camera view is the same as in v1.

## Exports (`exports_v2/`, 2400 x 1500 PNG)

| File | View |
|---|---|
| `JESB_Lot2_v2_Elevation_Front.png` | Front elevation, parallel projection |
| `JESB_Lot2_v2_Elevation_Rear.png` | Rear elevation, parallel projection |
| `JESB_Lot2_v2_Elevation_Left.png` | Left (garage) elevation, parallel projection |
| `JESB_Lot2_v2_Elevation_Right.png` | Right elevation, parallel projection |
| `JESB_Lot2_v2_Perspective.png` | Perspective from the front-left, same camera as the v1 saved view |

## Open questions

1. **"Flat roof" scope.** Only the tower slab was treated as the flat roof. The flat canopy over the front door was kept because sheet 1 still shows it flat. Confirm.
2. **Tower eave overhang.** The DWG draws 12" overhangs. The existing model roof overhangs the entry wall by about 7", so the new tower eave uses 7.14" to line up with it. Say if 12" is wanted here, or on the whole roof.
3. **Flat patch at the top of the tower roof.** The roof plan shows a small rectangle where the tower plane, the bay plane and the ridge meet. It is modelled flat (about 8" x 19"). It looks like a drafting simplification; the architect should confirm how that junction is framed.
4. **Model and DWG do not match exactly elsewhere.** The model was built from an older base drawing: the house is about 5" wider and 5" deeper than the 10/5 DWG and several eaves sit a few inches off. This was left alone as outside the two revisions.
5. **Garage door positions.** The existing north door sits about 8" closer to the front than on the plan, and the garage wall is 490" long against 485" on the plan. Keeping the north door in place and the 25" centre pier leaves a front corner pier of 26.8" instead of the plan's 35". Alternative: move both doors to the plan positions.
6. **Driveway.** The driveway slab was not widened. Its edge now falls about 21" inside the south jamb of the new door.
7. **Garage door style.** The existing door component (panel door with a top row of lites) was reused as instructed. The left elevation on sheet 1.2 draws a fully gridded 4 x 4 door. Confirm which is intended.
8. **Not checked.** Only the two revision areas were compared against the DWG. Windows, rear and right elevations and the dining roof were not audited.
