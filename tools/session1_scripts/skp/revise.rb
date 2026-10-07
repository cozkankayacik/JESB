# JESB Lot 2 - apply 10/5/26 exterior revisions to the SketchUp model.
#   1. Entry tower: remove flat cap, lower tower walls to the eave, add hip roof per DWG roof plan.
#   2. Garage: both openings 16'-0" x 8'-0" (DWG tag 16080 OVHD), one shared door component.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot2_v2.skp')
REF_DWG = File.join(OUT, 'Lot2_revisions1_ref.dwg')
LOG = []

def log(s)
  LOG << s
  File.write(File.join(OUT, 'result.txt'), LOG.join("\n"))
end

def move_verts(group)
  ents = group.entities
  tr = group.transformation
  inv = tr.inverse
  verts = ents.grep(Sketchup::Edge).flat_map(&:vertices).uniq
  vs = []
  vecs = []
  verts.each do |v|
    vec = yield(v.position.transform(tr))
    next unless vec
    vs << v
    vecs << vec.transform(inv)
  end
  ents.transform_by_vectors(vs, vecs) unless vs.empty?
  vs.length
end

def shot(view, name, eye, target, persp, height = nil, fov = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  cam.fov = fov if fov && persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  orig_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)

  roof   = m.find_entity_by_persistent_id(212244) # Group#53 main roof
  cap    = m.find_entity_by_persistent_id(212534) # Group#60 instance: flat cap on entry tower
  tower  = m.find_entity_by_persistent_id(189634) # Group#13 entry tower wall
  wwall  = m.find_entity_by_persistent_id(192973) # Group#19 garage west wall
  door_n = m.find_entity_by_persistent_id(194339) # 'Garage Doors' 16' door (north)
  door_s = m.find_entity_by_persistent_id(196417) # 'Garage Doors#2' 8' door (south)
  raise 'expected entities not found' if [roof, cap, tower, wwall, door_n, door_s].any?(&:nil?)

  m.start_operation('JESB Lot 2 Rev 10/5/26', true)

  # ---------- 1. entry tower roof ----------
  e   = 260.79            # eave / top plate level used by the existing roof
  y_m = 6482.53           # existing main front eave
  x_b = 3516.09           # existing right-bay roof: west eave
  x_br = 3606.09          # existing right-bay ridge (z = e + 45)
  x_be = 3696.09          # existing right-bay roof: east eave
  y_bb = 6570.03          # back edge of the right-bay roof
  y_r = 6613.28           # existing ridge between main front plane and wing north plane
  rise = y_r - y_m        # 130.75 plan run -> 65.375 rise at 6:12
  z_r = e + rise / 2.0
  ovh = 7.14              # eave overhang, same as existing main eave over the entry wall
  x_w = 3433.38 - ovh     # tower west eave
  y_t = 6470.67 - ovh     # tower front eave
  y_top = y_t + rise
  x_p6 = x_w + rise
  x_p5 = x_be + y_t - y_top

  cap.erase!
  n = move_verts(tower) { |p| (p.z - 284.45).abs < 0.05 ? Geom::Vector3d.new(0, 0, e - 284.45) : nil }
  log "tower: flat cap removed, #{n} wall-top vertices lowered 284.45 -> #{e}"

  inv = roof.transformation.inverse
  g = roof.entities.add_group
  g.name = 'Roof - Entry Tower (Rev 10-5-26)'
  shingle = m.materials['Material3']
  mk = lambda do |pts, mat, up|
    f = g.entities.add_face(pts.map { |p| Geom::Point3d.new(*p).transform(inv) })
    f.reverse! if (f.normal.z > 0) != up
    f.material = mat if mat
    f
  end
  p1 = [x_w, y_t, e]
  p2 = [x_b, y_t, e]
  p3 = [x_br, y_t + (x_br - x_b), e + (x_br - x_b) / 2.0]
  p5 = [x_p5, y_top, z_r]
  p6 = [x_p6, y_top, z_r]
  mk.call([p1, p2, p3, p5, p6], shingle, true)                                   # tower front plane, 6:12
  mk.call([p1, p6, [x_p6, y_r, z_r], [x_w, y_m, e]], shingle, true)              # west return plane, 6:12
  mk.call([p6, p5, [x_p5, y_r, z_r], [x_p6, y_r, z_r]], shingle, true)           # flat patch at ridge height (as drawn)
  x_me = x_be + y_m - y_bb                                                       # bay east plane meets main plane at back edge
  mk.call([p3, p5, [x_p5, y_r, z_r], [x_me, y_bb, e + (y_bb - y_m) / 2.0], [x_br, y_bb, e + 45.0]], shingle, true) # east plane extended up to tower plane
  mk.call([[x_w, y_t, e], [x_b, y_t, e], [x_b, y_m, e], [x_w, y_m, e]], nil, false) # eave soffit
  log "tower roof: #{g.entities.grep(Sketchup::Face).length} faces, eave y=#{y_t.round(2)} x=#{x_w.round(2)}, top z=#{z_r.round(2)}"

  # ---------- 2. garage doors ----------
  old_s = door_s.bounds
  s_jamb = 6591.17
  n_jamb = 6687.17
  new_n = 6781.17 - 25.0          # 25" pier between the doors per plan
  new_s = new_n - 192.0           # 16'-0" opening
  n = move_verts(wwall) do |p|
    next nil if p.z > 93.5
    if (p.y - s_jamb).abs < 0.05 then Geom::Vector3d.new(0, new_s - s_jamb, 0)
    elsif (p.y - n_jamb).abs < 0.05 then Geom::Vector3d.new(0, new_n - n_jamb, 0)
    end
  end
  log "garage wall: #{n} jamb vertices moved; south opening y #{new_s.round(2)}..#{new_n.round(2)} (192.0 wide), header z 93.0"
  shift = Geom::Transformation.translation([0, new_s - 6781.17, 0])
  d2 = m.entities.add_instance(door_n.definition, shift * door_n.transformation)
  d2.material = door_n.material
  d2.layer = door_n.layer
  door_s.erase!
  log "garage doors: south door replaced. old bb y #{old_s.min.y.round(2)}..#{old_s.max.y.round(2)}; new '#{d2.definition.name}' bb y #{d2.bounds.min.y.round(2)}..#{d2.bounds.max.y.round(2)} z #{d2.bounds.min.z.round(2)}..#{d2.bounds.max.z.round(2)}; instances of '#{d2.definition.name}': #{d2.definition.count_used_instances}"

  m.commit_operation
  ok = m.save(SAVE_AS)
  log "saved: #{ok} #{SAVE_AS}"

  # ---------- 3. DWG reference (hidden tag) ----------
  begin
    before = m.entities.to_a
    imported = m.import(REF_DWG, false)
    added = m.entities.to_a - before
    log "dwg import: #{imported}, new top-level entities: #{added.length} (#{added.map(&:typename).uniq.join(',')})"
    if imported && !added.empty?
      m.start_operation('Reference DWG', true)
      ref = added.length == 1 ? added.first : m.entities.add_group(added)
      ref.name = 'REF DWG Lot 2 revisions1 (10-5-26)' if ref.respond_to?(:name=)
      # first floor plan: garage SW frame corner (10629.14, 3393.19) -> model garage SW wall corner
      ref.transform!(Geom::Transformation.translation([2755.44 - 10629.14, 6537.40 - 3393.19, 0]))
      tag = m.layers.add('REF_DWG_Rev_2026-10-05')
      ref.layer = tag
      tag.visible = false
      m.commit_operation
      log "dwg reference placed on hidden tag '#{tag.name}', bb #{ref.bounds.min.to_a.map { |a| a.round(1) }} .. #{ref.bounds.max.to_a.map { |a| a.round(1) }}"
      log "saved with reference: #{m.save(SAVE_AS)}"
    end
  rescue => ex
    log "dwg import failed: #{ex.class}: #{ex.message}"
  end

  # ---------- 4. exports ----------
  cx = 3226.0; cy = 6785.0; cz = 160.0; d = 3000.0
  shot(v, 'JESB_Lot2_v2_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v2_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v2_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v2_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, 760)
  v.camera = orig_cam
  v.write_image(filename: File.join(OUT, 'JESB_Lot2_v2_Perspective.png'), width: 2400, height: 1500, antialias: true, transparent: false)
  # check views (not deliverables)
  shot(v, 'chk_tower.jpg', [3350, 6000, 330], [3480, 6500, 230], true)
  shot(v, 'chk_tower_high.jpg', [3250, 5900, 700], [3530, 6560, 280], true)
  shot(v, 'chk_tower_east.jpg', [4100, 6100, 600], [3560, 6560, 290], true)
  shot(v, 'chk_garage.jpg', [2150, 6450, 160], [2760, 6760, 80], true)
  cam = Sketchup::Camera.new([3520, 6540, 3000], [3520, 6540, 0], [0, 1, 0])
  cam.perspective = false
  cam.height = 260
  v.camera = cam
  v.write_image(filename: File.join(OUT, 'chk_tower_top.jpg'), width: 1800, height: 1100, antialias: true)
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
