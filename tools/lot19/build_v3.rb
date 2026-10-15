# JESB Lot 19 - model v3 (from v2):
#   1. terrain around the house: grade taken from the bottoms of the exterior wall faces (the model's walls already follow
#      the drawn grade), interpolated (inverse distance) over a 24 in. grid, with a skirt so elevations show a ground mass
#   2. soffit: underside of every roof painted Arctic White
#   3. frieze board under the eaves (A-300 note "5/4 x 8 frieze board, eng. wd. trim, Arctic White, typ."):
#      white band z 265.2..272.5, 0.75 in. proud, on every exterior wall that runs up to the main roof
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot19_v3.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v3.txt'), LOG.join("\n"))
end
CLAD = %w[Material Material1 Material2 Material3 Material9 Brick_05_1K].freeze
FZ0 = 265.2; FZ1 = 272.5; FP = 0.75
TOWER = [1517.0, 1679.0, 0.0, 1463.0].freeze

def walk(ents, tr, inh, &blk)
  ents.each do |e|
    if e.is_a?(Sketchup::Face)
      blk.call(e, tr, e.material || inh)
    elsif e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      next if e.hidden? || !e.layer.visible?
      next if e.definition.name =~ /Sree|\.dwg/i
      next if e.respond_to?(:name) && e.name =~ /^(Roof|Gutter|Frieze|Terrain)/
      walk(e.definition.entities, tr * e.transformation, e.material || inh, &blk)
    end
  end
end
def exterior?(m, p, n)
  [0.5, 6.0].all? do |off|
    hit = m.raytest([p.offset(n, off), n], true)
    hit.nil? || hit[0].distance(p) > 150
  end
