# JESB Lot 20 — SketchUp Model v4 Change Log

Date: 2026-10-08
Source model: `JESB_Lot20_v3.skp` as saved by the owner on 2026-10-08 12:07 (unchanged)
Reference: `Kami Export - Lot-20-ACC response.pdf` (marked-up sheets 1, 1.1 and 1.2, exported 2026-10-08)
Result: `JESB_Lot20_v4.skp`, images in `exports_v4/`

Task: update the model to the facade revision notes in the Kami export.

## The notes

The mark-up has seven red notes on the elevations, and the "STUCCO FINISH" label on the front elevation is crossed out. Each note reads either "SIDING BOARDS arctic white" or "SIDING BOARDS black". Together they replace every stucco / panel area on the house with siding boards.

| # | Sheet | Where the note points | Finish |
|---|---|---|---|
| F1 | Front | Garage front bay around the window | Arctic white |
| F2 | Front | Panel between the upper and lower windows, bay left of the entry | Black |
| F3 | Front | Rest of the bay left of the entry | Arctic white |
| F4 | Front | Tall three-window bay right of the entry (the crossed-out stucco note) | Arctic white |
| F5 | Front | Panel between the upper and lower windows, right-hand bay | Black |
| R1 | Rear | Panel between the upper windows and the lower glazing, left of the balcony | Black |
| S1 | Right side | Bay with the two small windows | Arctic white |

There are no notes on the left side elevation.

## Changes made

All seven notes are applied. The faces that carried the grey panel material (`Material6`) now carry one of two new materials:

- `Siding Boards - Arctic White` — 523 sq ft: F1 (72 sq ft plus the two side returns of the bay), F3 (119), F4 (86 plus its side return, 29), S1 (188 plus its two returns).
- `Siding Boards - Black` — 132 sq ft: F2 (37), F5 (37), R1 (58).

Both are textures, not geometry, at the same level of detail as the other claddings in the model. Courses start at slab level on every face, so they line up around corners.

Nothing else was changed: geometry, windows, roof, site and the saved camera view are as in v3.

## Assumptions to confirm

1. **Board direction and size.** The notes say only "siding boards". The model shows horizontal boards with a 7" exposure. If vertical boards or another width is meant, it is a texture change only.
2. **Colours.** "Arctic white" is modelled as an off-white (RGB 241, 242, 237) and "black" as a soft black (RGB 38, 38, 40); neither is matched to a manufacturer sample.
3. **Extent of the black panels.** Black is applied only to the panel between the window rows, as far as the existing panel face goes (window width). The bay around it is arctic white.
4. **ACC material list.** The Lot 20 column lists siding White and "siding dec" Black. The black panels are presumably that item; the list has not been edited.

## Not changed

- A small grey panel above the garage side door (front elevation, where the garage meets the house) has no note and was left as it is.
- The remaining items of the 2026-10-07 comparison: three left-side windows 12" toward the rear, roof vents, gutters, basement windows and grade, balcony depth, garage door style.

## Exports (`exports_v4/`, 2400 x 1500 PNG)

Front, rear, left and right elevations (parallel projection), one perspective from the front-left, and `JESB_Lot20_v4_Views.pdf` with the four elevations.
