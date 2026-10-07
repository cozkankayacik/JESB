# Left elevation only, from the user's v4. Nothing is saved.
# Same display tweaks as export4.rb, plus the driveway slab shown at the near edge of the ground so it reads in elevation.
OUT = File.join(File.dirname(__FILE__), 'exp4')

def run
  m = Sketchup.active_model
  v = m.active_view
  t = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /Terrain/ }
  raise 'terrain group not found' unless t
  dark = m.materials.add('tmp_export_ground')
  dark.color = Sketchup::Color.new(66, 72, 55)
  t.entities.grep(Sketchup::Face).select { |f| f.normal.z.abs < 0.01 }.each { |f| f.material = dark; f.back_material = dark }
  t.entities.grep(Sketchup::Edge).each do |ed|
    rim = ed.faces.length == 2 && ed.faces.any? { |f| f.normal.z.abs < 0.01 } && ed.faces.any? { |f| f.normal.z.abs >= 0.01 }
    bottom = ed.vertices.all? { |vx| vx.position.z < -149 }
    ed.hidden = true if rim || bottom || ed.faces.all? { |f| f.normal.z.abs < 0.01 }
  end

  # driveway slab as modelled: loose asphalt faces west of the garage
  drive = m.entities.grep(Sketchup::Face).select { |f| f.material && f.material.name == 'Asphalt_02_1K' }
  bb = Geom::BoundingBox.new
  drive.each { |f| bb.add(f.bounds) }
  asphalt = m.materials['Asphalt_02_1K']
  x = t.bounds.min.x - 0.5
  g = m.entities.add_group
  f = g.entities.add_face([x, bb.min.y, bb.min.z], [x, bb.max.y, bb.min.z], [x, bb.max.y, bb.max.z], [x, bb.min.y, bb.max.z])
  f.material = asphalt
  f.back_material = asphalt

  cx = 3226.0; cy = 6785.0; cz = 195.0
  cam = Sketchup::Camera.new([cx - 3000.0, cy, cz], [cx, cy, cz], [0, 0, 1])
  cam.perspective = false
  cam.height = 690.0
  v.camera = cam
  v.write_image(filename: File.join(OUT, 'JESB_Lot2_v4_Elevation_Left.png'), width: 2400, height: 1500, antialias: true, transparent: false)
  File.write(File.join(File.dirname(__FILE__), 'done.txt'), "ok driveway y #{bb.min.y.round(2)}..#{bb.max.y.round(2)} z #{bb.min.z.round(2)}..#{bb.max.z.round(2)} x #{bb.min.x.round(1)}..#{bb.max.x.round(1)} faces=#{drive.length}")
rescue => e
  File.write(File.join(File.dirname(__FILE__), 'done.txt'), "ERR #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
end

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
