# JESB Lot 20 - model v6: owner feedback "JE Lot 20 ACC and Render Feedback - 2026 10 10.pdf" (Tim & Aurora Trento).
#   1. Upper wall above the garage: four windows (two pairs) instead of two.
#   2. No window sills anywhere; no header band above the left-side brick window.
#   3. No frieze board (white band at the top of the garage walls).
#   4. Black Hardie panel between windows: entry (between door and upper window), tall window bay (between the windows).
#   5. Hardie panels with no seams: joint lines removed from the white panels.
#   6. Black gutters along the eaves.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v6.skp')
WHITE = 'Hardie Panel - Arctic White'
BLACK = 'Hardie Panel - Black'
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v6.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
def wbb(e, tr)
  bb = Geom::BoundingBox.new
  if e.is_a?(Sketchup::Face) then e.vertices.each { |v| bb.add(v.position.transform(tr)) }
  else (0..7).each { |i| bb.add(e.bounds.corner(i).transform(tr)) }
  end
  bb
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

# ---------- 1. four windows on the upper wall above the garage ----------
def upper_windows(m, house, ht)
  wall = m.find_entity_by_persistent_id(127795)
  src = m.find_entity_by_persistent_id(127474); other = m.find_entity_by_persistent_id(127793)
  raise 'upper wall or window groups not found' if [wall, src, other].any?(&:nil?)
  tr = ht * wall.transformation
  inv = tr.inverse
  we = wall.entities
  yf = 3798.95; yb = 3806.07
  front = lambda { we.grep(Sketchup::Face).find { |f| near(f.normal.y, -1, 0.001) && f.vertices.all? { |v| near(v.position.transform(tr).y, yf) } && f.area > 20_000 } }
  log "  front wall face before: #{front.call.loops.length - 1} openings"
  # close the two existing 32 x 32 openings
  [[12428.96, 12460.96], [12542.46, 12574.46]].each do |xa, xb|
    z0 = 216.33; z1 = 248.33
    inbox = lambda { |p| p.x > xa - 0.05 && p.x < xb + 0.05 && p.y > yf - 0.05 && p.y < yb + 0.05 && p.z > z0 - 0.05 && p.z < z1 + 0.05 }
    reveals = we.grep(Sketchup::Face).select { |f| f.normal.y.abs < 0.01 && f.vertices.all? { |v| inbox.call(v.position.transform(tr)) } }
    we.erase_entities(reveals)
    dead = we.grep(Sketchup::Edge).select do |ed|
      ps = ed.vertices.map { |v| v.position.transform(tr) }
      next false unless ps.all? { |p| inbox.call(p) }
      ed.faces.empty? || ps.all? { |p| near(p.y, yf) }
    end
    we.erase_entities(dead)
    log "  old opening x #{xa}..#{xb}: #{reveals.length} reveal faces, #{dead.length} edges removed"
  end
  raise "old openings were not closed (#{front.call.loops.length - 1} left)" unless front.call.loops.length == 1
  brick = front.call.material
  # four new openings: 32 wide x 30 high, head at 248.33, in two pairs (4 in. between the windows of a pair)
  x_corner = 12344.76
  xs = [29.5, 65.5, 207.5, 243.5].map { |d| x_corner + d }
  z0 = 218.33; z1 = 248.33; w = 32.0
  # A closed loop drawn in the middle of a face does not cut it through the API. Instead the face is split edge to
  # edge (two horizontal lines broken at every jamb, then the jamb lines), the opening pieces are erased and the
  # helper edges between the remaining brick pieces are removed again.
  fb = wbb(front.call, tr)
  # exact plane positions from the model (the rounded constants are 0.002-0.005 in off, enough for edges to miss the face)
  yf = front.call.vertices.first.position.transform(tr).y
  back = we.grep(Sketchup::Face).select { |f| near(f.normal.y, 1, 0.001) && near(f.vertices.first.position.transform(tr).y, yb, 0.05) }.max_by(&:area)
  yb = back.vertices.first.position.transform(tr).y
  log format('  exact wall planes: front y %.4f, back y %.4f', yf, yb)
  jambs = xs.flat_map { |x0| [x0, x0 + w] }
  stops = ([fb.min.x] + jambs + [fb.max.x]).sort
  pt = lambda { |x, z| Geom::Point3d.new(x, yf, z).transform(inv) }
  [z0, z1].each { |z| stops.each_cons(2) { |xa, xb| we.add_line(pt.call(xa, z), pt.call(xb, z)) } }
  jambs.each { |x| we.add_line(pt.call(x, z0), pt.call(x, z1)) }
  holes = we.grep(Sketchup::Face).select do |f|
    next false unless near(f.normal.y.abs, 1, 0.001)
    b = wbb(f, tr)
    near(b.min.y, yf) && near(b.max.y, yf) && near(b.min.z, z0) && near(b.max.z, z1) && xs.any? { |x0| near(b.min.x, x0) && near(b.max.x, x0 + w) }
  end
  raise "expected 4 opening pieces, found #{holes.length}" unless holes.length == 4
  we.erase_entities(holes)
  loop do
    helper = we.grep(Sketchup::Edge).select do |e|
      e.vertices.all? { |v| near(v.position.transform(tr).y, yf) } && e.faces.length == 2 && e.faces[0].normal.samedirection?(e.faces[1].normal) && e.faces[0].material == e.faces[1].material
    end
    break if helper.empty?
    we.erase_entities(helper)
  end
  xs.each do |x0|
    q = [[x0, z0], [x0 + w, z0], [x0 + w, z1], [x0, z1]]
    4.times do |i|
      a = q[i]; b = q[(i + 1) % 4]
      we.add_face([[a[0], yf, a[1]], [b[0], yf, b[1]], [b[0], yb, b[1]], [a[0], yb, a[1]]].map { |p| Geom::Point3d.new(*p).transform(inv) })
    end
  end
  ff = front.call
  ff.material = brick
  log "  front wall face after: #{ff.loops.length - 1} openings, area #{(ff.area / 144).round(1)} sq ft"
  raise 'expected 4 openings' unless ff.loops.length == 5
  ff.loops.reject(&:outer?).map { |l| l.vertices.map { |v| v.position.transform(tr) } }.sort_by { |ps| ps.map(&:x).min }.each_with_index do |ps, i|
    log format('    window %d: x %.2f..%.2f (%.1f..%.1f in from the left corner)  z %.2f..%.2f', i + 1, ps.map(&:x).min, ps.map(&:x).max, ps.map(&:x).min - x_corner, ps.map(&:x).max - x_corner, ps.map(&:z).min, ps.map(&:z).max)
  end
  # window units: four copies of the existing 32 x 32 unit, 30 high
  xs.each do |x0|
    c = src.copy
    o = c.transformation.origin
    c.transform!(Geom::Transformation.scaling(o, 1, 1, 30.0 / 32.0))
    wo = (ht * c.transformation).origin
    c.transform!(Geom::Transformation.translation([x0 - wo.x, 0, z0 - wo.z]))
    b = wbb(c, ht)
    log format('    unit: x %.2f..%.2f z %.2f..%.2f', b.min.x, b.max.x, b.min.z, b.max.z)
  end
  house.entities.erase_entities([src, other])