end
def section(pts, z)
  ip = []
  pts.each_with_index do |a, i|
    b = pts[(i + 1) % pts.length]
    next if (a.z - z) * (b.z - z) > 0 || (a.z - b.z).abs < 1e-6
    t = (z - a.z) / (b.z - a.z)
    ip << Geom::Point3d.new(a.x + t * (b.x - a.x), a.y + t * (b.y - a.y), z)
  end
  return nil if ip.length < 2
  d = ip[1] - ip[0]
  return nil if d.length < 1e-6
  d.normalize!
  s = ip.sort_by { |q| (q - ip[0]).dot(d) }
  [s.first, s.last]
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  white = m.materials.add('Trim - Arctic White'); white.color = Sketchup::Color.new(241, 242, 237)
  soffit = m.materials.add('Soffit - Arctic White'); soffit.color = Sketchup::Color.new(241, 242, 237)
  lawn = m.materials.add('Terrain - Lawn'); lawn.color = Sketchup::Color.new(104, 124, 72)
  soil = m.materials.add('Terrain - Ground Section'); soil.color = Sketchup::Color.new(78, 84, 62)

  # ---- scan exterior cladding faces: frieze segments and grade samples ----
  frieze = []; samples = []
  walk(m.entities, Geom::Transformation.new, nil) do |f, tr, mat|
    next unless mat && CLAD.include?(mat.name)
    n = f.normal.transform(tr); n.z = 0
    next if n.length < 0.99
    n.normalize!
    pts = f.outer_loop.vertices.map { |x| x.position.transform(tr) }
    zs = pts.map(&:z)
    # frieze
    if zs.min < FZ0 + 0.1 && zs.max > FZ1 - 0.1
      seg = section(pts, (FZ0 + FZ1) / 2)
      if seg && seg[0].distance(seg[1]) > 4
        mid = Geom.linear_combination(0.5, seg[0], 0.5, seg[1])
        in_tower = mid.x > TOWER[0] && mid.x < TOWER[1] && mid.y < TOWER[3]
        # several probes along the wall: a window frame in front of one probe must not hide an exterior wall
        clear = (1..7).any? { |k| exterior?(m, Geom.linear_combination(k / 8.0, seg[0], 1 - k / 8.0, seg[1]), n) }
        frieze << [seg, n] if !in_tower && clear
      end
    end
    # grade samples: the two lowest vertices of low exterior faces
    if zs.min < 45
      low = pts.sort_by(&:z).first(2)
      mid = Geom.linear_combination(0.5, low[0], 0.5, low[1])
      probe = Geom::Point3d.new(mid.x, mid.y, mid.z + 6)
      if exterior?(m, probe, n)
        low.each { |q| samples << [q.x + n.x * 1.0, q.y + n.y * 1.0, q.z] }
      end
    end
  end
  samples.uniq! { |s| s.map { |a| (a / 3.0).round } }
  samples.reject! { |s| s[2] > 20.0 }                # porch / step sides are not grade
  log "frieze segments: #{frieze.length}; grade samples: #{samples.length}, z #{samples.map { |s| s[2] }.min.round(1)}..#{samples.map { |s| s[2] }.max.round(1)}"

  m.start_operation('JESB Lot 19 v3', true)
  # ---- 1. soffits ----
  ns = 0
  m.entities.grep(Sketchup::Group).select { |g| g.name =~ /^Roof - / }.each do |g|
    g.entities.grep(Sketchup::Face).each do |f|
      next unless f.normal.z < -0.99
      f.material = soffit; f.back_material = soffit; ns += 1
    end
  end
  log "soffit faces painted: #{ns}"

  # ---- 2. frieze board ----
  fg = m.entities.add_group
  fg.name = 'Frieze Board - Arctic White 5/4x8 (v3)'
  len = 0.0
  frieze.each do |(a, b), n|
    u = b - a; u.normalize!
    a2 = a.offset(u, -FP); b2 = b.offset(u, FP)
    q = [a2, b2, b2.offset(n, FP), a2.offset(n, FP)].map { |p| Geom::Point3d.new(p.x, p.y, FZ0) }
    sg = fg.entities.add_group
    f = sg.entities.add_face(q)
    f.reverse! if f.normal.z < 0
    f.pushpull(FZ1 - FZ0)
    sg.entities.grep(Sketchup::Face).each { |x| x.material = white; x.back_material = white }
    len += a.distance(b)
  end
  log format('frieze board: %d pieces, %.0f ft', frieze.length, len / 12.0)

  # ---- 3. terrain ----
  hb = Geom::BoundingBox.new
  m.entities.each { |e| hb.add(e.bounds) if (e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)) && !e.hidden? && e.definition.name !~ /Sree|\.dwg/i }
  step = 24.0
  x0 = ((hb.min.x - 420) / step).floor * step; x1 = ((hb.max.x + 420) / step).ceil * step
  y0 = ((hb.min.y - 420) / step).floor * step; y1 = ((hb.max.y + 420) / step).ceil * step
  grade = lambda do |x, y|
    sw = 0.0; sz = 0.0
    samples.each do |sx, sy, sz0|
      d2 = (x - sx)**2 + (y - sy)**2
      return sz0 if d2 < 1.0
      w = 1.0 / (d2 * d2)
      sw += w; sz += w * sz0
    end
    sz / sw
  end
  nx = ((x1 - x0) / step).round; ny = ((y1 - y0) / step).round
  # flatwork (driveway, walks: top-level groups lying at grade) must stay above the lawn
  flat = m.entities.grep(Sketchup::Group).select { |g| b = g.bounds; b.max.z < 6 && b.min.z < 1 && g.name !~ /Terrain/ }.map(&:bounds)
  log "flatwork kept above the lawn: #{flat.map { |b| format('x %.0f..%.0f y %.0f..%.0f top %.1f', b.min.x, b.max.x, b.min.y, b.max.y, b.max.z) }}"
  zgrid = Array.new(nx + 1) do |i|
    Array.new(ny + 1) do |j|
      x = x0 + i * step; y = y0 + j * step
      z = grade.call(x, y) - 2.5                       # walls stand on a 2.5 in. foundation reveal
      flat.each { |b| z = [z, b.max.z - 1.5].min if x > b.min.x - 30 && x < b.max.x + 30 && y > b.min.y - 30 && y < b.max.y + 30 }
      z
    end
  end
  tg = m.entities.add_group
  tg.name = 'Terrain (grade from wall bottoms, v3)'
  mesh = Geom::PolygonMesh.new((nx + 1) * (ny + 1), nx * ny * 2)
  idx = {}
  (0..nx).each { |i| (0..ny).each { |j| idx[[i, j]] = mesh.add_point(Geom::Point3d.new(x0 + i * step, y0 + j * step, zgrid[i][j])) } }
  nx.times do |i|
    ny.times do |j|
      mesh.add_polygon(idx[[i, j]], idx[[i + 1, j]], idx[[i + 1, j + 1]])
      mesh.add_polygon(idx[[i, j]], idx[[i + 1, j + 1]], idx[[i, j + 1]])
    end
  end
  tg.entities.add_faces_from_mesh(mesh, Geom::PolygonMesh::AUTO_SOFTEN | Geom::PolygonMesh::SMOOTH_SOFT_EDGES, lawn, lawn)
  tg.entities.grep(Sketchup::Face).each { |f| f.reverse! if f.normal.z < 0; f.material = lawn; f.back_material = lawn }
  # skirt down to z -150 so the ground reads as a mass in elevations
  zb = -150.0
  border = (0..nx).map { |i| [i, 0] } + (1..ny).map { |j| [nx, j] } + (nx - 1).downto(0).map { |i| [i, ny] } + (ny - 1).downto(1).map { |j| [0, j] }
  border.each_with_index do |(i, j), k|
    i2, j2 = border[(k + 1) % border.length]
    p = Geom::Point3d.new(x0 + i * step, y0 + j * step, zgrid[i][j]); q = Geom::Point3d.new(x0 + i2 * step, y0 + j2 * step, zgrid[i2][j2])
    f = tg.entities.add_face(p, q, Geom::Point3d.new(q.x, q.y, zb), Geom::Point3d.new(p.x, p.y, zb))
    f.material = soil; f.back_material = soil
  end
  # vertical joints between skirt panels would read as a fence in elevations: hide them
  tg.entities.grep(Sketchup::Edge).each { |ed| ed.hidden = true if ed.faces.length == 2 && ed.faces.all? { |x| x.material == soil } && (ed.start.position.x - ed.end.position.x).abs < 1e-6 && (ed.start.position.y - ed.end.position.y).abs < 1e-6 }
  bot = tg.entities.add_face([x0, y0, zb], [x1, y0, zb], [x1, y1, zb], [x0, y1, zb])
  bot.material = soil; bot.back_material = soil
  zs = zgrid.flatten
  log format('terrain: x %.0f..%.0f y %.0f..%.0f, %dx%d cells of %d in., grade z %.1f..%.1f, skirt to %.0f', x0, x1, y0, y1, nx, ny, step, zs.min, zs.max, zb)

  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  [['chk_front.png', [1350, 500, 380], [1450, 1350, 230]], ['chk_frieze.png', [1050, 900, 300], [1300, 1250, 260]], ['chk_site.png', [700, 300, 900], [1500, 1450, 50]], ['chk_rear.png', [2300, 2700, 500], [1550, 1650, 100]]].each do |n, eye, tg2|
    cam = Sketchup::Camera.new(eye, tg2, [0, 0, 1]); cam.perspective = true; v.camera = cam
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
