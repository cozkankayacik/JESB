# Exports from the user's updated v4. Nothing is saved: display-only tweaks so the ground reads as one dark mass
# (as in the user's reference view) instead of a pale slab with an edge line.
OUT = File.join(File.dirname(__FILE__), 'exp4')
Dir.mkdir(OUT) unless Dir.exist?(OUT)

def shot(view, name, eye, target, height)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = false
  cam.height = height
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end

def run
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  user_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  # perspective: the view saved in the file, untouched model

  t = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /Terrain/ }
  raise 'terrain group not found' unless t
  dark = m.materials.add('tmp_export_ground')
  dark.color = Sketchup::Color.new(SKIRT_RGB[0], SKIRT_RGB[1], SKIRT_RGB[2])
  skirt = t.entities.grep(Sketchup::Face).select { |f| f.normal.z.abs < 0.01 }
  skirt.each { |f| f.material = dark; f.back_material = dark }
  t.entities.grep(Sketchup::Edge).each do |ed|
    zs = ed.vertices.map { |vx| vx.position.z }
    rim = ed.faces.length == 2 && ed.faces.any? { |f| f.normal.z.abs < 0.01 } && ed.faces.any? { |f| f.normal.z.abs >= 0.01 }
    bottom = zs.all? { |z| z < -149 }
    ed.hidden = true if rim || bottom || ed.faces.all? { |f| f.normal.z.abs < 0.01 }
  end
  cx = 3226.0; cy = 6785.0; cz = 195.0; d = 3000.0; h = 690.0   # frame bottom = z -150 = bottom of the terrain block
  shot(v, 'JESB_Lot2_v4_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], h)
  shot(v, 'JESB_Lot2_v4_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], h)
  shot(v, 'JESB_Lot2_v4_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], h)
  shot(v, 'JESB_Lot2_v4_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], h)
  v.camera = user_cam
  v.write_image(filename: File.join(OUT, 'JESB_Lot2_v4_Perspective.png'), width: 2400, height: 1500, antialias: true, transparent: false)
  File.write(File.join(OUT, 'done_info.txt'), "skirt faces #{skirt.length}; model saved: no")
  File.write(File.join(File.dirname(__FILE__), 'done.txt'), 'ok')
rescue => e
  File.write(File.join(File.dirname(__FILE__), 'done.txt'), "ERR #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
end

SKIRT_RGB = [66, 72, 55].freeze
tries = 0
tid = UI.start_timer(2, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid)
    UI.start_timer(3, false) { run }
  elsif tries > 60
    UI.stop_timer(tid)
    File.write(File.join(File.dirname(__FILE__), 'done.txt'), 'ERR no model loaded')
  end
end