end

# ---------- 2. sills and the header band ----------
SILLS = [166897, 174384, 174388, 174386, 125726, 134700, 164072, 164071, 164100, 132503, 134702, 198347, 198379].freeze
def remove_sills(m, house, ht)
  gone = []
  SILLS.each do |pid|
    e = m.find_entity_by_persistent_id(pid)
    raise "trim group #{pid} not found" unless e
    b = wbb(e, ht)
    kind = pid == 174386 ? 'header band' : 'sill'
    log format('  removed %-11s pid %d  x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', kind, pid, b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z)
    gone << e
  end
  house.entities.erase_entities(gone)
end

# ---------- 3. frieze board: unpainted band at the top of the garage walls ----------
def remove_frieze(m, house, ht)
  n = 0
  house.entities.grep(Sketchup::Group).each do |g|
    tr = ht * g.transformation
    bands = g.entities.grep(Sketchup::Face).select do |f|
      next false unless f.normal.z.abs < 0.01
      b = wbb(f, tr)
      b.min.z > 120 && b.max.z > 135 && b.max.z < 136 && b.depth > 5 && b.depth < 12
    end
    bands.each do |band|
      next unless band.valid?
      b = wbb(band, tr)
      low = band.edges.select { |e| e.vertices.all? { |v| near(v.position.transform(tr).z, b.min.z, 0.05) } }
      below = low.flat_map { |e| e.faces - [band] }.find { |x| x.normal.samedirection?(band.normal) }
      next unless below
      old = band.material ? band.material.name : '-'
      new = below.material ? below.material.name : '-'
      band.material = below.material
      band.back_material = below.back_material
      shared = low.select { |e| e.faces.length == 2 && e.faces.all? { |x| x.normal.samedirection?(band.normal) } }
      nn = band.normal.transform(tr)
      log format('  band x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f (normal %.2f,%.2f): %s -> %s%s', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z, nn.x, nn.y, old, new, shared.empty? ? '' : ', joint line removed')
      g.entities.erase_entities(shared) unless shared.empty?
      n += 1
    end
  end
  log "  frieze band faces merged into the walls: #{n}"
  # The frieze on the garage front, left of the bay: a 9.2 in. band that projects 4.1 in. in front of the brick
  # wall at its top (z 126.0..135.25). The band is erased and the brick wall is raised to the underside of the roof.
  g = m.find_entity_by_persistent_id(126237)
  tr = ht * g.transformation
  inbox = lambda { |p, y1| p.x > 12344.7 && p.x < 12416.8 && p.y > 3412.9 && p.y < y1 && p.z > 125.9 && p.z < 135.3 }
  box = g.entities.grep(Sketchup::Face).select { |f| f.vertices.all? { |v| inbox.call(v.position.transform(tr), 3417.1) } }
  raise "frieze box: expected 7 faces, found #{box.length}" unless box.length == 7
  g.entities.erase_entities(box)
  stray = g.entities.grep(Sketchup::Edge).select { |e| e.faces.empty? && e.vertices.all? { |v| inbox.call(v.position.transform(tr), 3417.1) } }
  g.entities.erase_entities(stray)
  top = g.entities.grep(Sketchup::Edge).flat_map(&:vertices).uniq.select do |v|
    p = v.position.transform(tr)
    near(p.z, 126.01, 0.02) && p.x > 12345.3 && p.x < 12416.8 && p.y > 3417.0 && p.y < 3422.1
  end
  g.entities.transform_by_vectors(top, top.map { Geom::Vector3d.new(0, 0, 135.25 - 126.01) })
  wallf = g.entities.grep(Sketchup::Face).find { |f| near(f.normal.y, -1, 0.001) && f.vertices.all? { |v| near(v.position.transform(tr).y, 3417.07, 0.02) } && f.area > 5000 && wbb(f, tr).max.x < 12420 }
  b = wbb(wallf, tr)
  log format('  projecting frieze band removed (%d faces, %d loose edges); brick wall raised: x %.1f..%.1f z %.1f..%.1f, %s, %d vertices moved', box.length, stray.length, b.min.x, b.max.x, b.min.z, b.max.z, wallf.material ? wallf.material.name : '-', top.length)
  raise 'brick wall was not raised' unless near(b.max.z, 135.25, 0.05)
