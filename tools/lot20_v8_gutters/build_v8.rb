# JESB Lot 20 - model v8: back to the v5 model, with black gutters added and nothing else (owner's decision 2026-10-12).
# None of the v6 / v7 changes are in this model (four windows, sills and frieze removed, extra black panels,
# seamless white panels, downspouts).
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v8.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v8.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
GW = 5.0
def gutters(m, house, ht)
  hinv = ht.inverse
  mat = m.materials.add('Gutter - Black'); mat.color = Sketchup::Color.new(22, 22, 24)
  grp = house.entities.add_group
  grp.name = 'Gutters - Black (v8)'
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
      a2 = convex[i] ? a.offset(e, -GW) : a
      b2 = convex[(i + 1) % n] ? b.offset(e, GW) : b
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
  log format('  gutters: %d pieces, %.0f ft in total, 5 x 5 in, black', grp.entities.length, total / 12.0)
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  ht = house.transformation
  names = house.entities.grep(Sketchup::Group).map(&:name)
  raise 'this is not the v5 model (gutters or downspouts already present)' if names.any? { |n| n =~ /Gutters|Downspouts/ }
  raise 'v5 garage roof not found' unless names.any? { |n| n =~ /Roof - Garage \(per DWG plan and elevations, v5\)/ }
  log "base model: #{File.basename(m.path)}; sills present: #{names.count { |n| n =~ /^Sill/ }} named + original ones; Hardie materials: #{m.materials.map(&:name).grep(/Hardie/).join(', ')}"
  m.start_operation('JESB Lot 20 v8 gutters', true)
  gutters(m, house, ht)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  cx, cy, cz = 12776.80, 3838.76, 187.33
  d = 3000.0; hgt = 813.694
  shot(v, 'JESB_Lot20_v8_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v8_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v8_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v8_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v8_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
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
