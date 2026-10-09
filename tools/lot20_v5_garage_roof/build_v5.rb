# JESB Lot 20 - model v5: garage roof revised to the roof plan AND the elevations of "Lot-20 base rend.dwg".
require 'json'
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v5.skp')
DATA = JSON.parse(File.read(File.join(OUT, 'roof_garage.json')))
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v5.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end

def shot(view, name, eye, target, persp, height = nil, up = [0, 0, 1], w = 2400, h = 1500)
  cam = Sketchup::Camera.new(eye, target, up)
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: w, height: h, antialias: true, transparent: false)
end

def merge_coplanar(ents)
  n = 0
  loop do
    dead = ents.grep(Sketchup::Edge).select do |e|
      e.faces.length == 2 && e.faces[0].normal.samedirection?(e.faces[1].normal)
    end
    break if dead.empty?
    n += dead.length
    ents.erase_entities(dead)
  end
  stray = ents.grep(Sketchup::Edge).select { |e| e.faces.empty? }
  ents.erase_entities(stray) unless stray.empty?
  [n, stray.length]
end

def build_roof(house, hinv, name, spec, shingle)
  zt = spec['zt']; zb = spec['zb']
  g = house.entities.add_group
  g.name = name
  ents = g.entities
  failed = 0
  spec['faces'].each do |fc|
    pts = fc['pts'].map { |p| Geom::Point3d.new(*p).transform(hinv) }
    begin
      f = ents.add_face(pts)
      f.reverse! if f.normal.z < 0
    rescue => ex
      failed += 1
    end
  end
  merged, stray = merge_coplanar(ents)
  tops = ents.grep(Sketchup::Face)
  log "#{name}: #{spec['faces'].length} cells (#{failed} failed), #{merged} coplanar edges merged, #{stray} stray -> #{tops.length} roof planes"
  # vertical edge (fascia) under every free edge, down to the fascia bottom
  free = ents.grep(Sketchup::Edge).select { |e| e.faces.length == 1 }
  zoff = hinv.origin.z
  free.each do |e|
    a, b = e.start.position, e.end.position
    a2 = Geom::Point3d.new(a.x, a.y, zb + zoff); b2 = Geom::Point3d.new(b.x, b.y, zb + zoff)
    begin
      ents.add_face([a, b, b2, a2])
    rescue => ex
      log "  fascia face failed: #{ex.message}"
    end
  end
  # soffit / underside
  bottom = ents.grep(Sketchup::Edge).select { |e| near(e.start.position.z, zb + zoff, 0.001) && near(e.end.position.z, zb + zoff, 0.001) }
  bottom.each { |e| e.find_faces if e.faces.length < 2 }
  merge_coplanar(ents)
  faces = ents.grep(Sketchup::Face)
  faces.each do |f|
    nz = f.normal.z
    if nz.abs < 0.001
      # fascia: outward
      next
    elsif near(f.vertices.map { |v| v.position.z }.max, zb + zoff, 0.001)
      f.reverse! if nz > 0
    else
      f.reverse! if nz < 0
      n = f.normal
      u = Geom::Vector3d.new(0, 0, 1).cross(n); u.normalize!
      up = n.cross(u); up.normalize!
      up.reverse! if up.z < 0
      p0 = f.vertices.min_by { |v| v.position.z }.position
      tw = shingle.texture ? shingle.texture.width : 48.0
      th = shingle.texture ? shingle.texture.height : 48.0
      f.position_material(shingle, [p0, [0, 0], p0.offset(u, tw), [1, 0], p0.offset(up, th), [0, 1]], true)
    end
  end
  open_edges = ents.grep(Sketchup::Edge).count { |e| e.faces.length != 2 }
  b = Geom::BoundingBox.new
  (0..7).each { |i| b.add(g.bounds.corner(i).transform(house.transformation)) }
  slopes = faces.select { |f| f.normal.z.abs > 0.001 && f.material }.length
  log format('  faces %d (sloped %d), open edges %d, manifold %s, volume %.0f cu ft', faces.length, slopes, open_edges, g.manifold?, (g.manifold? ? g.volume / 1728.0 : 0))
  log format('  bounds x %.2f..%.2f  y %.2f..%.2f  z %.2f..%.2f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z)
  g
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
  hinv = ht.inverse
  shingle = m.materials['Material3']
  raise 'shingle material not found' unless shingle
  old = house.entities.grep(Sketchup::Group).select { |g| g.name =~ /^Roof - Garage/ }
  raise "expected one garage roof group, found #{old.length}" unless old.length == 1
  m.start_operation('JESB Lot 20 v5 garage roof', true)
  b = old[0].bounds
  log format('removed %s  x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', old[0].name, b.min.x + ht.origin.x, b.max.x + ht.origin.x, b.min.y + ht.origin.y, b.max.y + ht.origin.y, b.min.z + ht.origin.z, b.max.z + ht.origin.z)
  house.entities.erase_entities(old)
  g = build_roof(house, hinv, 'Roof - Garage (per DWG plan and elevations, v5)', DATA['garage'], shingle)
  g.entities.grep(Sketchup::Face).select { |f| f.normal.z > 0.01 }.sort_by { |f| -f.area }.each do |f|
    n = f.normal
    zs = f.vertices.map { |x| x.position.z + ht.origin.z }
    log format('    roof plane %.1f sq ft  pitch %.2f:12  z %.1f..%.1f', f.area / 144.0, Math.sqrt(n.x**2 + n.y**2) / n.z * 12, zs.min, zs.max)
  end
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  b = house.bounds
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  d = 3000.0
  hgt = [b.width, b.height].max * 0.80
  log format('house centre %.2f %.2f %.2f elevation camera height %.3f', cx, cy, cz, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_top.png', [12770, 3870, 3000], [12770, 3870, 0], false, 1100.0, [0, 1, 0], 2400, 2400)
  shot(v, 'chk_garage_se.png', [13150, 3050, 520], [12520, 3640, 150], true)
  shot(v, 'chk_garage_e.png', [13300, 3620, 420], [12560, 3640, 160], true)
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