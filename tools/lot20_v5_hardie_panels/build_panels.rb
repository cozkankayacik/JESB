# JESB Lot 20 v5 - the "siding boards" of the Kami notes become Hardie board panels (owner's reference image, 2026-10-09):
# smooth flat panels with thin reveal joints instead of lap boards. Same faces and colours as v4.
# Joints are drawn as edges on the wall faces: vertical joints at the window jambs, horizontal joints at the lower
# window head and the upper window sill (z 127.0 / 182.7), so the black panels sit exactly in that band.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v5.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_panels.txt'), LOG.join("\n"))
end
BAND = [127.0, 182.7].freeze
# face pid => [note, axis of the vertical joints (:x or :y), vertical joint positions (world), horizontal joint heights]
SPEC = {
  125173 => ['F1 front - garage bay', :x, [12444.8, 12508.8], []],
  125205 => ['F1 front - garage bay, left return', :y, [], []],
  125199 => ['F1 front - garage bay, right return', :y, [], []],
  127288 => ['F3 front - window bay left of the entry', :x, [12688.3, 12784.3], BAND],
  132014 => ['F4 front - tall window bay right of the entry', :x, [12961.7, 13015.8], [92.75, 172.75]],
  132021 => ['F4 front - tall window bay, side return', :y, [], [92.75, 172.75]],
  157982 => ['S1 right side - panel bay', :y, [4010.1, 4034.1], BAND],
  157989 => ['S1 right side - panel bay, return', :x, [], BAND],
  157985 => ['S1 right side - panel bay, return', :x, [], BAND],
  127831 => ['F2 front - black panel, bay left of the entry', :x, [12736.3], []],
  131648 => ['F5 front - black panel, right bay', :x, [13121.9], []],
  165484 => ['R1 rear - black panel', :x, [12900.5, 12961.1], []]
}.freeze

def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end

# pieces of the line (origin o, unit direction d, both in the face's own coordinates) that lie inside the face
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

def joints(m, house, pid, spec)
  note, axis, vs, hs = spec
  f = m.find_entity_by_persistent_id(pid)
  raise "face #{pid} not found (#{note})" unless f.is_a?(Sketchup::Face)
  grp = f.parent.instances.first
  tr = house.transformation * grp.transformation
  inv = tr.inverse
  ents = f.parent.entities
  pw = f.vertices.first.position.transform(tr)
  bb = Geom::BoundingBox.new
  f.vertices.each { |v| bb.add(v.position.transform(tr)) }
  along = axis == :x ? Geom::Vector3d.new(1, 0, 0) : Geom::Vector3d.new(0, 1, 0)
  along_l = along.transform(inv); up_l = Geom::Vector3d.new(0, 0, 1).transform(inv)
  base = axis == :x ? Geom::Point3d.new(0, pw.y, 0) : Geom::Point3d.new(pw.x, 0, 0)
  pieces = []
  vs.each do |c|
    o = (axis == :x ? Geom::Point3d.new(c, pw.y, 0) : Geom::Point3d.new(pw.x, c, 0)).transform(inv)
    pieces.concat(inside_pieces(f, o, up_l, hs.dup))                    # break at the horizontal joints
  end
  hs.each do |z|
    o = Geom::Point3d.new(base.x, base.y, z).transform(inv)
    pieces.concat(inside_pieces(f, o, along_l, vs.dup))                 # break at the vertical joints
  end
  len = 0.0
  pieces.each { |a, b| ents.add_line(a, b); len += a.distance(b) }
  log format('  %-50s pid %d  %d joint pieces, %.0f in  (face x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f)', note, pid, pieces.length, len, bb.min.x, bb.max.x, bb.min.y, bb.max.y, bb.min.z, bb.max.z)
  len
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  white = m.materials['Siding Boards - Arctic White']; black = m.materials['Siding Boards - Black']
  raise 'v4 siding materials not found' unless white && black
  m.start_operation('JESB Lot 20 v5 Hardie panels', true)
  [[white, 'Hardie Panel - Arctic White', [241, 242, 237]], [black, 'Hardie Panel - Black', [38, 38, 40]]].each do |mat, name, rgb|
    mat.texture = nil
    mat.color = Sketchup::Color.new(*rgb)
    mat.name = name
    log "material -> #{mat.name}: smooth, no texture, rgb #{rgb.join(' ')}"
  end
  total = 0.0
  SPEC.each { |pid, spec| total += joints(m, house, pid, spec) }
  log format('joint lines added: %.0f ft in total', total / 12.0)
  areas = Hash.new(0.0)
  walk = lambda do |ents|
    ents.each do |e|
      if e.is_a?(Sketchup::Face) then areas[e.material.name] += e.area / 144.0 if e.material && e.material.name =~ /^Hardie Panel/
      elsif e.is_a?(Sketchup::Group) then walk.call(e.entities)
      end
    end
  end
  walk.call(house.entities)
  log 'panel areas: ' + areas.map { |k, a| format('%s %.1f sq ft', k, a) }.join(', ')
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  b = house.bounds
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  d = 3000.0
  hgt = [b.width, b.height].max * 0.80
  shot(v, 'JESB_Lot20_v5_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v5_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_front_close.png', [12850, 3300, 140], [12850, 3800, 130], true)
  shot(v, 'chk_right_close.png', [13700, 4022, 140], [13208, 4022, 130], true)
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
