"""JESB Lot 7 R01 - shared geometry (DWG plan inches, z = 0 at top of main floor, DWG elevation datum 1429.31).

All plan coordinates come from the architect's floor plan DWGs (xflr0/1/2, issue 2026-10-16), read from layered
plot PDFs (tools/lot7_rebuild/pdf_plan_extract.py). Outlines are the outer face of the exterior finish
(brick face on brick walls, sheathing/siding face on the wing).

Orientation: front faces WEST = -y. North = -x, south = +x, east (rear) = +y.
"""

Z_DATUM = 1429.31            # DWG elevation y of the main floor (839.20 ft)
FT0 = 839.20                 # main floor elevation in feet

# levels (z, inches above main floor) from xelev level lines
L1 = 0.0
MAIN_PLATE = 121.12
L2 = 133.75
UPPER_PLATE = 242.87
T_FND_FRONT = -14.13         # 838.00'
GARAGE_SLAB = -16.0          # assumed (garage door bottom at grade line on south elevation) - verify

# elevation x mapping (DWG xelev x of a plan point) - anchored on the main block corners
ELEV = {
    "front": {"axis": "x", "sign": 1, "c": 6482.98},    # west face, looking east
    "rear": {"axis": "x", "sign": -1, "c": 4411.64},    # east face, looking west
    "south": {"axis": "y", "sign": 1, "c": 7598.36},    # south face (+x), looking north
    "north": {"axis": "y", "sign": -1, "c": 6134.36},   # north face (-x), looking south
}


def to_elev(view, x, y):
    e = ELEV[view]
    v = x if e["axis"] == "x" else y
    return e["c"] + e["sign"] * v


# ---- outlines (outer face) ------------------------------------------------------------------------------------
# First floor (xflr1, 2026-10-16). xflr1 moved the garage front 9.36" back against the previous issue; R11 (owner,
# RFI-001.01/.02): garage front per the architect's elevations = previous position (south elevation within 0.6"):
# bump face y 4.96, main garage face y 16.0.
GARAGE_BUMP_Y = 4.96
GARAGE_FACE_Y = 16.0
L1_OUTLINE = [(0, GARAGE_BUMP_Y), (137.68, GARAGE_BUMP_Y), (137.68, GARAGE_FACE_Y), (276.0, GARAGE_FACE_Y),
              (276.0, 434.32), (362.96, 434.32),
              (362.96, 480.96), (448.96, 480.96), (448.96, 429.36), (638.96, 429.36), (638.96, 912.32), (0, 912.32),
              (0, 590.08), (-31.04, 590.08), (-31.04, 394.96), (0, 394.96)]
# Second floor (xflr2): main block + bonus-room wing over the garage with its two bay dormers.
L2_OUTLINE = [(0, 400.0), (28.96, 400.0), (28.96, 241.0), (16.9, 241.0), (16.9, 101.3), (28.96, 101.3),
              (28.96, 62.96), (270.96, 62.96), (270.96, 176.2), (282.0, 176.2), (282.0, 317.6), (270.96, 317.6),
              (270.96, 434.32), (362.96, 434.32), (362.96, 480.96), (448.96, 480.96), (448.96, 429.36),
              (638.96, 429.36), (638.96, 912.32), (0, 912.32)]


def ccw(poly):
    a = sum(poly[i][0] * poly[(i + 1) % len(poly)][1] - poly[(i + 1) % len(poly)][0] * poly[i][1] for i in range(len(poly)))
    return poly if a > 0 else poly[::-1]


def faces(poly):
    """Outer faces of a CCW polygon: (p, q, outward normal, view)."""
    poly = ccw(poly)
    out = []
    for i in range(len(poly)):
        p, q = poly[i], poly[(i + 1) % len(poly)]
        dx, dy = q[0] - p[0], q[1] - p[1]
        n = (dy, -dx)
        L = (n[0] ** 2 + n[1] ** 2) ** 0.5
        n = (round(n[0] / L, 6), round(n[1] / L, 6))
        view = {(0, -1): "front", (0, 1): "rear", (1, 0): "south", (-1, 0): "north"}.get((round(n[0]), round(n[1])))
        out.append((p, q, n, view))
    return out
