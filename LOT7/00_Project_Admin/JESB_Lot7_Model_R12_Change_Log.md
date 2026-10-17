# JESB Lot 7 – Exterior Model R12 – Change Log

Date: 2026-10-17
Based on: R11.
Source: the owner's answer to RFI-001.03: "use the DWG". This follows the owner's earlier instruction for the roof as seen on the rear elevation.

## Change

| Item | R11 (= R01–R11) | R12 |
|---|---|---|
| Main roof end hips (north and south ends, bodies A1 and A2 west/east planes) | 9:12, per A-220 and the front elevation. Ridge x 165.5–473.5 (308 in). | **6:12, as drawn on the rear elevation** (xelev: hips from the eave corners −12 / 651 at 248.87 to the ridge ends). Ridge x 254.2–384.8 (**131 in**) at 381.97. |
| Gablet on the south hip | Base on the 9:12 hip | The gablet is unchanged as drawn on the south elevation (eave 258.9, apex 313.2). Its gable infill now runs down to the 6:12 hip, 3.3 in lower at the gable face. |

Everything else is unchanged from R11.

## Consequences (accepted by the owner's instruction)

- **The rear elevation now matches xelev.**
- **The front elevation no longer matches its xelev roof lines.** Front and rear views of one roof always show the same outline, so both cannot be met. The front xelev draws a 311 in ridge and 9:12 end hips.
- **The roof plan check against A-220 shows the hip lines moved:** the ridge ends at x 254 / 385 against 165 / 474 on A-220. See `QA_Overlay_vs_Architect_DWG`.
- R11 keeps the A-220 / front-elevation roof, in case the architect confirms that version.

## Files

- Model: `03_Shared_CAD_and_Models/Models/01_Working/JESB_Lot7_Model_R12.skp`
- Exports and QA: `04_Visualization/Exports/R12/`
- A3 set: `05_Presentations_and_Issued/Issued_Sets/PROJADES_JESB_Lot7_Exterior_Model_A3_R12.pdf`
- V-Ray renders: none for R12. They were stopped when the R13 terrace change came in; see `Renders/R13/`.
