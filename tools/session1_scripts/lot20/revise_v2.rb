# JESB Lot 20 - model v2
#   1. Front upper wall above the garage: three small windows -> two 32x32 windows with sills, positions per DWG.
#   2. Siding: horizontal lap texture -> vertical board and batten (16" o.c.).
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v2.skp')
TEX = 'C:/Projects/JESB/LOT20/textures/board_batten_white_16in.jpg'
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v2.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end

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
  wall = m.find_entity_by_persistent_id(127795)
  w_left = m.find_entity_by_persistent_id(127474)
  w_mid = m.find_entity_by_persistent_id(127793)
  w_right = m.find_entity_by_persistent_id(127794)
  raise 'entities not found' if [house, wall, w_left, w_mid, w_right].any?(&:nil?)
  ht = house.transformation
  raise 'house group is not a pure translation' unless near(ht.xaxis.x, 1, 1e-6) && near(ht.yaxis.y, 1, 1e-6) && near(ht.zaxis.z, 1, 1e-6)
  tr = ht * wall.transformation
  raise 'wall group is not a pure translation' unless near(tr.xaxis.x, 1, 1e-6) && near(tr.yaxis.y, 1, 1e-6) && near(tr.zaxis.z, 1, 1e-6)
  inv = tr.inverse
  we = wall.entities
  yf = 3798.95; yb = 3806.07; z0 = 216.75; z1 = 247.73
  brick = m.materials['Material']

  m.start_operation('JESB Lot 20 v2', true)

  # ---------- 1a. remove the right-hand opening (x 12606.76..12638.76) ----------
  xa = 12606.76; xb = 12638.76
  inbox = lambda do |p|
    p.x > xa - 0.05 && p.x < xb + 0.05 && p.y > yf - 0.05 && p.y < yb + 0.05 && p.z > z0 - 0.05 && p.z < z1 + 0.05
  end
  reveals = we.grep(Sketchup::Face).select do |f|
    pts = f.vertices.map { |vx| vx.position.transform(tr) }
    pts.all? { |p| inbox.call(p) } && f.normal.y.abs < 0.01
  end
  log "right opening: #{reveals.length} reveal faces removed"
  we.erase_entities(reveals)
  # front: erasing the edges of the empty opening heals the wall face; also drop the loose reveal edges
  dead = we.grep(Sketchup::Edge).select do |ed|
    ps = ed.vertices.map { |vx| vx.position.transform(tr) }
    next false unless ps.all? { |p| inbox.call(p) }
    ed.faces.empty? || ps.all? { |p| near(p.y, yf) }
  end
  log "right opening: #{dead.length} edges erased (#{dead.count { |ed| ed.faces.empty? }} loose)"
  we.erase_entities(dead)
  # back (interior side): close the notch with a face
  we.add_face([[xa, yb, z0], [xb, yb, z0], [xb, yb, z1], [xa, yb, z1]].map { |p| Geom::Point3d.new(*p).transform(inv) })
  w_right.erase!
  front = we.grep(Sketchup::Face).find { |f| near(f.normal.y.abs, 1, 0.001) && f.vertices.all? { |vx| near(vx.position.transform(tr).y, yf) } && f.area > 20_000 }
  front.material = brick
  front.reverse! if front.normal.y > 0
  log "front wall face: #{front.loops.length - 1} openings after removal, area #{(front.area / 144).round(1)} sqft"
  raise "right opening was not closed (#{front.loops.length - 1} openings)" unless front.loops.length == 3

  # ---------- 1b. move / resize the two remaining openings to the DWG positions ----------
  nz0 = 216.33; nz1 = 248.33
  moves = [[12423.76, 12455.76, 12428.96, 12460.96], [12523.23, 12555.23, 12542.46, 12574.46]]
  vs = []; vecs = []
  we.grep(Sketchup::Edge).flat_map(&:vertices).uniq.each do |vx|
    p = vx.position.transform(tr)
    next unless p.y > yf - 0.05 && p.y < yb + 0.05
    moves.each do |oa, ob, na, nb|
      dx = if near(p.x, oa) then na - oa elsif near(p.x, ob) then nb - ob end
      next unless dx
      dz = if near(p.z, z0) then nz0 - z0 elsif near(p.z, z1) then nz1 - z1 end
      next unless dz
      vs << vx; vecs << Geom::Vector3d.new(dx, 0, dz)
    end
  end
  we.transform_by_vectors(vs, vecs)
  log "openings: #{vs.length} vertices moved (expected 16)"
  front = we.grep(Sketchup::Face).find { |f| near(f.normal.y.abs, 1, 0.001) && f.vertices.all? { |vx| near(vx.position.transform(tr).y, yf) } && f.area > 20_000 }
  front.loops.each do |l|
    next if l.outer?
    xs = l.vertices.map { |vx| vx.position.transform(tr).x }; zs = l.vertices.map { |vx| vx.position.transform(tr).z }
    log format('  opening x %.2f..%.2f  z %.2f..%.2f', xs.min, xs.max, zs.min, zs.max)
  end
  bad = we.grep(Sketchup::Face).count { |f| !f.valid? }
  log "wall group faces now #{we.grep(Sketchup::Face).length}, invalid #{bad}"

  # ---------- 1c. window units ----------
  [[w_left, 12428.96], [w_mid, 12542.46]].each do |g, nx|
    o = g.transformation.origin
    b = g.bounds
    sx = 32.0 / b.width; sz = 32.0 / b.depth
    g.transform!(Geom::Transformation.scaling(o, sx, 1, sz))
    wo = (ht * g.transformation).origin
    g.transform!(Geom::Transformation.translation([nx - wo.x, 0, nz0 - wo.z]))
    bb = Geom::BoundingBox.new
    (0..7).each { |i| bb.add(g.bounds.corner(i).transform(ht)) }
    log format('window unit: x %.2f..%.2f z %.2f..%.2f', bb.min.x, bb.max.x, bb.min.z, bb.max.z)
  end

  # ---------- 1d. sills ----------
  sill_mat = m.materials['M05_Graphite_Haze']
  hinv = ht.inverse
  [[12427.96, 12462.96], [12541.46, 12576.46]].each do |sa, sb|
    g = house.entities.add_group
    g.name = 'Sill - front upper window (Rev 10-5-26)'
    f = g.entities.add_face([[sa, yf - 2.07, 212.33], [sb, yf - 2.07, 212.33], [sb, yf, 212.33], [sa, yf, 212.33]].map { |p| Geom::Point3d.new(*p).transform(hinv) })
    f.reverse! if f.normal.z < 0
    f.pushpull(4.0)
    g.entities.grep(Sketchup::Face).each { |x| x.material = sill_mat }
    b = g.bounds
    log format('sill: x %.2f..%.2f z %.2f..%.2f', b.min.x + ht.origin.x, b.max.x + ht.origin.x, b.min.z + ht.origin.z, b.max.z + ht.origin.z)
  end

  # ---------- 2. siding ----------
  sid = m.materials['Material5']
  old = sid.texture ? File.basename(sid.texture.filename) : '-'
  sid.texture = TEX
  sid.texture.size = [16.0, 16.0]
  log "siding material '#{sid.name}': texture #{old} -> #{File.basename(sid.texture.filename)}, tile #{sid.texture.width}x#{sid.texture.height} in"

  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  # ---------- exports ----------
  b = house.bounds
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  d = 3000.0
  hgt = [b.width, b.height].max * 0.80
  shot(v, 'JESB_Lot20_v2_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v2_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v2_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v2_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v2_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_v2_upper.png', [12500, 3200, 330], [12500, 3800, 225], true)
  shot(v, 'chk_v2_siding.png', [12150, 4650, 200], [12600, 4150, 130], true)
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
