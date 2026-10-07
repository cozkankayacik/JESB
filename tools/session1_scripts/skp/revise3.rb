# JESB Lot 2 - v2 -> v3
#   2. All roofs rebuilt with 12" eave overhang (DWG roof plan form, eaves 12" off the model's exterior wall faces).
#   3. Both garage doors moved to the DWG plan positions.
#   4. Driveway slab widened to cover both doors.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot2_v3.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result3.txt'), LOG.join("\n"))
end

def add_face(ents, inv, pts, mat, up)
  uniq = []
  pts.each { |p| uniq << p unless uniq.any? { |q| (q[0] - p[0]).abs < 0.01 && (q[1] - p[1]).abs < 0.01 && (q[2] - p[2]).abs < 0.01 } }
  return nil if uniq.length < 3
  f = ents.add_face(uniq.map { |p| Geom::Point3d.new(*p).transform(inv) })
  f.reverse! if !up.nil? && (f.normal.transform(inv.inverse).z > 0) != up
  f.material = mat if mat
  f
end

# Equal-pitch (6:12) hip roof solid over a rectangle; optional flat cap at height `cap` above the eave.
def hip_solid(parent, inv, x0, x1, y0, y1, e, mat, cap = nil)
  g = parent.add_group
  t = [x1 - x0, y1 - y0].min / 2.0
  t = [t, cap * 2.0].min if cap
  h = t / 2.0
  b = [[x0, y0, e], [x1, y0, e], [x1, y1, e], [x0, y1, e]]
  tp = [[x0 + t, y0 + t, e + h], [x1 - t, y0 + t, e + h], [x1 - t, y1 - t, e + h], [x0 + t, y1 - t, e + h]]
  add_face(g.entities, inv, b, nil, false)
  4.times { |i| j = (i + 1) % 4; add_face(g.entities, inv, [b[i], b[j], tp[j], tp[i]], mat, true) }
  add_face(g.entities, inv, tp, mat, true)
  g
end

def cleanup_coplanar(ents)
  removed = 0
  loop do
    dead = ents.grep(Sketchup::Edge).select do |ed|
      fs = ed.faces
      fs.length == 2 && fs[0].normal.samedirection?(fs[1].normal) && fs[0].material == fs[1].material
    end
    break if dead.empty?
    removed += dead.length
    ents.erase_entities(dead)
  end
  removed
end

def move_verts(ents, tr)
  inv = tr.inverse
  vs = []; vecs = []
  ents.grep(Sketchup::Edge).flat_map(&:vertices).uniq.each do |v|
    vec = yield(v.position.transform(tr))
    next unless vec
    vs << v; vecs << vec.transform(inv)
  end
  ents.transform_by_vectors(vs, vecs) unless vs.empty?
  vs.length
end

