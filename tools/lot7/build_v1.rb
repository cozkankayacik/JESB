# JESB Lot 7 - model v1 from JESB_SKETCHUP_LOT7.skp: roofs per Rev 1 roof plan A-220 + elevations, east garage dormer,
# west dormer raised, covered terrace (roof, columns, terrace moved under it). Geometry from roof7.json (roof7.py).
require 'json'
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot7_v1.skp')
DATA = JSON.parse(File.read(File.join(OUT, 'roof7.json')))
OLD = { 460580 => 'main roof', 462372 => 'entry tower front roof', 463324 => 'main roof fascia band',
        460743 => 'garage upper roof', 462858 => 'west dormer roof' }.freeze
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v1.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def b3(b) format('x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) end
def merge_coplanar(ents)
  n = 0
  loop do
    dead = ents.grep(Sketchup::Edge).select { |e| e.faces.length == 2 && e.faces[0].normal.samedirection?(e.faces[1].normal) && e.faces[0].material == e.faces[1].material }
    break if dead.empty?
    n += dead.length; ents.erase_entities(dead)
  end
  stray = ents.grep(Sketchup::Edge).select { |e| e.faces.empty? }
  ents.erase_entities(stray) unless stray.empty?
  n
end
def build_roof(m, name, spec, mat, mats)
  zb = spec['zb']
  g = m.entities.add_group; g.name = name; ents = g.entities
  failed = 0
  spec['faces'].each do |fc|
    begin
      f = ents.add_face(fc['pts'].map { |p| Geom::Point3d.new(*p) })
      f.reverse! if f.normal.z < 0
      f.material = mat
    rescue
      failed += 1
    end
  end
  merge_coplanar(ents)
  gable_faces = []
  ents.grep(Sketchup::Edge).select { |e| e.faces.length == 1 }.each do |e|
    a = e.start.position; b = e.end.position
    gb = spec['gables'].find { |gy, _, _| near(a.y, gy, 0.05) && near(b.y, gy, 0.05) && (a.z - b.z).abs > 0.5 }
    bottom = gb ? gb[1] : zb
    begin
      f = ents.add_face([a, b, Geom::Point3d.new(b.x, b.y, bottom), Geom::Point3d.new(a.x, a.y, bottom)])
      gable_faces << [f, mats[gb[2]]] if gb
    rescue => ex
      log "  edge face failed: #{ex.message}"
    end
  end
  [zb] + spec['gables'].map { |x| x[1] }.uniq.each do |zz|
    ents.grep(Sketchup::Edge).select { |e| near(e.start.position.z, zz, 0.001) && near(e.end.position.z, zz, 0.001) }.each { |e| e.find_faces if e.faces.length < 2 }
  end
  merge_coplanar(ents)
  ents.grep(Sketchup::Face).each do |f|
    nz = f.normal.z
    if nz.abs < 0.001
      f.material = nil
    elsif f.vertices.map { |v| v.position.z }.max < zb + 0.01 || f.vertices.all? { |v| spec['gables'].any? { |gy, gz, _| near(v.position.z, gz, 0.01) } }
      f.reverse! if nz > 0
      f.material = mats['soffit']; f.back_material = mats['soffit']
    else
      f.reverse! if nz < 0
      n = f.normal
      u = Geom::Vector3d.new(0, 0, 1).cross(n); u.normalize!
      up = n.cross(u); up.normalize!; up.reverse! if up.z < 0
      p0 = f.vertices.min_by { |v| v.position.z }.position
      tw = mat.texture ? mat.texture.width : 48.0; th = mat.texture ? mat.texture.height : 48.0
      f.position_material(mat, [p0, [0, 0], p0.offset(u, tw), [1, 0], p0.offset(up, th), [0, 1]], true)
    end
  end
  # gable-end faces: siding / metal panels (the generator's vertical faces in the gable plane, below the rakes)
  spec['gables'].each do |gy, gz, key|
    ents.grep(Sketchup::Face).each do |f|
      next unless f.normal.y.abs > 0.999 && f.vertices.all? { |v| near(v.position.y, gy, 0.05) }
      f.material = mats[key]; f.back_material = mats[key]
    end
  end
  open_edges = ents.grep(Sketchup::Edge).count { |e| e.faces.length != 2 }
  log format('%s: %d cells (%d failed) -> %d faces, open edges %d, manifold %s; %s', name, spec['faces'].length, failed, ents.grep(Sketchup::Face).length, open_edges, g.manifold?, b3(g.bounds))
  g
end
def box(ents, x0, x1, y0, y1, z0, z1, mat)
  g = ents.add_group
  f = g.entities.add_face([x0, y0, z0], [x1, y0, z0], [x1, y1, z0], [x0, y1, z0])
  f.reverse! if f.normal.z > 0
  f.pushpull(-(z1 - z0))
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g
end
def stretch_top(m, pid, zcut, dz)
  g = m.find_entity_by_persistent_id(pid) or raise "group #{pid} not found"
  tr = g.transformation
  vs = g.entities.grep(Sketchup::Edge).flat_map(&:vertices).uniq.select { |v| v.position.transform(tr).z > zcut }
  g.entities.transform_by_vectors(vs, vs.map { Geom::Vector3d.new(0, 0, dz) })
  log format('  group %d: %d vertices above z %.1f moved up %.1f -> %s', pid, vs.length, zcut, dz, b3(g.bounds))
end
def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  shingle = m.materials['Material5'] or raise 'Material5 missing'
  mats = { 'siding' => m.materials['Material1'], 'metal' => m.materials['Material metal'], 'soffit' => m.materials['D01_Frost_White'] }
  raise "materials missing: #{mats}" if mats.values.any?(&:nil?)
  brick = m.materials['Brick_05_1K']
  m.start_operation('JESB Lot 7 v1', true)

  log '1. old roofs'
  old = OLD.keys.map { |pid| m.find_entity_by_persistent_id(pid) }
  raise "missing: #{OLD.keys.zip(old).select { |_, e| e.nil? }.map(&:first)}" if old.any?(&:nil?)
  old.each_with_index { |e, i| log format('  removed %-26s pid %d %s', OLD.values[i], e.persistent_id, b3(e.bounds)) }
  m.entities.erase_entities(old)
  fr = m.find_entity_by_persistent_id(463326)
  fr.transform!(Geom::Transformation.translation([0, 0, 270.6 - 264.9])) if fr
  log "  frieze band 463326 raised to the new soffit: #{b3(fr.bounds)}" if fr

  log '2. new roofs'
  build_roof(m, 'Roof - Main (per A-220, v1)', DATA['main'], shingle, mats)
  build_roof(m, 'Roof - Garage upper (per A-220, v1)', DATA['garage'], shingle, mats)
  build_roof(m, 'Roof - Garage dormer west (v1)', DATA['dormer_w'], shingle, mats)
  build_roof(m, 'Roof - Garage dormer east (v1)', DATA['dormer_e'], shingle, mats)
  build_roof(m, 'Roof - Covered terrace (v1)', DATA['terrace'], shingle, mats)

  log '3. garage upper walls to the new soffit, west dormer raised'
  stretch_top(m, 459942, 210.0, 223.5 - 217.3)
  stretch_top(m, 459944, 200.0, 256.2 - 231.6)
  dw = [468589, 468590, 468591, 468592].map { |pid| m.find_entity_by_persistent_id(pid) }
  raise 'west dormer windows missing' if dw.any?(&:nil?)
  dw.each { |w| w.transform!(Geom::Transformation.translation([0, 0, 25.0])) }
  log "  west dormer windows raised 25: #{b3(dw[0].bounds)}"
  # cheek walls of the west dormer (between the dormer eave and the garage roof)
  [3422.1, 3563.1].each do |y|
    f = m.entities.add_group.entities.add_face([1658.8, y, 230.8 + 0.3 * 0.75], [1658.8, y, 256.2], [1692.4, y, 256.2])
    f.material = mats['siding']; f.back_material = mats['siding']
  end

  log '4. east dormer'
  eg = m.entities.add_group; eg.name = 'Garage dormer east - walls (v1)'
  box(eg.entities, 1910.6, 1924.6, 3497.8, 3638.8, 125.0, 256.2, mats['siding'])
  [3497.8, 3638.8].each do |y|
    f = eg.entities.add_face([1910.6, y, 241.3], [1910.6, y, 256.2], [1890.7, y, 256.2])
    f.material = mats['siding']; f.back_material = mats['siding']
  end
  mirror = Geom::Transformation.scaling(Geom::Point3d.new((1661.7 + 1923.8) / 2.0, 0, 0), -1, 1, 1)
  y0 = 3497.8 + (141.0 - (4 * 28.0 + 3 * 3.5)) / 2.0
  dw.sort_by { |w| w.bounds.min.y }.each_with_index do |w, i|
    c = w.copy
    c.transform!(mirror)
    b = c.bounds
    c.transform!(Geom::Transformation.translation([1924.6 - b.min.x + 0.3, y0 + i * 31.5 - b.min.y, 0]))
    log "  east dormer window #{i + 1}: #{b3(c.bounds)}"
  end

  log '5. garage front gable window (A-300: trim x 1777..1807, z 253..290, in front of the new gable face)'
  cands = []
  m.entities.each do |e|
    next unless (e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)) && !e.hidden?
    cands << [e, IDENTITY]
    next unless e.bounds.min.y < 3420 && e.bounds.max.z > 230
    e.definition.entities.each { |c| cands << [c, e.transformation] if c.is_a?(Sketchup::Group) || c.is_a?(Sketchup::ComponentInstance) }
  end
  cands.each do |e, ptr|
    b = Geom::BoundingBox.new; (0..7).each { |i| b.add(e.bounds.corner(i).transform(ptr)) }
    next unless b.min.z > 225 && b.max.z < 300 && b.min.x > 1750 && b.max.x < 1830 && b.min.y > 3330 && b.max.y < 3420
    next unless b.width < 50 && b.depth < 40
    t = Geom::Vector3d.new(1792.0 - (b.min.x + b.max.x) / 2.0, 3376.6 - b.max.y, 271.5 - (b.min.z + b.max.z) / 2.0)
    e.transform!(Geom::Transformation.translation(t.transform(ptr.inverse)))
    log "  moved #{e.typename} #{e.persistent_id} #{e.respond_to?(:definition) ? e.definition.name : ''} from #{b3(b)} by #{t.to_a.map { |a| a.round(1) }}"
  end

  log '6. covered terrace'
  deck = m.entities.select do |e|
    next false unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    b = e.bounds
    b.min.x > 2280 && b.max.z < 60 && b.min.y > 3950 && b.max.y < 4240 && !e.name.to_s.start_with?('Roof')
  end
  deck.each { |e| e.transform!(Geom::Transformation.translation([0, -60.3, 0])) }
  bb = Geom::BoundingBox.new; deck.each { |e| bb.add(e.bounds) }
  log "  #{deck.length} terrace parts moved 60.3 in. south -> #{b3(bb)}"
  ztop = 23.3
  cg = m.entities.add_group; cg.name = 'Covered terrace columns 16x16 (v1)'
  [[2408.6, 3903.9], [2408.6, 4153.5], [2283.8, 3903.9], [2283.8, 4153.5]].each do |x, y|
    box(cg.entities, x, x + 16, y, y + 16, ztop, 134.1, brick)
  end
  log '  4 columns 16x16, z 23.3..134.1'

  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /Sree|Chris|\.dwg/i }
  cx = 1950.0; cy = 3780.0; cz = 190.0; d = 5000.0
  [['m_south.png', [cx, cy - d, cz]], ['m_north.png', [cx, cy + d, cz]], ['m_west.png', [cx - d, cy, cz]], ['m_east.png', [cx + d, cy, cz]]].each do |n, eye|
    cam = Sketchup::Camera.new(eye, [cx, cy, cz], [0, 0, 1]); cam.perspective = false; cam.height = 500.0; v.camera = cam
    v.write_image(filename: File.join(OUT, n), width: 2400, height: 1000, antialias: true, transparent: false)
  end
  cam = Sketchup::Camera.new([cx, cy, cz + d], [cx, cy, cz], [0, 1, 0]); cam.perspective = false; cam.height = 1200.0; v.camera = cam
  v.write_image(filename: File.join(OUT, 'm_top.png'), width: 2400, height: 2400, antialias: true, transparent: false)
  [['chk_sw.png', [1100, 2700, 900], [1950, 3800, 200]], ['chk_se.png', [2900, 2800, 800], [2000, 3800, 180]], ['chk_ne.png', [3000, 5000, 800], [2050, 3950, 150]], ['chk_garage_e.png', [2400, 3000, 450], [1850, 3550, 200]]].each do |n, eye, tg|
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