end
# ---------- 4. black panels between windows ----------
def black_between(m, house, ht)
  black = m.materials[BLACK]
  # entry: wall behind the porch, between the door head and the sill of the upper window
  g = m.find_entity_by_persistent_id(129973)
  tr = ht * g.transformation; inv = tr.inverse
  doors = [131211, 131212].map { |pid| wbb(m.find_entity_by_persistent_id(pid), ht) }
  win = wbb(m.find_entity_by_persistent_id(130012), ht)
  z_lo = doors.map { |b| b.max.z }.max; z_hi = win.min.z
  f = g.entities.grep(Sketchup::Face).select { |x| x.normal.transform(tr).y < -0.99 && near(wbb(x, tr).min.y, 3854.07, 0.05) }.max_by(&:area)
  raise 'entry wall face not found' unless f
  fbnd = wbb(f, tr)
  xdir = Geom::Vector3d.new(1, 0, 0).transform(inv)
  pieces = []
  [z_lo, z_hi].each { |z| pieces.concat(inside_pieces(f, Geom::Point3d.new(fbnd.min.x, fbnd.min.y, z).transform(inv), xdir, [])) }
  pieces.each { |a, b| g.entities.add_line(a, b) }
  area = 0.0
  g.entities.grep(Sketchup::Face).each do |x|
    next unless x.normal.transform(tr).y < -0.99
    b = wbb(x, tr)
    next unless near(b.min.y, 3854.07, 0.05) && b.min.z > z_lo - 0.05 && b.max.z < z_hi + 0.05
    x.material = black; area += x.area / 144.0
    log format('  entry band: x %.1f..%.1f z %.1f..%.1f -> %s', b.min.x, b.max.x, b.min.z, b.max.z, BLACK)
  end
  raise 'entry band was not created' if area < 1
  # tall window bay: the two strips between the stacked windows
  [131979, 132006].each do |pid|
    x = m.find_entity_by_persistent_id(pid)
    raise "tall bay strip #{pid} not found" unless x.is_a?(Sketchup::Face)
    b = wbb(x, ht * x.parent.instances.first.transformation)
    old = x.material ? x.material.name : '-'
    x.material = black
    log format('  tall bay strip: x %.1f..%.1f z %.1f..%.1f  %s -> %s', b.min.x, b.max.x, b.min.z, b.max.z, old, BLACK)
  end
end

