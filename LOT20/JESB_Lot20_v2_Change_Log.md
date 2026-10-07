# JESB Lot 20 — SketchUp Model v2 Change Log

Date: 2026-10-07
Source model: `JESB_LOT20_SKETCHUP_MODEL.skp` (2026-09-09, treated as v1, unchanged)
Reference drawing: `Lot-20 base rend.dwg` (saved 2026-10-07), cross-checked with `Lot-20-ACC response.pdf` (10/5/26)
Result: `JESB_Lot20_v2.skp`, images in `exports_v2/`

Items 1 and 2 of the comparison in `comparison_2026-10-07/JESB_Lot20_DWG_vs_SketchUp.md`, as instructed by the owner.

## Changes made

### 1. Front elevation — upper wall above the garage

- The three small windows were replaced by two, at the DWG positions and size.
- Each window is 32" x 32" (was 32" x 31"), bottom of opening 216.3" above the slab.
- Measured from the left (garage-side) corner of that wall: first window 84.2" to 116.2", second window 197.7" to 229.7".
- The former right-hand opening was closed and the wall face made continuous in brick.
- A 35" x 4" sill was added under each window, in the same material as the other sills on the house.

### 2. Siding — vertical board and batten

- The siding material (`Material5`) now carries a white vertical board and batten texture with battens at 16" on centre, replacing the horizontal lap siding texture.
- This applies everywhere that material was used, about 2,200 sq ft: rear elevation (left bay, balcony bay, garage wing), left side elevation, and the rear part of the right side elevation.
- The texture file is saved at `textures/board_batten_white_16in.jpg` and is embedded in the model.

Nothing else was changed. The saved camera view is the same as in v1.

## Exports (`exports_v2/`, 2400 x 1500 PNG)

Front, rear, left and right elevations (parallel projection) and one perspective from the front-left.

## Notes

1. **Battens are a texture, not geometry**, matching how the siding was modelled before. On adjoining wall pieces the batten spacing restarts at each piece, so battens do not always line up across a joint.
2. **Colour.** The texture is white, per the ACC material list for Lot 20 (siding: White). The list also names a black "siding dec"; that was not applied because the drawings do not show where it goes.
3. **Batten spacing** of 16" comes from the DWG hatch pattern (`BOARD&BATTEN16`). The drawings do not dimension it.
4. The other items from the comparison (three left-side windows, roof heights, roof vents, fascia and gutters, basement windows and grade, balcony depth, garage door style) are not changed in v2.
