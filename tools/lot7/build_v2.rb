# JESB Lot 7 - model v2 from JESB_Lot7_v1.skp: roofs, dormers, windows and garage doors corrected to the exterior
# elevations xelev_lot 7G.dwg (DWG z = Y - 1400.5, aligned on the windows; east view y = DWG + 6 from the 72" windows).
# Roof geometry from roof7_v2.json (tools/lot7/roof7_v2.py).
require 'json'
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot7_v2.skp')
DATA = JSON.parse(File.read(File.join(OUT, 'roof7_v2.json')))
OLD_ROOFS = ['Roof - Main (per A-220, v1)', 'Roof - Garage upper (per A-220, v1)', 'Roof - Garage dormer west (v1)',
             'Roof - Garage dormer east (v1)', 'Roof - Covered terrace (v1)', 'Garage dormer east - walls (v1)'].freeze
FASCIA = 7.3
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v2.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def b3(b) format('x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) end
def merge_coplanar(ents)
  loop do
    dead = ents.grep(Sketchup::Edge).select { |e| e.faces.length == 2 && e.faces[0].normal.samedirection?(e.faces[1].normal) && e.faces[0].material == e.faces[1].material }
    break if dead.empty?
    ents.erase_entities(dead)
  end
  stray = ents.grep(Sketchup::Edge).select { |e| e.faces.empty? }
  ents.erase_entities(stray) unless stray.empty?
end
def on_gable(gb, p) gb[0] == 'x' ? near(p.x, gb[1], 0.05) : near(p.y, gb[1], 0.05) end
# Roof group from envelope cells. Free edges get a vertical face: gable rakes down to the gable's bottom, horizontal
# eaves down by the fascia depth, anything else down to the group's bottom. The base line of a gable that stands on
# another roof plane (east gablet) is left alone.
def build_roof(m, name, spec, mat, mats)
  zb = spec['zb']; gables = spec['gables']
  g = m.entities.add_group; g.name = name; ents = g.entities
  failed = 0
  metal = spec['metal'] || []
  spec['faces'].each do |fc|
    begin
      f = ents.add_face(fc['pts'].map { |p| Geom::Point3d.new(*p) })
      f.reverse! if f.normal.z < 0
      f.material = metal.include?(fc['key']) ? mats['metal'] : mat
    rescue
      failed += 1
    end
  end
  merge_coplanar(ents)
  bottoms = [zb]
  ents.grep(Sketchup::Edge).select { |e| e.faces.length == 1 }.each do |e|
    a = e.start.position; b = e.end.position
    flat = (a.z - b.z).abs < 0.5
    gb = gables.find { |x| on_gable(x, a) && on_gable(x, b) }
    next if gb && flat && near(a.z, gb[2], 0.05)
    bottom = gb && !flat ? gb[2] : (flat ? a.z - FASCIA : zb)
    bottoms << bottom
    begin
      ents.add_face([a, b, Geom::Point3d.new(b.x, b.y, bottom), Geom::Point3d.new(a.x, a.y, bottom)])
    rescue => ex
      log "  edge face failed: #{ex.message}"
    end
  end
  bottoms.map { |z| z.round(3) }.uniq.each do |zz|
    ents.grep(Sketchup::Edge).select { |e| near(e.start.position.z, zz, 0.001) && near(e.end.position.z, zz, 0.001) }.each { |e| e.find_faces if e.faces.length < 2 }
  end
  merge_coplanar(ents)
  ents.grep(Sketchup::Face).each do |f|
    nz = f.normal.z
    if nz.abs < 0.001
      f.material = nil
    elsif nz.abs > 0.999 && f.vertices.map { |v| v.position.z }.max < zb + 0.01
      f.reverse! if nz > 0
      f.material = mats['soffit']; f.back_material = mats['soffit']
    else
      f.reverse! if nz < 0
      n = f.normal
      u = Geom::Vector3d.new(0, 0, 1).cross(n); u.normalize!
      up = n.cross(u); up.normalize!; up.reverse! if up.z < 0
      p0 = f.vertices.min_by { |v| v.position.z }.position
      fm = f.material || mat
      tw = fm.texture ? fm.texture.width : 48.0; th = fm.texture ? fm.texture.height : 48.0
      f.position_material(fm, [p0, [0, 0], p0.offset(u, tw), [1, 0], p0.offset(up, th), [0, 1]], true)
    end
  end
  gables.each do |gb|
    ents.grep(Sketchup::Face).each do |f|
      nn = gb[0] == 'x' ? f.normal.x : f.normal.y
      next unless nn.abs > 0.999 && f.vertices.all? { |v| on_gable(gb, v.position) }
      f.material = mats[gb[3]]; f.back_material = mats[gb[3]]
    end
  end
  open_edges = ents.grep(Sketchup::Edge).count { |e| e.faces.length != 2 }
  log format('%s: %d cells (%d failed) -> %d faces, open edges %d; %s', name, spec['faces'].length, failed, ents.grep(Sketchup::Face).length, open_edges, b3(g.bounds))
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
def wbounds(e, tr)
  bb = Geom::BoundingBox.new
  (0..7).each { |i| bb.add(e.bounds.corner(i).transform(tr)) }
  bb
end
# Move every vertex of a group whose world position lies in the y band (an opening and its reveals/trim) by dy, and
# those also inside the z band by dz. All faces involved are planes of constant x, y or z, so they stay planar.
def band_move(g, y0, y1, dy, zb0 = nil, zb1 = nil, dz = 0)
  tr = g.transformation; inv = tr.inverse
  vs = g.entities.grep(Sketchup::Edge).flat_map(&:vertices).uniq.select { |v| p = v.position.transform(tr); p.y > y0 && p.y < y1 }
  vecs = vs.map do |v|
    p = v.position.transform(tr)
    w = Geom::Vector3d.new(0, dy, zb0 && p.z > zb0 && p.z < zb1 ? dz : 0)
    w.transform(inv)
  end
  g.entities.transform_by_vectors(vs, vecs)
  vs.length
end
def move_world(e, parent_tr, t_world)
  e.transform!(parent_tr.inverse * t_world * parent_tr)
end
# Flat trim board on a vertical gable plane: polygon given in plane coordinates (u along the plane, z), front face
# 'proud' in front of the plane, pushed back to the plane. axis 'y': plane y = c, front towards -y; 'x': plane x = c,
# front towards +x. holes: optional inner polygons (window casing).
def board(ents, axis, c, proud, poly, mat, holes = [])
  g = ents.add_group
  pt = lambda { |u, z| axis == 'y' ? Geom::Point3d.new(u, c - proud, z) : Geom::Point3d.new(c + proud, u, z) }
  f = g.entities.add_face(poly.map { |u, z| pt.call(u, z) })
  holes.each { |h| hf = g.entities.add_face(h.map { |u, z| pt.call(u, z) }); g.entities.erase_entities(hf) if hf && hf.valid? }
  f = g.entities.grep(Sketchup::Face).max_by(&:area)
  out = axis == 'y' ? Geom::Vector3d.new(0, -1, 0) : Geom::Vector3d.new(1, 0, 0)
  f.reverse! if f.normal.dot(out) < 0
  f.pushpull(-proud)
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g
end
# Sloped bar along y (handrail): rectangle section w x h, bottom z = z0 + k * (y - y0)
def rail(ents, x0, x1, ya, yb, z0, y0, k, h, mat)
  g = ents.add_group
  za = z0 + k * (ya - y0); zb = z0 + k * (yb - y0)
  f = g.entities.add_face([x0, ya, za], [x0, yb, zb], [x0, yb, zb + h], [x0, ya, za + h])
  f.reverse! if f.normal.x < 0
  f.pushpull(x1 - x0)
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g
end
def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  shingle = m.materials['Material5'] or raise 'Material5 missing'
  mats = { 'siding' => m.materials['Material1'], 'metal' => m.materials['Material metal'], 'soffit' => m.materials['D01_Frost_White'] }
  raise "materials missing: #{mats}" if mats.values.any?(&:nil?)
  ident = Geom::Transformation.new
  m.start_operation('JESB Lot 7 v2', true)

  log '1. v1 roofs and dormer pieces removed'
  old = m.entities.select { |e| e.is_a?(Sketchup::Group) && OLD_ROOFS.include?(e.name) }
  raise "v1 groups found: #{old.map(&:name)}" unless old.length == OLD_ROOFS.length
  cheeks = m.entities.select do |e|
    next false unless e.is_a?(Sketchup::Group) && e.name.empty? && e.entities.grep(Sketchup::Face).length == 1
    b = e.bounds
    near(b.min.x, 1658.8, 0.2) && near(b.max.x, 1692.4, 0.2) && b.height < 0.1
  end
  log "  #{old.length} groups + #{cheeks.length} west cheek walls"
  m.entities.erase_entities(old + cheeks)

  log '2. roofs v2'
  build_roof(m, 'Roof - Main (per DWG, v2)', DATA['main'], shingle, mats)
  build_roof(m, 'Roof - Garage upper (per DWG, v2)', DATA['garage'], shingle, mats)
  build_roof(m, 'Roof - Garage dormer west (v2)', DATA['dormer_w'], shingle, mats)
  build_roof(m, 'Roof - Garage dormer east (v2)', DATA['dormer_e'], shingle, mats)
  build_roof(m, 'Roof - Covered terrace (v2)', DATA['terrace'], shingle, mats)

  log '3. garage gable window onto the new gable face (y 3372.3)'
  gw = m.find_entity_by_persistent_id(461201) or raise 'gable window 461201 missing'
  gw.transform!(Geom::Transformation.translation([0, 3371.7 - gw.bounds.max.y, 0]))
  log "  461201 -> #{b3(gw.bounds)}"

  log '4. dormers'
  ww = [468589, 468590, 468591, 468592].map { |pid| m.find_entity_by_persistent_id(pid) }
  raise 'west dormer windows missing' if ww.any?(&:nil?)
  ww.sort_by { |w| w.bounds.min.y }.zip([3422.9, 3456.9, 3490.8, 3524.8]).each do |w, y|
    b = w.bounds
    w.transform!(Geom::Transformation.translation([0, y - b.min.y, 184.4 - b.min.z]))
    log "  west dormer window #{w.persistent_id}: #{b3(w.bounds)}"
  end
  cg = m.entities.add_group; cg.name = 'Garage dormer west - cheek walls (v2)'
  [3416.5, 3559.5].each do |y|
    f = cg.entities.add_face([1658.8, y, 230.8 + 0.3 * 0.75], [1658.8, y, 256.2], [1692.4, y, 256.2])
    f.material = mats['siding']; f.back_material = mats['siding']
  end
  eg = m.entities.add_group; eg.name = 'Garage dormer east - walls (v2)'
  box(eg.entities, 1910.6, 1924.6, 3488.2, 3629.2, 125.0, 256.2, mats['siding'])
  [3488.2, 3629.2].each do |y|
    f = eg.entities.add_face([1910.6, y, 241.3], [1910.6, y, 256.2], [1890.7, y, 256.2])
    f.material = mats['siding']; f.back_material = mats['siding']
  end
  ew = m.entities.select { |e| e.is_a?(Sketchup::ComponentInstance) && e.definition.name == 'Component#507' && e.bounds.min.x > 1924 && e.bounds.max.x < 1927.5 && e.bounds.min.z > 150 }
  raise "east dormer windows: #{ew.length}" unless ew.length == 4
  ew.sort_by { |w| w.bounds.min.y }.zip([3493.7, 3527.7, 3561.6, 3595.6]).each do |w, y|
    b = w.bounds
    w.transform!(Geom::Transformation.translation([0, y - b.min.y, 184.4 - b.min.z]))
    log "  east dormer window: #{b3(w.bounds)}"
  end

  log '5. east wall: the two 24" upper windows moved and shortened to 24x60 (DWG)'
  wall = m.find_entity_by_persistent_id(445771) or raise 'east wall 445771 missing'
  [[445919, 3945.0, 3987.0, -5.5], [445918, 4074.0, 4114.0, -6.1]].each do |pid, y0, y1, dy|
    w = wall.entities.find { |e| e.persistent_id == pid } or raise "window #{pid} missing"
    wb = wbounds(w, wall.transformation)
    n = band_move(wall, y0, y1, dy, 175.0, 200.0, 11.7)
    s = (wb.max.z - (wb.min.z + 11.7)) / (wb.max.z - wb.min.z)
    t = Geom::Transformation.translation([0, dy, 0]) * Geom::Transformation.scaling(Geom::Point3d.new(wb.center.x, wb.center.y, wb.max.z), 1, 1, s)
    move_world(w, wall.transformation, t)
    log "  #{pid}: #{n} wall vertices moved, window #{b3(wb)} -> #{b3(wbounds(w, wall.transformation))}"
  end

  log '6. garage doors (east) moved south to the DWG positions, with their openings'
  gw5 = m.find_entity_by_persistent_id(428091) or raise 'garage wall 428091 missing'
  [[3366.0, 3479.0, -9.4, 430593], [3490.0, 3699.0, -8.8, 428972]].each do |y0, y1, dy, pid|
    n = band_move(gw5, y0, y1, dy)
    extra = m.entities.select do |e|
      next false unless (e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)) && e.persistent_id != 428091
      b = e.bounds
      b.min.x > 1905 && b.max.x < 1932 && b.min.y > y0 && b.max.y < y1 && b.max.z < 100
    end
    extra.each { |e| e.transform!(Geom::Transformation.translation([0, dy, 0])) }
    log "  band #{y0}..#{y1}: #{n} wall vertices, moved #{extra.map { |e| "#{e.persistent_id} #{b3(e.bounds)}" }.join('; ')}"
    raise "door #{pid} not moved" unless extra.any? { |e| e.persistent_id == pid }
  end

  log '7. covered terrace 5.1 in. south (DWG right side)'
  parts = m.entities.select do |e|
    next false unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    b = e.bounds
    (b.min.x > 2280 && b.max.z < 60 && b.min.y > 3890 && b.max.y < 4240 && !e.name.to_s.start_with?('Roof')) || e.name == 'Covered terrace columns 16x16 (v1)'
  end
  parts.each { |e| e.transform!(Geom::Transformation.translation([0, -5.1, 0])) }
  bb = Geom::BoundingBox.new; parts.each { |e| bb.add(e.bounds) }
  log "  #{parts.length} parts -> #{b3(bb)}"

  log '8. gable trim (DWG front / right side): rake boards, king posts, gable window casing, gablet base board'
  white = mats['soffit']
  tg = m.entities.add_group; tg.name = 'Gable trim (v2)'; te = tg.entities
  # garage gable, plane y 3372.3; model = DWG + 0.9 here (eave 230.8 / ridge 330.6)
  board(te, 'y', 3372.3, 0.75, [[1658.5, 223.5], [1658.5, 230.8], [1791.55, 330.6], [1924.6, 230.8], [1924.6, 223.5], [1906.6, 223.5],
                                [1906.6, 235.2], [1791.55, 321.5], [1676.5, 235.2], [1676.5, 223.5]], white)
  board(te, 'y', 3372.3, 1.5, [[1788.0, 295.5], [1795.1, 295.5], [1795.1, 309.7], [1788.0, 309.7]], white)
  board(te, 'y', 3372.3, 1.5, [[1789.8, 297.5], [1793.3, 297.5], [1793.3, 321.5], [1789.8, 321.5]], white)
  gwb = gw.bounds
  board(te, 'y', 3372.3, 0.75, [[1776.5, 252.0], [1807.5, 252.0], [1807.5, 291.0], [1776.5, 291.0]], white,
        [[[gwb.min.x, gwb.min.z], [gwb.max.x, gwb.min.z], [gwb.max.x, gwb.max.z], [gwb.min.x, gwb.max.z]]])
  # east gablet, plane x 2279.6
  board(te, 'x', 2279.6, 0.75, [[3922.8, 287.65], [4031.5, 342.0], [4140.2, 287.65], [4124.0, 287.65], [4031.5, 333.9], [3939.0, 287.65]], white)
  board(te, 'x', 2279.6, 0.75, [[3939.0, 287.65], [4124.0, 287.65], [4124.0, 290.7], [3939.0, 290.7]], white)
  board(te, 'x', 2279.6, 1.5, [[4027.8, 307.9], [4035.1, 307.9], [4035.1, 324.0], [4027.8, 324.0]], white)
  board(te, 'x', 2279.6, 1.5, [[4029.7, 309.9], [4033.2, 309.9], [4033.2, 333.9], [4029.7, 333.9]], white)
  log "  #{te.length} trim pieces"

  log '9. covered terrace deck, railings and stair to the DWG (deck to x 2426, stair on the south side x 2351.2..2399.2)'
  deck = m.find_entity_by_persistent_id(447791) or raise 'deck 447791 missing'
  db = deck.bounds
  dmat = deck.entities.grep(Sketchup::Face).map(&:material).compact.first
  nd = m.entities.add_group; nd.name = 'Covered terrace deck (v2)'
  box(nd.entities, db.min.x, 2426.0, db.min.y, db.max.y, db.min.z, db.max.z, dmat)
  log "  deck #{b3(db)} -> #{b3(nd.bounds)}"
  gone = [447791, 449633, 449634, 449643, 449644, 447711].map { |pid| m.find_entity_by_persistent_id(pid) }
  log "  removed: #{gone.compact.map { |e| "#{e.persistent_id} #{e.definition.name} #{b3(e.bounds)}" }.join('; ')}"
  sr = m.find_entity_by_persistent_id(449606) or raise 'south railing 449606 missing'
  rb = sr.bounds
  [[2290.6, 2346.9], [2401.9, 2417.0]].each do |a, z|
    c = m.entities.add_instance(sr.definition, sr.transformation)
    c.transform!(Geom::Transformation.scaling(Geom::Point3d.new(rb.min.x, rb.center.y, rb.min.z), (z - a) / rb.width, 1, 1))
    c.transform!(Geom::Transformation.translation([a - c.bounds.min.x, 0, 0]))
    log "  south railing piece #{b3(c.bounds)}"
  end
  post = m.find_entity_by_persistent_id(449627) or raise 'post 449627 missing'
  pc = post.copy
  post.transform!(Geom::Transformation.translation([2351.2 - post.bounds.max.x, 0, 0]))
  pc.transform!(Geom::Transformation.translation([2399.2 - pc.bounds.min.x, 0, 0]))
  log "  stair posts #{b3(post.bounds)} / #{b3(pc.bounds)}"
  rail_mat = post.definition.entities.grep(Sketchup::Face).map(&:material).compact.first || dmat
  m.entities.erase_entities(gone.compact + [sr])
  st = m.entities.add_group; st.name = 'Covered terrace stair (v2)'; se = st.entities
  ye = db.min.y                       # deck edge
  ztop = db.max.z                     # deck top 23.3 (DWG 24.8)
  4.times do |i|
    box(se, 2351.2, 2399.2, ye - 12.0 * (i + 1), ye - 12.0 * i, -14.0, ztop - 6.8 * (i + 1), dmat)
  end
  k = 6.8 / 12.0
  [[2349.7, 2351.2], [2399.2, 2400.7]].each do |x0, x1|
    rail(se, x0, x1, ye - 50.5, ye, ztop + 6.6 - 1.5, ye - 50.5 + 0.0, k, 1.7, rail_mat)          # top rail
    rail(se, x0, x1, ye - 50.5, ye, ztop + 0.3 - 1.5, ye - 50.5, k, 1.7, rail_mat)                # lower rail
    rail(se, x0, x1, ye - 50.5, ye, ztop - 31.2, ye - 50.5, k, 6.0, rail_mat)                    # stringer
    y = ye - 49.0
    while y < ye - 2.0
      zb = ztop - 31.2 + 6.0 + k * (y - (ye - 50.5))
      zt = ztop + 6.6 - 1.5 + k * (y - (ye - 50.5))
      box(se, x0, x1, y, y + 1.5, zb, zt, rail_mat)
      y += 5.5
    end
    box(se, x0 - 1.0, x1 + 1.0, ye - 51.5, ye - 48.0, ztop - 34.0, ztop + 9.8, rail_mat)       # bottom newel post
  end
  log "  stair #{b3(st.bounds)}"

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
  [['chk_sw.png', [1100, 2700, 900], [1950, 3800, 200]], ['chk_se.png', [2900, 2800, 800], [2000, 3800, 180]], ['chk_ne.png', [3000, 5000, 800], [2050, 3950, 150]], ['chk_garage_e.png', [2400, 3000, 450], [1850, 3550, 200]], ['chk_wing.png', [1400, 3000, 700], [1760, 3760, 300]]].each do |n, eye, tg|
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
