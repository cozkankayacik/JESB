# JESB Lot 20 v5 - white Hardie panels divided into EQUAL panels (owner's instruction, 2026-10-09).
# The earlier joints followed the window lines and gave unequal panels. They are removed and every white panel
# face gets an even grid: columns = width / 48" rounded, rows = height / 96" rounded, all panels of a face equal.
# The black panels were already equal and are left as they are.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v5.skp')
WHITE = 'Hardie Panel - Arctic White'
MOD_W = 48.0
MOD_H = 96.0
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_equal.txt'), LOG.join("\n"))
end
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end

def inside_pieces(face, o, d, extra_t)
  ts = extra_t.dup
  line = [o, d]
  face.edges.each do |e|
    a = e.start.position; b = e.end.position
    if (b - a).parallel?(d)
      next unless a.on_line?(line)
      ts << (a - o).dot(d) << (b - o).dot(d)
    else
      p = Geom.intersect_line_line(line, [a, b - a])
      next unless p
      next unless (p.distance(a) + p.distance(b) - a.distance(b)).abs < 0.002
      ts << (p - o).dot(d)
    end
  end
  ts = ts.sort.each_with_object([]) { |t, acc| acc << t if acc.empty? || (t - acc.last).abs > 0.01 }
  out = []
  ts.each_cons(2) do |t0, t1|
    mid = o.offset(d, (t0 + t1) / 2.0)
    out << [o.offset(d, t0), o.offset(d, t1)] if face.classify_point(mid) == Sketchup::Face::PointInside
  end
  out
end

def white_groups(house)
  house.entities.grep(Sketchup::Group).select { |g| g.entities.grep(Sketchup::Face).any? { |f| f.material && f.material.name == WHITE } }
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  raise 'white panel material not found' unless m.materials[WHITE]
  m.start_operation('JESB Lot 20 v5 equal Hardie panels', true)

  # 1. remove the old joints: edges between two coplanar white faces
  removed = 0
  white_groups(house).each do |g|
    loop do
      dead = g.entities.grep(Sketchup::Edge).select do |e|
        e.faces.length == 2 && e.faces.all? { |f| f.material && f.material.name == WHITE } && e.faces[0].normal.samedirection?(e.faces[1].normal)
      end
      break if dead.empty?
      removed += dead.length
      g.entities.erase_entities(dead)
    end
  end
  log "old joint edges removed: #{removed}"

  # 2. even grid on every white face
  total = 0.0
  zup = Geom::Vector3d.new(0, 0, 1)
  white_groups(house).each do |g|
    tr = house.transformation * g.transformation
    inv = tr.inverse
    faces = g.entities.grep(Sketchup::Face).select { |f| f.material && f.material.name == WHITE }
    faces.each do |f|
      n = f.normal.transform(tr)
      next if n.z.abs > 0.01
      u = zup.cross(n); u.normalize!
      pts = f.vertices.map { |x| x.position.transform(tr) }
      p0 = pts.first
      us = pts.map { |p| (p - p0).dot(u) }; zs = pts.map(&:z)
      w = us.max - us.min; h = zs.max - zs.min
      cols = [(w / MOD_W).round, 1].max; rows = [(h / MOD_H).round, 1].max
      vpos = (1...cols).map { |i| us.min + w * i / cols }
      hpos = (1...rows).map { |i| zs.min + h * i / rows }
      u_l = u.transform(inv); z_l = zup.transform(inv)
      pieces = []
      vpos.each do |c|
        o = Geom::Point3d.new(p0.x + u.x * c, p0.y + u.y * c, 0).transform(inv)
        pieces.concat(inside_pieces(f, o, z_l, hpos.dup))
      end
      hpos.each do |z|
        o = Geom::Point3d.new(p0.x, p0.y, z).transform(inv)
        pieces.concat(inside_pieces(f, o, u_l, vpos.dup))
      end
      len = pieces.sum { |a, b| a.distance(b) }
      total += len
      bb = Geom::BoundingBox.new; pts.each { |p| bb.add(p) }
      log format('  face x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f  %.1f x %.1f in -> %d x %d panels of %.2f x %.2f in, %d joint pieces', bb.min.x, bb.max.x, bb.min.y, bb.max.y, bb.min.z, bb.max.z, w, h, cols, rows, w / cols, h / rows, pieces.length)
      pieces.each { |a, b| g.entities.add_line(a, b) }
    end
  end
  log format('joint lines added: %.0f ft', total / 12.0)
  area = 0.0
  white_groups(house).each { |g| g.entities.grep(Sketchup::Face).each { |f| area += f.area / 144.0 if f.material && f.material.name == WHITE } }
  log format('white panel area %.1f sq ft', area)
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
  shot(v, 'chk_front_close.png', [12850, 3300, 140], [12850, 3800, 130], true)
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