def shot(view, name, eye, target, persp, height = nil, w = 2400, hh = 1500)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: w, height: hh, antialias: true, transparent: false)
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  orig_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  roof = m.find_entity_by_persistent_id(212244)
  dining = m.find_entity_by_persistent_id(212299)
  leanto = m.find_entity_by_persistent_id(212342)
  wwall = m.find_entity_by_persistent_id(192973)
  raise 'roof groups not found' if [roof, dining, leanto, wwall].any?(&:nil?)
  shingle = m.materials['Material3']
  ovh = 12.0
  e = 260.79

  m.start_operation('JESB Lot 2 v3', true)

  # ---------- main roof: union of hip masses, eaves = exterior wall face + 12" ----------
  west = 2755.44 - ovh; gfront = 6537.22 - ovh; rear = 6992.30 + ovh
  bfront = 6488.18 - ovh; bwest = 3022.88 - ovh; beast = 3613.59 + ovh
  cx0 = 3135.38 - ovh; cx1 = 3349.38 + ovh; cfront = 6442.68 - ovh
  gx0 = 2946.94 - ovh; gx1 = 3148.88 + ovh; grear = 7027.17 + ovh
  ex0 = 3529.38 - ovh; east = 3690.38 + ovh; efront = 6431.17 - ovh; wnorth = 6733.17 + ovh
  tx0 = 3433.38 - ovh; tfront = 6470.67 - ovh
  inv = roof.transformation.inverse
  old = roof.entities.to_a
  roof.entities.erase_entities(old)
  re = roof.entities
  masses = {
    'A garage/west' => hip_solid(re, inv, west, 3500.0, gfront, rear, e, shingle),
    'B main'        => hip_solid(re, inv, bwest, beast, bfront, rear, e, shingle),
    'C front bay'   => hip_solid(re, inv, cx0, cx1, cfront, 6720.0, e, shingle),
    'G rear bump'   => hip_solid(re, inv, gx0, gx1, 6700.0, grear, e, shingle),
    'F east wing'   => hip_solid(re, inv, 3300.0, east, bfront, wnorth, e, shingle),
    'E right bay'   => hip_solid(re, inv, ex0, east, efront, wnorth, e, shingle)
  }
  f_ridge = (wnorth - bfront) / 4.0
  masses['D entry tower'] = hip_solid(re, inv, tx0, east, tfront, wnorth, e, shingle, f_ridge)
  masses.each { |k, g| log "mass #{k}: solid=#{g.manifold?} faces=#{g.entities.grep(Sketchup::Face).length}" }
  res = nil
  masses.each_value do |g|
    if res.nil? then res = g
    else
      r = res.outer_shell(g)
      if r.nil? then log 'outer_shell returned nil; masses left as separate groups'; res = nil; break end
      res = r
    end
  end
  if res
    removed = cleanup_coplanar(res.entities)
    res.name = 'Roof - Main (12in overhang, Rev 10-5-26)'
    res.entities.grep(Sketchup::Face).each { |f| f.material = (f.normal.transform(roof.transformation).z > 0.01 ? shingle : nil) }
    log "main roof: union solid=#{res.manifold?} faces=#{res.entities.grep(Sketchup::Face).length} coplanar edges removed=#{removed}"
  end
  log "main roof bounds: #{roof.bounds.min.to_a.map { |a| a.round(2) }} .. #{roof.bounds.max.to_a.map { |a| a.round(2) }}"

  # ---------- dining roof (4:12 sides, 6:12 rear hip) ----------
  dz = 138.04; dys = 6990.34
  dx0 = 3139.60 - ovh; dx1 = 3349.60 + ovh; dyr = 7138.46 + ovh
  dxc = (dx0 + dx1) / 2.0; dh = (dxc - dx0) / 3.0; dya = dyr - dh * 2.0
  m.entities.erase_entities([dining])
  g = m.entities.add_group
  g.name = 'Roof - Dining (12in overhang)'
  idt = Geom::Transformation.new
  add_face(g.entities, idt, [[dx0, dys, dz], [dx0, dyr, dz], [dxc, dya, dz + dh], [dxc, dys, dz + dh]], shingle, true)
  add_face(g.entities, idt, [[dx1, dys, dz], [dx1, dyr, dz], [dxc, dya, dz + dh], [dxc, dys, dz + dh]], shingle, true)
  add_face(g.entities, idt, [[dx0, dyr, dz], [dx1, dyr, dz], [dxc, dya, dz + dh]], shingle, true)
  add_face(g.entities, idt, [[dx0, dys, dz], [dx1, dys, dz], [dx1, dyr, dz], [dx0, dyr, dz]], nil, false)
  add_face(g.entities, idt, [[dx0, dys, dz], [dx1, dys, dz], [dxc, dys, dz + dh]], nil, nil)
  log "dining roof: eaves x #{dx0}..#{dx1} y #{dyr}, ridge z #{(dz + dh).round(2)}, solid=#{g.manifold?}"

  # ---------- rear lean-to roof over the garage ----------
  lz = 122.04; ly0 = 6992.40; ly1 = 7027.17 + ovh; lx0 = west; lx1 = 2946.88
  lh = (ly1 - ly0) / 2.0; lxh = lx0 + (ly1 - ly0)
  m.entities.erase_entities([leanto])
  g = m.entities.add_group
  g.name = 'Roof - Rear Lean-to (12in overhang)'
  add_face(g.entities, idt, [[lx0, ly1, lz], [lx1, ly1, lz], [lx1, ly0, lz + lh], [lxh, ly0, lz + lh]], shingle, true)
  add_face(g.entities, idt, [[lx0, ly0, lz], [lx0, ly1, lz], [lxh, ly0, lz + lh]], shingle, true)
  add_face(g.entities, idt, [[lx0, ly0, lz], [lx1, ly0, lz], [lx1, ly0, lz + lh], [lxh, ly0, lz + lh]], nil, nil)
  add_face(g.entities, idt, [[lx1, ly0, lz], [lx1, ly1, lz], [lx1, ly0, lz + lh]], nil, nil)
  add_face(g.entities, idt, [[lx0, ly0, lz], [lx1, ly0, lz], [lx1, ly1, lz], [lx0, ly1, lz]], nil, false)
  log "lean-to roof: eave y #{ly1} x #{lx0}, top z #{(lz + lh).round(2)}, solid=#{g.manifold?}"

  # ---------- garage doors to plan positions ----------
  dy = 3.23  # plan: 30" corner pier, 16'-0" door, 25" pier, 16'-0" door, measured from the garage front frame corner (y 6537.40)
  jambs = [6564.17, 6756.17, 6781.17, 6973.17]
  n = move_verts(wwall.entities, wwall.transformation) do |p|
    p.z <= 93.5 && jambs.any? { |j| (p.y - j).abs < 0.05 } ? Geom::Vector3d.new(0, dy, 0) : nil
  end
  doors = m.entities.grep(Sketchup::ComponentInstance).select { |i| i.definition.name == 'Garage Doors' }
  doors.each { |d| d.transform!(Geom::Transformation.translation([0, dy, 0])) }
  log "garage: #{n} jamb vertices and #{doors.length} doors moved +#{dy}\" in y; openings y #{jambs[0] + dy}..#{jambs[1] + dy} and #{jambs[2] + dy}..#{jambs[3] + dy}"
  doors.each { |d| log "  door bb y #{d.bounds.min.y.round(2)}..#{d.bounds.max.y.round(2)} z #{d.bounds.min.z.round(2)}..#{d.bounds.max.z.round(2)}" }

  # ---------- driveway ----------
  drive = m.entities.grep(Sketchup::Face).select { |f| f.bounds.min.x < 2400 && f.bounds.max.x <= 2755.5 && f.bounds.max.z < 0 }
  north_margin = 6981.73 - (jambs[3] + dy)
  new_south = jambs[0] + dy - north_margin
  dverts = drive.flat_map(&:vertices).uniq.select { |vx| (vx.position.y - 6584.92).abs < 0.05 }
  m.entities.transform_by_vectors(dverts, dverts.map { Geom::Vector3d.new(0, new_south - 6584.92, 0) })
  db = Geom::BoundingBox.new
  nd = dverts.length
  drive = m.entities.grep(Sketchup::Face).select { |f| f.bounds.min.x < 2400 && f.bounds.max.x <= 2755.5 && f.bounds.max.z < 0 }
  drive.each { |f| db.add(f.bounds) }
  log "driveway: #{drive.length} faces, #{nd} vertices moved; slab y #{db.min.y.round(2)}..#{db.max.y.round(2)} (was 6584.92..6981.73), x #{db.min.x.round(2)}..#{db.max.x.round(2)}"

  m.commit_operation
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  # ---------- exports ----------
  cx = 3226.0; cy = 6785.0; cz = 160.0; d = 3000.0
  shot(v, 'JESB_Lot2_v3_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v3_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v3_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v3_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, 760)
  v.camera = orig_cam
  v.write_image(filename: File.join(OUT, 'JESB_Lot2_v3_Perspective.png'), width: 2400, height: 1500, antialias: true, transparent: false)
  shot(v, 'chk3_front_high.jpg', [3250, 5700, 800], [3300, 6650, 280], true, nil, 1800, 1100)
  shot(v, 'chk3_east_high.jpg', [4300, 6000, 750], [3450, 6650, 290], true, nil, 1800, 1100)
  shot(v, 'chk3_rear_high.jpg', [2900, 7900, 700], [3150, 6950, 200], true, nil, 1800, 1100)
  shot(v, 'chk3_garage.jpg', [2000, 6350, 180], [2760, 6770, 90], true, nil, 1800, 1100)
  shot(v, 'chk3_tower.jpg', [3350, 6000, 330], [3480, 6500, 230], true, nil, 1800, 1100)
  tag = m.layers['REF_DWG_Rev_2026-10-05']
  tag.visible = true
  cam = Sketchup::Camera.new([3226, 6790, 3000], [3226, 6790, 0], [0, 1, 0])
  cam.perspective = false
  cam.height = 900
  v.camera = cam
  v.write_image(filename: File.join(OUT, 'chk3_top.jpg'), width: 2400, height: 1500, antialias: true)
  tag.visible = false
  v.camera = orig_cam
  log 'exports written'
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => ex
  log "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(8).join("\n")}"
  File.write(File.join(OUT, 'done.txt'), 'ERR')
end

tries = 0
tid = UI.start_timer(2, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid)
    UI.start_timer(3, false) { revise }
  elsif tries > 60
    UI.stop_timer(tid)
    File.write(File.join(OUT, 'done.txt'), 'ERR no model loaded')
  end
end
