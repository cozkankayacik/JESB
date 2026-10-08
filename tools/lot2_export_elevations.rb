# JESB Lot 2 - export the four elevations from the current v4 model. Nothing is saved.
# Export convention (brain.md, 2026-10-06/07): parallel projection, centre z 195, height 690 so the frame bottom meets
# the terrain block; terrain skirt painted dark with its rim and bottom edges hidden; on the left elevation the
# driveway slab profile is drawn on the near face of the ground so it reads in elevation.
OUT = File.dirname(__FILE__)
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result.txt'), LOG.join("\n"))
end
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
  log "path #{m.path}"
  log "saved camera eye=#{c0.eye.to_a.map { |a| a.round(1) }} target=#{c0.target.to_a.map { |a| a.round(1) }} persp=#{c0.perspective?}"
  log 'top-level: ' + m.entities.group_by(&:typename).map { |k, a| "#{k}=#{a.length}" }.join(' ')
  vb = Geom::BoundingBox.new
  m.entities.each do |e|
    next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    b = e.bounds
    named = !e.name.to_s.empty? || e.is_a?(Sketchup::ComponentInstance)
    vis = !e.hidden? && e.layer.visible?
    vb.add(b) if vis && b.width < 3000 && b.min.x > 1500
    log format('  %s pid=%d name=%s def=%s vis=%s x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', e.typename[0, 5], e.persistent_id, e.name, e.definition.name, vis, b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) if named
  end
  log format('visible bounds near house x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', vb.min.x, vb.max.x, vb.min.y, vb.max.y, vb.min.z, vb.max.z)
  mats = Hash.new(0.0)
  m.entities.grep(Sketchup::Face).each { |f| mats[f.material ? f.material.name : '-'] += f.area / 144.0 }
  log 'loose top-level faces by material (sq ft): ' + mats.map { |k, a| "#{k}=#{a.round(0)}" }.join(' ')

  t = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /Terrain/ }
  if t
    dark = m.materials.add('tmp_export_ground')
    dark.color = Sketchup::Color.new(66, 72, 55)
    skirt = t.entities.grep(Sketchup::Face).select { |f| f.normal.z.abs < 0.01 }
    skirt.each { |f| f.material = dark; f.back_material = dark }
    t.entities.grep(Sketchup::Edge).each do |ed|
      rim = ed.faces.length == 2 && ed.faces.any? { |f| f.normal.z.abs < 0.01 } && ed.faces.any? { |f| f.normal.z.abs >= 0.01 }
      bottom = ed.vertices.all? { |vx| vx.position.z < -149 }
      ed.hidden = true if rim || bottom || ed.faces.all? { |f| f.normal.z.abs < 0.01 }
    end
    tb = t.bounds
    log format('terrain group: skirt faces %d, bounds x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', skirt.length, tb.min.x, tb.max.x, tb.min.y, tb.max.y, tb.min.z, tb.max.z)
  else
    log 'terrain group NOT found - no ground display tweaks'
  end

  cx = 3226.0; cy = 6785.0; cz = 195.0; d = 3000.0; h = 690.0
  shot(v, 'JESB_Lot2_v4_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], h)
  shot(v, 'JESB_Lot2_v4_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], h)
  shot(v, 'JESB_Lot2_v4_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], h)
  shot(v, 'JESB_Lot2_v4_Elevation_Left_plain.png', [cx - d, cy, cz], [cx, cy, cz], h)

  # left elevation: driveway slab profile on the near face of the ground
  drive = m.entities.grep(Sketchup::Face).select { |f| f.material && f.material.name =~ /Asphalt/ }
  if t && !drive.empty?
    bb = Geom::BoundingBox.new
    drive.each { |f| bb.add(f.bounds) }
    asphalt = drive.first.material
    x = t.bounds.min.x - 0.5
    g = m.entities.add_group
    f = g.entities.add_face([x, bb.min.y, bb.min.z], [x, bb.max.y, bb.min.z], [x, bb.max.y, bb.max.z], [x, bb.min.y, bb.max.z])
    f.material = asphalt; f.back_material = asphalt
    log format('driveway faces %d (%s): x %.1f..%.1f y %.2f..%.2f z %.2f..%.2f', drive.length, asphalt.name, bb.min.x, bb.max.x, bb.min.y, bb.max.y, bb.min.z, bb.max.z)
  else
    log "driveway profile not drawn (terrain #{t ? 'ok' : 'missing'}, asphalt faces #{drive.length})"
  end
  shot(v, 'JESB_Lot2_v4_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], h)
  log 'exports written; model not saved'
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => ex
  log "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(8).join("\n")}"
  File.write(File.join(OUT, 'done.txt'), 'ERR')
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
