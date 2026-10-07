# JESB Lot 2 — SketchUp Model v3 Change Log

Date: 2026-10-06
Source model: `JESB_Lot2_v2.skp` (unchanged)
Reference drawing: `Lot 2 _revisions1.dwg` / `Lot 2_revision1.pdf` (revision 10/5/26)
Result: `JESB_Lot2_v3.skp`, images in `exports_v3/`

v3 applies the owner's decisions on the open questions from the v2 change log.

## Decisions received

| # | Question (v2) | Decision | Action in v3 |
|---|---|---|---|
| 1 | Flat canopy over the front door | Keep as is | None |
| 2 | Eave overhang | 12" on the whole roof, to match the DWG | All three roofs rebuilt |
| 3 | Garage door positions | Move both doors to the plan positions | Both doors and openings moved |
| 4 | Driveway | Widen the slab | Slab widened |
| 5 | Garage door style | Keep as is | None |

## Changes made

### Roofs — 12" overhang everywhere

- **Main roof** rebuilt from the DWG roof plan as one clean solid: garage/west hip, main hip, front bay, rear bump, east wing, right-hand bay and the entry tower roof, all 6:12, eave level unchanged (260.79"). Every eave is 12" outside the model's exterior wall face. The old roof pieces, which overlapped each other and had 5"–7" overhangs, were removed.
- **Dining roof** rebuilt with 12" overhangs (4:12 sides, 6:12 rear hip, as on the roof plan).
- **Rear lean-to roof** over the garage rebuilt with a 12" overhang at the rear (the west side already had 12").
- Because the eave height is fixed and the eaves moved out, ridges rise slightly: main ridge +0.7", dining ridge +1.2", lean-to top +2.4".
- Detail level is unchanged: single shingle surfaces with a flat soffit plane, no fascia, gutters or downspouts.

### Garage doors — plan positions

- Both 16' x 8' openings and both door instances moved 3.23" toward the rear, so that measured from the front corner of the garage the wall reads as on sheet 3: 30" pier, 16'-0" door, 25" pier, 16'-0" door.
- Stone base, sill band and headers follow the openings. Door component and style unchanged.

### Driveway

- Slab widened toward the front by 22.9" so it covers both doors. It now extends 5.3" past the outer jamb of each door (the same margin the old slab had at the rear door). Length and thickness unchanged.

Nothing else was changed. The hidden reference tag `REF_DWG_Rev_2026-10-05` and the saved camera view are as in v2.

## Exports (`exports_v3/`, 2400 x 1500 PNG)

| File | View |
|---|---|
| `JESB_Lot2_v3_Elevation_Front.png` | Front elevation, parallel projection |
| `JESB_Lot2_v3_Elevation_Rear.png` | Rear elevation, parallel projection |
| `JESB_Lot2_v3_Elevation_Left.png` | Left (garage) elevation, parallel projection |
| `JESB_Lot2_v3_Elevation_Right.png` | Right elevation, parallel projection |
| `JESB_Lot2_v3_Perspective.png` | Perspective from the front-left, same camera as v1/v2 |

## Open questions

1. **Where the 12" is measured from.** In v3 it is measured from the model's exterior wall face, which matches the DWG elevations. The DWG roof plan measures 12" from the framing line, which leaves about 7" clear of the brick face on the veneered walls. Say if the roof-plan reading is preferred.
2. **Model is larger than the DWG at the rear and the east wing.** The rear garage wall and the north wall of the east wing sit about 10" further out in the model than in the 10/5 DWG; the east and rear main walls about 5". The roof follows the model walls, so it is that much larger than the DWG roof there. The walls were not corrected (out of scope).
3. **Rear garage pier.** With the doors at plan positions the rear pier is 51" in the model against 46" on the plan, because the model's garage wall is 5" longer.
4. **Flat patch at the top of the entry tower roof** (about 12" x 17"), modelled as drawn on the roof plan. Still to be confirmed by the architect.
5. **Driveway width.** The DWG has no site plan, so the 5.3" margin past the door jambs is an assumption carried over from the existing slab.
6. **Not checked.** Windows and the rear and right elevations were still not audited against the DWG.
