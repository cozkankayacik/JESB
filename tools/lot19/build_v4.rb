# JESB Lot 19 - model v4 (from v3), checked against xelev_lot19.dwg (exterior elevations, 2026-10-16):
#   1. entry door: 3'-0" door with 1'-6" sidelites, ~8'-4" high, and a row of three fixed transoms 2'-0" high above,
#      up to the underside of the entry canopy (the model had a 6'-7" door, short sidelites and a grey panel above)
#   2. garage doors: panel pattern per the DWG (two panels per column in the lower rows, muntins in the glass row)
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot19_v4.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v4.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def b3(b) format('x %.2f..%.2f y %.2f..%.2f z %.2f..%.2f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) end
def wb(e)
  bb = Geom::BoundingBox.new
  (0..7).each { |i| bb.add(e.bounds.corner(i)) }
  bb
end
# fit a copy of src into the world box (x0..x1, z0..z1), y unchanged
def fit(src, x0, x1, z0, z1)
  c = src.copy
  b = wb(c)
  c.transform!(Geom::Transformation.scaling(b.min, (x1 - x0) / b.width, 1.0, (z1 - z0) / b.depth))
  b = wb(c)
  c.transform!(Geom::Transformation.translation([x0 - b.min.x, 0, z0 - b.min.z]))
  c
end
def box(ents, x0, x1, y0, y1, z0, z1, mat)
  f = ents.add_face([x0, y0, z0], [x1, y0, z0], [x1, y1, z0], [x0, y1, z0])
  f.reverse! if f.normal.z > 0
  f.pushpull(-(z1 - z0))
  ents.grep(Sketchup::Face).each { |x| x.material = mat if x.material.nil? }
end

# ---------- 1. entry ----------
XA = 1561.98; XB = 1633.98            # opening between the jambs of the entry frame (Group#13)
ZD0 = 32.01                            # existing threshold
ZDT = 131.8                            # head of door and sidelites (xelev front elevation)
ZT1 = 155.8                            # head of the transoms (just under the canopy, 156.9)
def entry(m)
  frame = m.find_entity_by_persistent_id(339955) or raise 'entry frame Group#13 not found'
  wall = m.find_entity_by_persistent_id(339914) or raise 'wall above the entry Group#17 not found'
  door = m.find_entity_by_persistent_id(645939) or raise 'entry door not found'
  side = m.find_entity_by_persistent_id(645943) or raise 'sidelite not found'
  st = m.find_entity_by_persistent_id(645945) or raise 'sidelite transom not found'
  mt = m.find_entity_by_persistent_id(645947) or raise 'door transom not found'
  old = [door, side, st, mt] + [645944, 645946].map { |p| m.find_entity_by_persistent_id(p) }
  raise 'entry parts missing' if old.any?(&:nil?)
  # a. grey panel above the door (front box of the frame): bottom raised from 124.23 to the transom head
  ftr = frame.transformation
  vs = frame.entities.grep(Sketchup::Edge).flat_map(&:vertices).uniq.select do |v|
    p = v.position.transform(ftr)
    near(p.z, 124.23, 0.05) && p.x > XA - 0.05 && p.x < XB + 0.05
  end
  frame.entities.transform_by_vectors(vs, vs.map { Geom::Vector3d.new(0, 0, ZT1 - 124.23) })
  log "  grey panel above the door: #{vs.length} vertices raised to z #{ZT1}"
  # b. wall above the door (Group#17, y 1412.91..1418.91, bottom 124.73): notch x XA..XB up to ZT1
  wtr = wall.transformation; inv = wtr.inverse
  we = wall.entities
  # exact plane positions from the faces (rounded values miss the faces and do not split them)
  ff = we.grep(Sketchup::Face).select { |x| x.normal.transform(wtr).y < -0.99 }.max_by(&:area)
  bf = we.grep(Sketchup::Face).select { |x| x.normal.transform(wtr).y > 0.99 }.max_by(&:area)
  yf = ff.vertices.first.position.transform(wtr).y; yb = bf.vertices.first.position.transform(wtr).y
  z0 = ff.vertices.map { |x| x.position.transform(wtr).z }.min
  log format('  wall planes: front y %.4f, back y %.4f, bottom z %.4f', yf, yb, z0)
  pt = lambda { |x, y, z| Geom::Point3d.new(x, y, z).transform(inv) }
  [yf, yb].each do |y|
    we.add_line(pt.call(XA, y, z0), pt.call(XA, y, ZT1)); we.add_line(pt.call(XB, y, z0), pt.call(XB, y, ZT1)); we.add_line(pt.call(XA, y, ZT1), pt.call(XB, y, ZT1))
  end
  [XA, XB].each { |x| we.add_line(pt.call(x, yf, z0), pt.call(x, yb, z0)) }
  inside = lambda do |f|
    ps = f.vertices.map { |v| v.position.transform(wtr) }
    ps.all? { |p| p.x > XA - 0.05 && p.x < XB + 0.05 && p.z > z0 - 0.05 && p.z < ZT1 + 0.05 }
  end
  dead = we.grep(Sketchup::Face).select { |f| inside.call(f) }
  log "  wall above the entry: #{dead.length} faces removed for the transom opening"
  raise 'transom opening was not cut' if dead.length < 3
  mat = we.grep(Sketchup::Face).find { |f| f.material }&.material
  we.erase_entities(dead)
  [[[XA, yf, ZT1], [XB, yf, ZT1], [XB, yb, ZT1], [XA, yb, ZT1]], [[XA, yf, z0], [XA, yb, z0], [XA, yb, ZT1], [XA, yf, ZT1]], [[XB, yf, z0], [XB, yb, z0], [XB, yb, ZT1], [XB, yf, ZT1]]].each do |q|
    f = we.add_face(q.map { |p| pt.call(*p) }); f.material = mat
  end
  stray = we.grep(Sketchup::Edge).select { |e| e.faces.empty? }
  we.erase_entities(stray)
  # c. new door unit: sidelite 18 | door 36 | sidelite 18, transoms above in the same divisions
  x1 = XA + 18.0; x2 = XB - 18.0
  parts = [fit(side, XA, x1, ZD0, ZDT), fit(door, x1, x2, ZD0, ZDT), fit(side, x2, XB, ZD0, ZDT),
           fit(st, XA, x1, ZDT, ZT1), fit(mt, x1, x2, ZDT, ZT1), fit(st, x2, XB, ZDT, ZT1)]
  parts.each { |p| p.name = 'Entry door unit (v4)' if p.respond_to?(:name=) }
  m.entities.erase_entities(old)
  parts.each { |p| log '  ' + (p.respond_to?(:definition) ? p.definition.name : '?') + ' ' + b3(wb(p)) }
end

# ---------- 2. garage doors ----------
XW = 1449.85
def garage_door(m, name, y0, y1, ncol, leaf, glass, trim)
  g = m.entities.add_group
  g.name = name
  e = g.entities
  z0 = 3.0; z1 = 99.0; xb = XW - 2.0; xf = XW + 1.5
  f = e.add_face([xb, y0, z0], [xb, y1, z0], [xb, y1, z1], [xb, y0, z1])
  f.reverse! if f.normal.x < 0
  f.pushpull(xf - xb)
  e.grep(Sketchup::Face).each { |x| x.material = leaf; x.back_material = leaf }
  rows = 4; rh = (z1 - z0) / rows; cw = (y1 - y0) / ncol; mg = 2.5
  cells = []
  rows.times do |r|
    ncol.times do |c|
      ya = y0 + c * cw + mg; yb = y0 + (c + 1) * cw - mg
      za = z0 + r * rh + mg; zz = z0 + (r + 1) * rh - mg
      if r == rows - 1
        cells << [:glass, ya, yb, za, zz, e.add_face([xf, ya, za], [xf, yb, za], [xf, yb, zz], [xf, ya, zz])]
      else
        ym = (ya + yb) / 2.0
        [[ya, ym - 1.0], [ym + 1.0, yb]].each { |a, b| cells << [:panel, a, b, za, zz, e.add_face([xf, a, za], [xf, b, za], [xf, b, zz], [xf, a, zz])] }
      end
    end
  end
  cells.each do |kind, ya, yb, za, zz, c|
    next unless c && c.valid?
    c.reverse! if c.normal.x < 0
    if kind == :glass
      c.material = glass; c.pushpull(-1.0)
      # muntins: 3 vertical and 1 horizontal bar, 1 in. wide, flush with the leaf face
      bars = (1..3).map { |k| y = ya + (yb - ya) * k / 4.0; [y - 0.5, y + 0.5, za, zz] } + [[ya, yb, (za + zz) / 2.0 - 0.5, (za + zz) / 2.0 + 0.5]]
      bars.each { |a, b, c0, c1| sg = e.add_group; box(sg.entities, xf - 1.0, xf - 0.1, a, b, c0, c1, leaf) }
    else
      c.material = leaf; c.pushpull(-0.6)
    end
  end
  [[y0 - 4, y0, z0, z1 + 4], [y1, y1 + 4, z0, z1 + 4], [y0 - 4, y1 + 4, z1, z1 + 4]].each do |ya, yb, za, zz|
    sg = e.add_group
    box(sg.entities, XW, XW + 1.0, ya, yb, za, zz, trim)
  end
  log format('  %s: y %.2f..%.2f, %d columns, %d lower panels per row', name, y0, y1, ncol, ncol * 2)
  g
end
def garage(m)
  old = m.entities.grep(Sketchup::Group).select { |g| g.name =~ /^Garage Door - / }
  raise "expected 2 garage doors, found #{old.length}" unless old.length == 2
  leaf = nil
  old[0].entities.grep(Sketchup::Face).each { |f| leaf ||= f.material if f.material && f.material.name !~ /Glass|Graphite/ }
  glass = m.materials['[Translucent Glass Blue]']; trim = m.materials['M05_Graphite_Haze']
  spans = old.map { |g| b = g.bounds; [g.name, b] }
  m.entities.erase_entities(old)
  garage_door(m, 'Garage Door - single 8x8 (v4)', 1009.48, 1105.48, 2, leaf, glass, trim)
  garage_door(m, 'Garage Door - double 16x8 (v4)', 1136.01, 1328.01, 4, leaf, glass, trim)
  log "  leaf material #{leaf ? leaf.name : '-'}"
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  m.start_operation('JESB Lot 19 v4', true)
  log '1. entry door'; entry(m)
  log '2. garage doors'; garage(m)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /Sree/i }
  cx = 1495.0; cy = 1475.0; cz = 190.0; d = 5000.0
  [['m_south.png', [cx, cy - d, cz]], ['m_east.png', [cx + d, cy, cz]]].each do |n, eye|
    cam = Sketchup::Camera.new(eye, [cx, cy, cz], [0, 0, 1]); cam.perspective = false; cam.height = 500.0; v.camera = cam
    v.write_image(filename: File.join(OUT, n), width: 2400, height: 1000, antialias: true, transparent: false)
  end
  [['chk_entry.png', [1640, 1100, 110], [1598, 1415, 100]], ['chk_garage.png', [1900, 850, 250], [1440, 1170, 60]]].each do |n, eye, tg|
    cam = Sketchup::Camera.new(eye, tg, [0, 0, 1]); cam.perspective = true; v.camera = cam
    v.write_image(filename: File.join(OUT, n), width: 2400, height: 1500, antialias: true, transparent: false)
  end
  v.camera = saved_cam
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
