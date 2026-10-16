# JESB Lot 7 - standard exports (4 elevations, parallel projection, + perspective) from the current model. Nothing is saved.
# Fixed framing for every Lot 7 version: centre (1950, 3800, 210), height 700 in. Prefix from the file name (JESB_Lot7_vN).
OUT = File.dirname(__FILE__)
CX = 1950.0; CY = 3800.0; CZ = 210.0; H = 700.0
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
def run
  m = Sketchup.active_model
  v = m.active_view
  prefix = File.basename(m.path)[/JESB_Lot7_v\d+/] or raise 'model name does not start with JESB_Lot7_vN'
  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /Sree|Chris|\.dwg/i }
  d = 5000.0
  shot(v, "#{prefix}_Elevation_Front.png", [CX, CY - d, CZ], [CX, CY, CZ], false, H)
  shot(v, "#{prefix}_Elevation_Rear.png", [CX, CY + d, CZ], [CX, CY, CZ], false, H)
  shot(v, "#{prefix}_Elevation_Left.png", [CX - d, CY, CZ], [CX, CY, CZ], false, H)
  shot(v, "#{prefix}_Elevation_Right.png", [CX + d, CY, CZ], [CX, CY, CZ], false, H)
  shot(v, "#{prefix}_Perspective.png", [CX - 900, CY - 1500, 520], [CX - 20, CY - 20, 170], true)
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => ex
  File.write(File.join(OUT, 'done.txt'), "ERR #{ex.class}: #{ex.message}")
end
tries = 0
tid = UI.start_timer(3, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid)
    UI.start_timer(8, false) { run }
  elsif tries > 100
    UI.stop_timer(tid)
    File.write(File.join(OUT, 'done.txt'), 'ERR no model loaded')
  end
end
