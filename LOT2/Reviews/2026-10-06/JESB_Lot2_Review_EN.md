# JESB Lot 2 Review Report

Date: October 6, 2026

The model's overall elevation and roof arrangement is close to the drawings, but coordination is incomplete. Resolve the wall boundaries and the reference face for the roof overhang first, followed by the relationship between the terrain and building elevations. The model should not be used for definitive quantity takeoffs or construction dimensions until these issues are resolved.

## Scope and sources

- DWG: `C:/Projects/JESB/LOT2/Lot 2 _revisions1.dwg`
- SketchUp: `C:/Projects/JESB/LOT2/JESB_Lot2_v3.skp`
- Supporting PDF: `C:/Projects/JESB/LOT2/Lot 2_revision1.pdf` (11 sheets, October 5, 2026 revision).
- Existing model images: elevations and perspective in `LOT2/exports_v3`.

A copy of the DWG was exported to DXF using AutoCAD and read for inspection. A copy of the SKP was inspected using the SketchUp Ruby API. The four existing elevation images were compared with the PDF sheets. These images were not regenerated during this review. The source DWG and SKP files were not modified; their SHA256 hashes matched the working copies at the end of the review.

The review covers architectural coordination and visual consistency. Structural calculations and code compliance were not audited. Notes within the documents were treated as project information, not as user instructions.

## Findings

### 1 Terrain and model relationship

Priority: High. Status: Visual comparison finding.

The model images show basement windows at the front elevation and openings beneath the garage. The drawings show these areas below grade or as unexcavated. This makes the model's relationship to the terrain misleading; it does not, by itself, establish that extra openings were modeled.

Recommendation: Match the terrain surface and exposed foundation limits to the drawings, then regenerate the elevations.

Evidence: PDF sheets 1, 1.2, and 2; model front and left elevation images.

### 2 Site plan

Priority: High. Status: Confirmed in the reviewed PDF set.

The T1.0 index lists a site plan, but no site plan is drawn in the reviewed set. The driveway, site elevations, and the walk-out basement's connection to the surrounding terrain cannot be fully verified from this set.

Recommendation: Complete the site and grading plan, or reference the relevant separate sheet in the set.

Evidence: PDF sheet T1.0 and the 11-sheet set.

### 3 Eave details

Priority: Medium. Status: Visual comparison finding.

The 8-inch fascia/frieze boards and gutter system shown on the drawings are not represented in the model images.

Recommendation: Add these elements to the model so the elevation and roof-edge proportions can be assessed accurately.

Evidence: PDF sheets 1, 1.1, and 1.2; existing model elevations. The v3 change log also states that fascia, gutters, and downspouts were not modeled.

### 4 Cladding above the entry

Priority: Medium. Status: Visual comparison finding.

The model shows a plain white surface around the horizontal window above the entry, while the brick hatch continues across this area on the front elevation drawing.

Recommendation: Match the surface material to the drawing or identify it as a design change.

Evidence: PDF sheet 1 and the model front elevation image.

### 5 Ventilation schedule

Priority: Medium. Status: Directly confirmed in the PDF schedule.

On sheet 4, the required mechanical ventilation for the master bathroom is listed as 202.4 CFM, while the selected value is 200 CFM. The selected value is 2.4 CFM below the requirement stated in the schedule.

Recommendation: Reconcile the calculation or equipment selection. This finding identifies an internal schedule inconsistency; it is not an independent code compliance determination.

Evidence: PDF sheet 4; close-up image `Evidence/ventilation.png`.

### 6 DWG area labels

Priority: Medium. Status: Directly confirmed in the DWG export.

The A-Area layer contains labels of 1,935 / 1,761 / 1,808 / 1,077 ft² and a `##############` field. Their relationship to the cover-sheet schedule of 2,511 + 2,512 = 5,023 ft² is unclear. These values may be remnants of earlier work and should not be used as the current area calculation.

Recommendation: Separate obsolete areas and verify the current area calculation using closed boundaries.

Evidence: `Data/dwg_data.json`; PDF sheet T1.0. Net and gross areas were not recalculated during this review.

### 7 Sheet titles and general notes

Priority: Low. Status: Confirmed in the PDF set.

T1.0 is titled Exterior Elevations, and the project number is incomplete as 2026-. The new-construction set includes notes referring to modifications to existing ductwork.

Recommendation: Correct the sheet titles, project number, and template notes that do not apply to the project scope.

Evidence: T1.0 title block and general notes; project number fields on the other sheets.

## Unresolved dimensional questions from the previous revision log

The following items are carried over from the v3 change log. Not all differences were remeasured during this review, so they should not be treated as newly verified, definitive measurements.

- Some rear and east model walls are reported to extend approximately 5–10 inches beyond the DWG positions.
- It remains unresolved whether the 12-inch overhang is measured from the exterior cladding face or the framing line. The model uses the exterior wall face.
- The rear garage pier is recorded as 51 inches in the model versus 46 inches on the plan.
- Architect confirmation remains outstanding for the approximately 12 x 17-inch flat patch at the top of the entry tower roof.
- The driveway slab extending approximately 5.3 inches beyond the outer door jambs is recorded as an assumption and should be verified against the site plan.

Evidence: `Previous_Revision_Logs/JESB_Lot2_v3_Change_Log.md`. Decision statements in the previous logs are historical records; they do not constitute new authorization for changes under this review.

## Recommended work sequence

1. Align the DWG and SKP exterior wall boundaries to a common reference and clarify the reference face for the overhang dimension.
2. Complete the terrain, driveway, and walk-out elevations.
3. Match the cladding and eave details, then regenerate all four elevations.
4. Correct the ventilation schedule, area labels, and sheet information.

## Folder contents

- `Evidence/PDF_Sheets`: Review images of all 11 PDF pages. File sequence numbers correspond to PDF page numbers: 01=T1.0, 02=1, 03=1.1, 04=1.2, 05=2, 06=3, 07=4, 08=5, 09=6, 10=7, 11=8.
- `Evidence/Model_Elevations`: Copies of the existing v3 elevation and perspective images.
- `Evidence/ventilation.png`: Close-up of the ventilation schedule.
- `Data`: DWG text/block data, model top-level object bounds, roof lines, and PDF text. The path in the model JSON file refers to the temporary review copy. A solid=false result for a parent group does not, by itself, indicate that the roof geometry inside it is defective.
- `Previous_Revision_Logs`: Unmodified copies of the previous v2 and v3 change logs.

The source drawings remain in the main LOT2 folder. This folder is a review archive; it does not contain revised DWG or SKP deliverables.
