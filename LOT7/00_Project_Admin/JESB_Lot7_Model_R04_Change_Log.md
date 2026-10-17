# JESB Lot 7 – Exterior Model R04 – Change Log

Date: 2026-10-16
Based on: R03, and through it R02 and R01.

## Request

The owner asked for three things to follow the elevation drawings:
- the stone headers;
- the frames around the windows;
- thin grid muntins on every window.

## Source

The elevation DWG `xelev_lot 7G.dwg`:
- layer `FINE` (green): window and door surrounds, headers, the frieze band;
- layers `A-Elev-Glaz-Munt` and `A-Elev-Decking` (red): window grids. Every window unit has one vertical bar at its centre and one horizontal bar at mid-height, giving 4 lites.

## Changes

| Item | R04 |
|---|---|
| Stone headers | Cast stone, 8" high, 2" wider than the opening each side, 1.25" proud. Over every first-floor window, the entry door unit, both garage doors and the terrace sliding door, e.g. heads at 106.9 give a header at 106.9..114.9 as drawn. New material `Cast Stone - Window Header`. |
| First-floor casings | 2" white side casings from the sill to the header, 0.75" proud |
| Second-floor surrounds (brick walls) | 4" side casings and a 5.5" apron under the sill, top against the frieze band (as drawn: window heads at 228.6 = frieze bottom) |
| Siding-wall windows (wing gable, dormer bays) | 3.5" casing all round |
| Window grids | Thin 0.75" muntins: one vertical and one horizontal per unit, 4 lites. Twin windows have a frame mullion and a cross in each unit. The terrace slider has a cross per panel at z 48, as drawn. The generic meeting rail of R01–R03 is replaced. |
| Not gridded | Basement egress windows (no grid on the elevation, below grade), entry door side lights and transom, garage doors |
| Frieze band | Moved to z 228.6..238.1 per the `FINE` lines; it was 233.6..241.6 in R01–R03 |

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R04.skp`. R01–R03 are kept.
- Exports and QA: `04_Visualization/Exports/R04/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R04.pdf`

## Open question added

12. **Header material and colour.** The headers are modelled as light buff cast stone. The ACC list says "no stone" for Lot 7. Please confirm whether the headers are cast stone, precast or a brick soldier course, and give the colour.
