# JESB Lot 19 - model v2 (from v1), owner's mark-up of 2026-10-15 on the Rev 1 elevations:
#   1. entry tower: main roof no longer runs across the tower face (main roof rebuilt with a notch at the tower walls)
#   2. first-floor garage roof rebuilt per A-300 / A-310 (eave 132.5, 4:12 sides, 6:12 south ends, two hips)
#   3. window added on the east wall of the two-storey bay above the garage (mirror of the west window)
#   4. garage doors: single-car door first (south), then a double door; centre pier moved
require 'json'
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot19_v2.skp')
DATA = JSON.parse(File.read(File.join(OUT, 'roof19.json')))
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v2.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def b3(b) format('x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) end
def merge_coplanar(ents)
  n = 0
  loop do
    dead = ents.grep(Sketchup::Edge).select { |e| e.faces.length == 2 && e.faces[0].normal.samedirection?(e.faces[1].normal) && e.faces[0].material == e.faces[1].material }
    break if dead.empty?
    n += dead.length
    ents.erase_entities(dead)
  end
  stray = ents.grep(Sketchup::Edge).select { |e| e.faces.empty? }
  ents.erase_entities(stray) unless stray.empty?
  n
end
def build_roof(m, name, spec, mat)
  zb = spec['zb']
  g = m.entities.add_group
  g.name = name
  ents = g.entities
  failed = 0
  spec['faces'].each do |fc|
    begin
      f = ents.add_face(fc['pts'].map { |p| Geom::Point3d.new(*p) })
      f.reverse! if f.normal.z < 0
    rescue
      failed += 1
    end
  end
  merged = merge_coplanar(ents)
  log "#{name}: #{spec['faces'].length} cells (#{failed} failed), #{merged} edges merged -> #{ents.grep(Sketchup::Face).length} roof planes"
  ents.grep(Sketchup::Edge).select { |e| e.faces.length == 1 }.each do |e|
    a = e.start.position; b = e.end.position
    begin
      ents.add_face([a, b, Geom::Point3d.new(b.x, b.y, zb), Geom::Point3d.new(a.x, a.y, zb)])
    rescue => ex
      log "  fascia face failed: #{ex.message}"
    end
  end
  ents.grep(Sketchup::Edge).select { |e| near(e.start.position.z, zb, 0.001) && near(e.end.position.z, zb, 0.001) }.each { |e| e.find_faces if e.faces.length < 2 }
  merge_coplanar(ents)
  faces = ents.grep(Sketchup::Face)
  faces.each do |f|
    nz = f.normal.z
    next if nz.abs < 0.001
    if near(f.vertices.map { |v| v.position.z }.max, zb, 0.001)
      f.reverse! if nz > 0
    else
      f.reverse! if nz < 0
      n = f.normal
      u = Geom::Vector3d.new(0, 0, 1).cross(n); u.normalize!
      up = n.cross(u); up.normalize!; up.reverse! if up.z < 0
      p0 = f.vertices.min_by { |v| v.position.z }.position
      tw = mat.texture ? mat.texture.width : 48.0
      th = mat.texture ? mat.texture.height : 48.0
      f.position_material(mat, [p0, [0, 0], p0.offset(u, tw), [1, 0], p0.offset(up, th), [0, 1]], true)
    end
  end
  open_edges = ents.grep(Sketchup::Edge).count { |e| e.faces.length != 2 }
  log format('  faces %d, open edges %d, manifold %s; %s', faces.length, open_edges, g.manifold?, b3(g.bounds))
  g
end
def box(ents, x0, x1, y0, y1, z0, z1, mat)
  f = ents.add_face([x0, y0, z0], [x1, y0, z0], [x1, y1, z0], [x0, y1, z0])
  f.reverse! if f.normal.z > 0
  f.pushpull(-(z1 - z0))
  ents.grep(Sketchup::Face).each { |x| x.material = mat if x.material.nil? }
end

# ---------- garage doors ----------
XW = 1449.85                    # garage east wall face
def garage_door(m, name, y0, y1, ncol, leaf, glass, trim)
  g = m.entities.add_group
  g.name = name
  e = g.entities
  z0 = 3.0; z1 = 99.0; xb = XW - 2.0; xf = XW + 1.5
  f = e.add_face([xb, y0, z0], [xb, y1, z0], [xb, y1, z1], [xb, y0, z1])
  f.reverse! if f.normal.x < 0
  f.pushpull(xf - xb)
  e.grep(Sketchup::Face).each { |x| x.material = leaf; x.back_material = leaf }
  front = e.grep(Sketchup::Face).find { |x| x.normal.x > 0.99 && near(x.vertices.first.position.x, xf, 0.01) }
  rows = 4; rh = (z1 - z0) / rows; cw = (y1 - y0) / ncol; mg = 2.5
  cells = []
  rows.times do |r|
    ncol.times do |c|
      ya = y0 + c * cw + mg; yb = y0 + (c + 1) * cw - mg
      za = z0 + r * rh + mg; zz = z0 + (r + 1) * rh - mg
      cells << [r, e.add_face([xf, ya, za], [xf, yb, za], [xf, yb, zz], [xf, ya, zz])]
    end
  end
  cells.each do |r, c|
    next unless c && c.valid?
    c.reverse! if c.normal.x < 0
    if r == rows - 1
      c.material = glass; c.pushpull(-1.0)
    else
      c.material = leaf; c.pushpull(-0.6)
    end
  end
  # casing: 4 in. wide, 1 in. proud of the wall, sides and head
  [[y0 - 4, y0, z0, z1 + 4], [y1, y1 + 4, z0, z1 + 4], [y0 - 4, y1 + 4, z1, z1 + 4]].each do |ya, yb, za, zz|
    sg = e.add_group
    box(sg.entities, XW, XW + 1.0, ya, yb, za, zz, trim)
  end
  log format('  %s: y %.2f..%.2f (%.1f in. wide), z %.1f..%.1f, %d panel columns', name, y0, y1, y1 - y0, z0, z1, ncol)
  g
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  shingle = m.materials['Material5'] or raise 'shingle material Material5 not found'
  m.start_operation('JESB Lot 19 v2', true)

  log '1. main roof notched at the entry tower'
  old_main = m.entities.grep(Sketchup::Group).select { |g| g.name =~ /^Roof - Main/ }
  raise "expected one main roof group, found #{old_main.length}" unless old_main.length == 1
  m.entities.erase_entities(old_main)
  build_roof(m, 'Roof - Main (per Rev 1 elevations, v2)', DATA['main'], shingle)

  log '2. garage roof'
  old_gar = [347685, 360873].map { |pid| m.find_entity_by_persistent_id(pid) }
  raise 'old garage roof groups not found' if old_gar.any?(&:nil?)
  old_gar.each { |g| log "  removed old garage roof pid #{g.persistent_id} #{b3(g.bounds)}" }
  m.entities.erase_entities(old_gar)
  build_roof(m, 'Roof - Garage (per Rev 1 elevations, v2)', DATA['garage'], shingle)

  log '3. window on the east wall of the bay above the garage (mirror of the west window)'
  xm = (1194.41 + 1400.41) / 2.0
  mirror = Geom::Transformation.scaling(Geom::Point3d.new(xm, 0, 0), -1, 1, 1)
  [345395, 345470, 345471].each do |pid|
    src = m.find_entity_by_persistent_id(pid) or raise "west window part #{pid} not found"
    c = src.copy
    c.transform!(mirror)
    log "  #{src.definition.name} -> #{b3(c.bounds)}"
  end

  log '4. garage doors: single door (south), double door (north)'
  doors = [330282, 330283].map { |pid| m.find_entity_by_persistent_id(pid) }
  raise 'old garage doors not found' if doors.any?(&:nil?)
  mats = Hash.new(0)
  doors[0].definition.entities.each { |e| next unless e.respond_to?(:definition); e.definition.entities.grep(Sketchup::Face).each { |f| mats[f.material] += f.area if f.material } }
  leaf = mats.reject { |mt, _| mt.name =~ /glass/i || (mt.alpha < 0.9) }.max_by { |_, a| a }&.first || m.materials['C07_Caramel_Shine']
  glass = m.materials['[Translucent Glass Blue]']
  trim = m.materials['M05_Graphite_Haze']
  log "  door leaf material #{leaf.name}, glass #{glass.name}, casing #{trim.name}"
  m.entities.erase_entities(doors)
  # centre pier of the brick/stone base (group 328276) moved from y 1205.7..1230.5 to y 1105.5..1136.0
  base = m.find_entity_by_persistent_id(328276)
  btr = base.transformation
  pier = base.entities.grep(Sketchup::Face).select { |f| f.vertices.all? { |x| p = x.position.transform(btr); p.x > 1449.8 && p.y > 1203.4 && p.y < 1231.9 } }
  base.entities.erase_entities(pier)
  stray = base.entities.grep(Sketchup::Edge).select { |e| e.faces.empty? }
  base.entities.erase_entities(stray)
  log "  old centre pier: #{pier.length} faces and #{stray.length} loose edges removed"
  py0 = 1105.48; py1 = 1136.01
  pg = m.entities.add_group
  pg.name = 'Garage centre pier (v2)'
  stone = m.materials['Material2']; brick = m.materials['Material']
  [[XW, 1454.85, py0, py1, 3.0, 36.0, stone], [XW, 1455.85, py0 - 1.0, py1 + 0.75, 36.0, 44.0, brick], [XW, 1456.85, py0 - 2.2, py1 + 1.4, 44.0, 48.0, trim]].each do |x0, x1, ya, yb, za, zz, mt|
    sg = pg.entities.add_group
    box(sg.entities, x0, x1, ya, yb, za, zz, mt)
  end
  log format('  new centre pier y %.2f..%.2f', py0, py1)
  garage_door(m, 'Garage Door - single 8x8 (v2)', 1009.48, py0, 2, leaf, glass, trim)
  garage_door(m, 'Garage Door - double 16x8 (v2)', py1, 1328.01, 4, leaf, glass, trim)

  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /Sree/i }
  cx = 1495.0; cy = 1475.0; cz = 190.0; d = 5000.0
  [['m_south.png', [cx, cy - d, cz]], ['m_north.png', [cx, cy + d, cz]], ['m_west.png', [cx - d, cy, cz]], ['m_east.png', [cx + d, cy, cz]]].each do |n, eye|
    cam = Sketchup::Camera.new(eye, [cx, cy, cz], [0, 0, 1]); cam.perspective = false; cam.height = 500.0; v.camera = cam
    v.write_image(filename: File.join(OUT, n), width: 2400, height: 1000, antialias: true, transparent: false)
  end
  [['chk_front.png', [1300, 600, 450], [1450, 1300, 200]], ['chk_garage.png', [1900, 850, 320], [1440, 1170, 120]]].each do |n, eye, tg|
    cam = Sketchup::Camera.new(eye, tg, [0, 0, 1]); cam.perspective = true; v.camera = cam
    v.write_image(filename: File.join(OUT, n), width: 2400, height: 1500, antialias: true, transparent: false)
  end
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
