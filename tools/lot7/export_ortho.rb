# JESB Lot 7 - orthographic views at a fixed scale (2 px per inch) for comparison with the drawing set. Nothing is saved.
# Model axes: +x east, +y north, z up. Front = south (view from -y).
OUT = File.dirname(__FILE__)
PX = 2.0
CX = 1950.0; CY = 3780.0; CZ = 190.0
def shot(view, name, eye, target, up, w, h)
  cam = Sketchup::Camera.new(eye, target, up)
  cam.perspective = false
  cam.height = h / PX
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: w, height: h, antialias: true, transparent: false)
end
def run
  m = Sketchup.active_model
  v = m.active_view
  # hide the scale figure and any imported reference drawing so only the house is drawn
  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && (e.definition.name =~ /Sree|\.dwg/i) }
  d = 5000.0
  shot(v, 'm_south.png', [CX, CY - d, CZ], [CX, CY, CZ], [0, 0, 1], 2400, 1000)
  shot(v, 'm_north.png', [CX, CY + d, CZ], [CX, CY, CZ], [0, 0, 1], 2400, 1000)
  shot(v, 'm_west.png', [CX - d, CY, CZ], [CX, CY, CZ], [0, 0, 1], 2400, 1000)
  shot(v, 'm_east.png', [CX + d, CY, CZ], [CX, CY, CZ], [0, 0, 1], 2400, 1000)
  shot(v, 'm_top.png', [CX, CY, CZ + d], [CX, CY, CZ], [0, 1, 0], 2400, 2400)
  File.write(File.join(OUT, 'frame.txt'), "px_per_in #{PX}\ncentre #{CX} #{CY} #{CZ}\nimage centre = model centre; south/north 2400x1000 (x/z), west/east 2400x1000 (y/z), top 2400x2400 (x/y, +y up)\n")
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => ex
  File.write(File.join(OUT, 'done.txt'), "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(6).join("\n")}")
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

