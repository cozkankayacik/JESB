# JESB Lot 2 - rear elevation with the deck visible. Nothing is saved.
# A true elevation sees the deck edge-on (a 7" line). To make it read as in the user's reference view
# (Elevation_Rear_new), the elevation camera stays orthographic and the deck top is drawn as a band on the near
# face of the ground, as if seen from DECK_ANGLE degrees above: band height = deck depth x sin(angle), with the
# deck's front edge below it. Same display-only idea as the driveway profile on the left elevation.
OUT = File.dirname(__FILE__)
DECK_ANGLE = 15.0
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result.txt'), LOG.join("\n"))
end
def run
  m = Sketchup.active_model
  v = m.active_view
  log "path #{m.path}"
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

  # the deck as modelled: loose top-level slab at the rear, top face in the deck material
  top = m.entities.grep(Sketchup::Face).select { |f| f.normal.z > 0.9 && f.bounds.min.y > 6990 && f.bounds.max.z > 5 && f.bounds.max.z < 40 && f.area > 2000 }.max_by(&:area)
  raise 'deck top face not found' unless top
  b = top.bounds
  front = m.entities.grep(Sketchup::Face).find { |f| f.normal.y > 0.9 && (f.bounds.min.y - b.max.y).abs < 0.5 && f.bounds.min.x >= b.min.x - 1 && f.bounds.max.x <= b.max.x + 1 && f.bounds.max.z <= b.max.z + 0.1 }
  grade = 8.8                                      # ground level at the deck (terrain)
  edge_h = b.max.z - grade
  depth = b.max.y - b.min.y
  band = depth * Math.sin(DECK_ANGLE * Math::PI / 180)
  log format('deck top: material %s, x %.1f..%.1f y %.1f..%.1f z %.1f; depth %.1f, visible edge %.1f; band %.1f', (top.material ? top.material.name : '-'), b.min.x, b.max.x, b.min.y, b.max.y, b.max.z, depth, edge_h, band)
  y = t.bounds.max.y + 0.5
  g = m.entities.add_group
  z1 = b.max.z; z2 = z1 - band; z3 = z2 - edge_h
  f1 = g.entities.add_face([b.min.x, y, z2], [b.max.x, y, z2], [b.max.x, y, z1], [b.min.x, y, z1])
  f1.material = top.material; f1.back_material = top.material
  f2 = g.entities.add_face([b.min.x, y, z3], [b.max.x, y, z3], [b.max.x, y, z2], [b.min.x, y, z2])
  em = front && (front.material || front.back_material)
  unless em
    em = m.materials.add('tmp_export_deck_edge'); em.color = Sketchup::Color.new(176, 176, 172)
  end
  f2.material = em; f2.back_material = em
  log "front edge material: #{em.name} (#{front ? 'from the deck front face' : 'fallback colour'})"

  cx = 3226.0; cy = 6785.0; cz = 195.0; d = 3000.0; h = 690.0
  cam = Sketchup::Camera.new([cx, cy + d, cz], [cx, cy, cz], [0, 0, 1])
  cam.perspective = false
  cam.height = h
  v.camera = cam
  v.write_image(filename: File.join(OUT, 'JESB_Lot2_v4_Elevation_Rear.png'), width: 2400, height: 1500, antialias: true, transparent: false)
  log 'rear exported (orthographic, deck band drawn); model not saved'
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