# ---------- 5. no seams on the white panels ----------
def remove_white_seams(m, house)
  removed = 0
  house.entities.grep(Sketchup::Group).each do |g|
    loop do
      dead = g.entities.grep(Sketchup::Edge).select do |e|
        e.faces.length == 2 && e.faces.all? { |f| f.material && f.material.name == WHITE } && e.faces[0].normal.samedirection?(e.faces[1].normal)
      end
      break if dead.empty?
      removed += dead.length
      g.entities.erase_entities(dead)
    end
  end
  cnt = Hash.new(0)
  house.entities.grep(Sketchup::Group).each { |g| g.entities.grep(Sketchup::Face).each { |f| cnt[f.material.name] += 1 if f.material && f.material.name =~ /^Hardie Panel/ } }
  log "  joint edges removed from the white panels: #{removed}; panel faces now #{cnt}"
end

# ---------- 6. black gutters ----------
GW = 5.0
def gutters(m, house, ht)
  hinv = ht.inverse
  mat = m.materials.add('Gutter - Black'); mat.color = Sketchup::Color.new(22, 22, 24)
  grp = house.entities.add_group
  grp.name = 'Gutters - Black (v6)'
  total = 0.0
  house.entities.grep(Sketchup::Group).select { |g| g.name =~ /^Roof - / }.each do |roof|
    tr = ht * roof.transformation
    bot = roof.entities.grep(Sketchup::Face).select { |f| f.normal.z.abs > 0.99 }.min_by { |f| f.bounds.min.z }
    pts = bot.outer_loop.vertices.map { |v| v.position.transform(tr) }
    ztop = pts.first.z + 8.0                                   # eave top = fascia bottom + 8
    n = pts.length
    area2 = (0...n).sum { |i| pts[i].x * pts[(i + 1) % n].y - pts[(i + 1) % n].x * pts[i].y }
    ori = area2 > 0 ? 1 : -1
    dirs = (0...n).map { |i| v = pts[(i + 1) % n] - pts[i]; v.z = 0; v.normalize!; v }
    convex = (0...n).map { |i| p = dirs[(i - 1) % n]; c = dirs[i]; (p.x * c.y - p.y * c.x) * ori > 0.01 }
    len = 0.0
    n.times do |i|
      a = pts[i]; b = pts[(i + 1) % n]; e = dirs[i]
      next if roof.name =~ /Garage/ && a.y > 3800.9 && b.y > 3800.9          # end against the two-storey wall
      out = ori > 0 ? Geom::Vector3d.new(e.y, -e.x, 0) : Geom::Vector3d.new(-e.y, e.x, 0)
      a2 = a.offset(e, convex[i] ? -GW : 0.0001 - 0.0001); b2 = b.offset(e, convex[(i + 1) % n] ? GW : 0.0001 - 0.0001)
      a2 = a if !convex[i]; b2 = b if !convex[(i + 1) % n]
      z = ztop - GW
      q = [a2, b2, b2.offset(out, GW), a2.offset(out, GW)].map { |p| Geom::Point3d.new(p.x, p.y, z).transform(hinv) }
      sg = grp.entities.add_group
      f = sg.entities.add_face(q)
      f.reverse! if f.normal.z < 0
      f.pushpull(GW)
      sg.entities.grep(Sketchup::Face).each { |x| x.material = mat }
      len += a.distance(b)
    end
    total += len
    log format('  %s: eave top %.1f, gutter along %.0f ft of eave', roof.name, ztop, len / 12.0)
  end
  b = wbb(grp, ht)
  log format('  gutters: %d pieces, %.0f ft, bounds z %.1f..%.1f', grp.entities.length, total / 12.0, b.min.z, b.max.z)
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  ht = house.transformation
  raise 'house group is not a pure translation' unless near(ht.xaxis.x, 1, 1e-6) && near(ht.yaxis.y, 1, 1e-6) && near(ht.zaxis.z, 1, 1e-6)
  raise 'Hardie materials not found' unless m.materials[WHITE] && m.materials[BLACK]
  m.start_operation('JESB Lot 20 v6 owner feedback', true)
  log '1. upper wall above the garage - four windows'; upper_windows(m, house, ht)
  log '2. sills and header band'; remove_sills(m, house, ht)
  log '3. frieze board'; remove_frieze(m, house, ht)
  log '4. black panels between windows'; black_between(m, house, ht)
  log '5. white panel seams'; remove_white_seams(m, house)
  log '6. gutters'; gutters(m, house, ht)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  b = house.bounds
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  d = 3000.0
  hgt = [b.width, b.height].max * 0.80
  log format('house bounds x %.2f..%.2f y %.2f..%.2f z %.2f..%.2f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z)
  shot(v, 'JESB_Lot20_v6_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_upper_wall.png', [12500, 3150, 330], [12500, 3800, 225], true)
  shot(v, 'chk_entry.png', [12880, 3350, 150], [12880, 3850, 130], true)
  shot(v, 'chk_garage_eave.png', [12200, 3150, 190], [12420, 3420, 130], true)
  shot(v, 'chk_left_nw.png', [12000, 4250, 120], [12506, 4200, 110], true)
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
