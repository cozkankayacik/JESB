# Lot 7 – V-Ray elevation renders

Pipeline used for `LOT7/04_Visualization/Renders/<rev>/`. It is fully scripted, so it can be repeated on a new model revision.

1. Run `python -I make_render_plates.py`. It writes `../textures/grass_lawn.png` and `../textures/sky_plate_elevation.png`.
2. Run `run_su.ps1 -Script vray_export.rb -Model <working skp> -Work <dir> -Extra '{"grass_texture": ..., "width": 3200, "height": 1850, "vrscene": "<dir>\lot7_<rev>.vrscene"}'`.
   - SketchUp opens a **copy** of the model, puts the grass texture on the lawn and the terrain section, and exports a `.vrscene` through the V-Ray for SketchUp Ruby API.
   - The model scenes (`Elevation Front West`, …) become V-Ray cameras.
3. Run `python -I vray_render.py <vrscene> <out_dir> <rev> [width] [views] [noise threshold]`. For each view it:
   - overrides the materials. Main roofs are shingles with bump; accent roofs are dark bronze standing-seam metal, with metalness 1 and glossiness 0.62. Brick and siding get bump. Painted whites are set to 0.74 albedo, and the glass is clear and thin-walled with fresnel reflection;
   - sets the sun 40° up and 35° to the viewer's left of the facade normal, so that all four elevations get the same light;
   - sets the camera to f/11, 1/125 s, ISO 100, with a slightly warm white balance and Reinhard burn 0.8;
   - uses the progressive sampler, the V-Ray denoiser and AO at 0.6 within 10 in;
   - renders with `vray.exe -camera=<scene>`. **The orthographic width is halved**: `vray.exe` reads it twice as wide as V-Ray for SketchUp does;
   - composites the alpha over the sky plate. An orthographic camera sees the V-Ray sky as one flat colour, so a plate is used instead;
   - crops the image at the bottom of the terrain section band, at row 1712 of 1850, and applies a gentle contrast of 1.06.

No geometry, material assignment or extra objects are added. There are no trees, people, vehicles or gutters.
