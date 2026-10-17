# JESB Lot 7 – Exterior Model R07 – Change Log

Date: 2026-10-16
Based on: R06, and through it R01–R05.

## Requests

1. The stone headers are wrong. On the elevations, windows set side by side in a group carry **one continuous header** and one surround around the whole group (screenshot of the rear windows). The model gave each window its own header.
2. Add railings to the entry steps and to the terrace stair, as drawn on the elevations.

## Changes

### Continuous headers and surrounds over window groups

Windows of the same height set side by side form one group when the gap between them is 13" or less, as drawn on layer `FINE` of `xelev_lot 7G.dwg`.

| Group | Units | First floor | Second floor |
|---|---|---|---|
| Rear (east), north rank | 3, x 40.96..172.96 | One header x 39..175, casings at the group ends | One surround around the group |
| Rear (east), middle rank | 4, x 262.48..400.48 | One header x 260.5..402.5 | One surround around the group |
| Guest bedroom bay (north) | 3 | One header across the bay | – |
| Dormer bays (siding) | 4 each | – | One casing around the whole group |

The narrow brick piers between the units stay brick. Single windows are unchanged.

The R04 code sorted the openings by position only. Because the rear wall carries both storeys, first- and second-floor windows alternated in that order and the groups never formed. They are now sorted by height first.

### Stair railings (xelev front and south, layer `A-Elev-Decking`)

The railings are drawn as wrought iron. In the model, each railing has:
- a newel post at each end;
- a double top rail (the ring band between the two rails simplified to a bar);
- a bottom rail parallel to the nosing line;
- 5/8" pickets at about 5".

New material `Railing - Black Iron`.

| Stair | Railings | Height above the nosing line |
|---|---|---|
| Entry steps: 5 risers from the porch (-0.5) to grade (-38) | Both sides, x 363.75 and 448.25 | 29" (post tops 28.7 at the porch, as drawn) |
| Terrace stair: 6 risers from the deck (-4) to grade (-50), x 705..760 | Both sides, x 705.75 and 759.25 | 32" (rail ends against the 42" terrace guard) |

The entry steps were widened to the porch width, x 363..449, as drawn; they were 368..444 before.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R07.skp`. R01–R06 are kept.
- Exports and QA: `04_Visualization/Exports/R07/`. New close-ups: `..._QA_rear_headers`, `..._QA_entry_stair`, `..._QA_terrace_stair`.
- A3 set (9 sheets): `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R07.pdf`

## Open question added

13. **Railing finish and colour.** The elevation draws decorative wrought iron with a ring band; the model uses black iron. Please confirm the product and colour. The ACC list does not cover railings.
