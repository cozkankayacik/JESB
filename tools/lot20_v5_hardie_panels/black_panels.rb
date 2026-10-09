# JESB Lot 20 v5 - black Hardie panels (owner's instruction, 2026-10-09):
# front elevation black panels = one piece each; rear elevation black panel = two equal pieces.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v5.skp')
BLACK = 'Hardie Panel - Black'
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_black.txt'), LOG.join("\n"))
end
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  raise 'black panel material not found' unless m.materials[BLACK]
  groups = house.entities.grep(Sketchup::Group).select { |g| g.entities.grep(Sketchup::Face).any? { |f| f.material && f.material.name == BLACK } }
  m.start_operation('JESB Lot 20 v5 black panels', true)
  removed = 0
  groups.each do |g|
    loop do
      dead = g.entities.grep(Sketchup::Edge).select do |e|
        e.faces.length == 2 && e.faces.all? { |f| f.material && f.material.name == BLACK } && e.faces[0].normal.samedirection?(e.faces[1].normal)
      end
      break if dead.empty?
      removed += dead.length
      g.entities.erase_entities(dead)
    end
  end
  log "old joint edges removed: #{removed}"
  groups.each do |g|
    tr = house.transformation * g.transformation
    inv = tr.inverse
    g.entities.grep(Sketchup::Face).select { |f| f.material && f.material.name == BLACK }.each do |f|
      n = f.normal.transform(tr)
      pts = f.vertices.map { |x| x.position.transform(tr) }
      xs = pts.map(&:x); zs = pts.map(&:z); y = pts.first.y
      # leftover collinear vertices from the removed joints are harmless; the panel must still be one rectangle
      raise 'black panel is not a single rectangular face' unless f.loops.length == 1 && (f.area - (xs.max - xs.min) * (zs.max - zs.min)).abs < 1.0
      if n.y > 0.9                                   # faces the rear
        xm = (xs.min + xs.max) / 2.0
        g.entities.add_line(Geom::Point3d.new(xm, y, zs.min).transform(inv), Geom::Point3d.new(xm, y, zs.max).transform(inv))
        log format('  rear  black panel x %.1f..%.1f z %.1f..%.1f: 2 panels of %.1f x %.1f in (joint at x %.1f)', xs.min, xs.max, zs.min, zs.max, (xs.max - xs.min) / 2, zs.max - zs.min, xm)
      else
        log format('  front black panel x %.1f..%.1f z %.1f..%.1f: 1 panel of %.1f x %.1f in', xs.min, xs.max, zs.min, zs.max, xs.max - xs.min, zs.max - zs.min)
      end
    end
  end
  cnt = 0; area = 0.0
  groups.each { |g| g.entities.grep(Sketchup::Face).each { |f| next unless f.material && f.material.name == BLACK; cnt += 1; area += f.area / 144.0 } }
  log format('black panel faces now %d, %.1f sq ft', cnt, area)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  b = house.bounds
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  d = 3000.0
  hgt = [b.width, b.height].max * 0.80
  shot(v, 'JESB_Lot20_v5_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  v.camera = saved_cam
  log 'exports written'
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
    UI.start_timer(8, false) { revise }
  elsif tries > 100
    UI.stop_timer(tid)
    File.write(File.join(OUT, 'done.txt'), 'ERR no model loaded')
  end
end
