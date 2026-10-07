# JESB Lot 2 - v3 -> v4
#   A. Terrain surface built from the grade lines on the four elevations (sheets 1, 1.1, 1.2).
#   B. Visible foundation limits at the entry brought down to grade (tower base, entry piers, steps, walk).
#   C. Wall above the entry canopy clad in brick.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot2_v4.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result4.txt'), LOG.join("\n"))
end

def lerp(a, b, t) a + (b - a) * [[t, 0.0].max, 1.0].min end

# piecewise-linear lookup through [[x, v], ...]
def pl(pts, x)
  return pts.first[1] if x <= pts.first[0]
  return pts.last[1] if x >= pts.last[0]
  pts.each_cons(2) { |(x0, v0), (x1, v1)| return v0 + (v1 - v0) * (x - x0) / (x1 - x0) if x <= x1 }
end

XW = 2755.44; XE = 3690.38
G_FRONT = -16.2    # grade at entry / right bay, front elevation (DWG y 229.94)
G_WEST = -3.3      # driveway side, left elevation (DWG y 243.14 = -3.0; kept just under the slab top)
G_WALK = -71.95    # walk-out level, right and rear elevations (DWG y 174.19)
G_PATIO = 8.8      # patio level, rear and left elevations (DWG y 254.94)

# front wall line and grade at the wall, per x (front elevation)
def front_wall_y(x)
  if x < 3019.0 then 6537.22
  elsif x < 3135.38 then 6488.18
  elsif x < 3338.38 then 6442.68
  elsif x < 3350.0 then 6436.67
  elsif x < 3432.38 then 6386.74
  elsif x < 3446.38 then 6436.67
  elsif x < 3529.38 then 6470.67
  else 6431.17 end
end
W_FRONT = [[XW, -3.0], [2891.7, 0.0], [3019.0, 0.0], [3022.88, -2.0], [3131.0, -2.0], [3135.38, -4.0], [3338.38, -4.0], [3350.0, -10.0], [3356.0, G_FRONT], [XE - 30, G_FRONT], [XE, -17.91]].freeze
F_FAR = [[XW, -19.7], [3350.0, G_FRONT]].freeze           # front yard beyond the house (left elevation -19.7, front elevation -16.2)
Y_FAR = [[XW, 6436.67], [3022.88, 6386.74]].freeze        # where the front yard levels out
R_REAR = [[XW, G_WEST], [2944.38, G_PATIO], [3135.38, G_PATIO], [3350.0, G_WALK]].freeze  # rear elevation profile
E_SIDE = [[6431.17, -17.91], [6733.17, G_WALK]].freeze    # right elevation profile

def rear_wall_y(x)
  if x < 3135.38 then 7027.17
  elsif x < 3350.0 then 7139.8
  elsif x < 3613.59 then 6992.17
  else 6733.17 end
end

def inside_house?(x, y)
  x > XW && x < XE && y > front_wall_y(x) && y < rear_wall_y(x)
end

def grade(x, y)
  if x >= XE - 0.01 && y >= 6431.17
    return pl(E_SIDE, y)
  end
  if x <= XW + 0.01
    return G_WEST if y >= 6537.22
    return lerp(G_WEST, -19.7, (6537.22 - y) / (6537.22 - 6436.67))
  end
  xc = [[x, XW].max, XE].min
  return pl(R_REAR, xc) if y >= rear_wall_y(xc) - 0.01 && y > 6700
  yw = front_wall_y(xc)
  w = pl(W_FRONT, xc)
  w = lerp(-17.91, G_FRONT, (6431.17 - y) / 44.43) if x > XE
  return w if y >= yw
  yf = pl(Y_FAR, xc)
  f = pl(F_FAR, xc)
  return f if y <= yf || yw <= yf
  lerp(w, f, (yw - y) / (yw - yf))
end

def box(ents, x0, x1, y0, y1, z0, z1, mat)
  g = ents.add_group
  f = g.entities.add_face([x0, y0, z0], [x1, y0, z0], [x1, y1, z0], [x0, y1, z0])
  f.reverse! if f.normal.z < 0
  f.pushpull(z1 - z0)
  bb = g.bounds
  raise "box built wrong: z #{bb.min.z}..#{bb.max.z}, wanted #{z0}..#{z1}" if (bb.min.z - z0).abs > 0.01 || (bb.max.z - z1).abs > 0.01
  g.entities.grep(Sketchup::Face).each { |fc| fc.material = mat } if mat
  g
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
  brick = m.materials['Material1']
  stone = m.materials['Material']
  entry_wall = m.find_entity_by_persistent_id(191755)
  raise 'entry wall not found' unless entry_wall && brick && stone

  m.start_operation('JESB Lot 2 v4', true)

  # ---------- C. brick above the entry ----------
  n = 0
  entry_wall.entities.grep(Sketchup::Face).each { |f| f.material = brick; n += 1 }
  log "entry wall above canopy: #{n} faces set to brick ('#{brick.name}', #{File.basename(brick.texture.filename)})"

  # ---------- B. foundation limits at the entry ----------
  zb = -30.0
  g = box(m.entities, 3433.38, 3529.38, 6470.67, 6495.67, zb, 0.0, nil)
  g.name = 'Foundation - Entry Tower (exposed concrete to grade)'
  g = box(m.entities, 3338.38, 3356.38, 6436.67, 6495.67, zb, 0.0, stone)
  g.name = 'Entry Pier Base - West (stone to grade)'
  g = box(m.entities, 3428.38, 3446.38, 6436.67, 6495.67, zb, 0.0, stone)
  g.name = 'Entry Pier Base - East (stone to grade)'
  g = box(m.entities, 3350.38, 3432.38, 6396.74, 6491.46, -7.75, 0.0, nil)
  g.name = 'Entry Steps - added riser 1'
  g = box(m.entities, 3350.38, 3432.38, 6386.74, 6491.46, zb, -7.75, nil)
  g.name = 'Entry Steps - added riser 2'
  walk = m.entities.grep(Sketchup::Face).find { |f| f.bounds.min.y < 6200 && f.bounds.max.z.abs < 0.01 && f.bounds.min.x > 3300 && f.bounds.max.x < 3500 }
  if walk
    vs = walk.vertices
    m.entities.transform_by_vectors(vs, vs.map { |vx| Geom::Vector3d.new(0, (vx.position.y > 6400 ? 6386.74 - vx.position.y : 0), G_FRONT + 0.2) })
    log "front walk lowered to z #{G_FRONT + 0.2} and trimmed to the new bottom step (y 6386.74)"
  else
    log 'front walk face not found'
  end
  log 'entry: tower foundation, pier bases and two added risers down to grade -16.2'

  # ---------- A. terrain ----------
  xs = [2330.0, XW, 2891.7, 2944.38, 3019.0, 3022.88, 3131.0, 3135.38, 3338.38, 3350.0, 3356.0, 3432.38, 3446.38, 3529.38, 3613.59, XE - 30, XE, 4010.0]
  ys = [6140.0, 6386.74, 6431.17, 6436.67, 6442.68, 6470.67, 6488.18, 6537.22, 6733.17, 6992.17, 7027.17, 7139.8, 7440.0]
  subdiv = lambda do |a, step|
    out = []
    a.sort.each_cons(2) do |p, q|
      k = ((q - p) / step).ceil
      k.times { |i| out << p + (q - p) * i / k }
    end
    out << a.max
    out
  end
  gx = subdiv.call(xs, 48.0)
  gy = subdiv.call(ys, 48.0)
  mesh = Geom::PolygonMesh.new
  idx = {}
  pt = lambda do |i, j|
    idx[[i, j]] ||= mesh.add_point(Geom::Point3d.new(gx[i], gy[j], grade(gx[i], gy[j])))
  end
  cells = 0
  (gx.length - 1).times do |i|
    (gy.length - 1).times do |j|
      next if inside_house?((gx[i] + gx[i + 1]) / 2.0, (gy[j] + gy[j + 1]) / 2.0)
      a = pt.call(i, j); b = pt.call(i + 1, j); c = pt.call(i + 1, j + 1); d = pt.call(i, j + 1)
      mesh.add_polygon(a, b, c)
      mesh.add_polygon(a, c, d)
      cells += 1
    end
  end
  # perimeter skirt so the ground reads as a solid section in elevation views
  zs = -150.0
  ni = gx.length - 1; nj = gy.length - 1
  ni.times { |i| mesh.add_polygon(pt.call(i, 0), pt.call(i + 1, 0), mesh.add_point([gx[i + 1], gy[0], zs]), mesh.add_point([gx[i], gy[0], zs])); mesh.add_polygon(pt.call(i, nj), pt.call(i + 1, nj), mesh.add_point([gx[i + 1], gy[nj], zs]), mesh.add_point([gx[i], gy[nj], zs])) }
  nj.times { |j| mesh.add_polygon(pt.call(0, j), pt.call(0, j + 1), mesh.add_point([gx[0], gy[j + 1], zs]), mesh.add_point([gx[0], gy[j], zs])); mesh.add_polygon(pt.call(ni, j), pt.call(ni, j + 1), mesh.add_point([gx[ni], gy[j + 1], zs]), mesh.add_point([gx[ni], gy[j], zs])) }
  tmat = m.materials['Terrain_Grade'] || m.materials.add('Terrain_Grade')
  tmat.color = Sketchup::Color.new(176, 184, 156)
  tg = m.entities.add_group
  tg.name = 'Terrain (grade per elevations, Rev 10-5-26)'
  tg.entities.fill_from_mesh(mesh, true, 12, tmat, tmat)
  tg.entities.grep(Sketchup::Face).each { |f| f.reverse! if f.normal.z < -0.01 }
  tg.entities.grep(Sketchup::Edge).each do |ed|
    top = ed.faces.length == 2 && ed.faces.all? { |f| f.normal.z.abs > 0.01 }
    side = ed.faces.length == 2 && ed.faces.all? { |f| f.normal.z.abs < 0.01 }
    ed.soft = top || side
    ed.smooth = top
  end
  b = tg.bounds
  log "terrain: #{cells} cells, #{tg.entities.grep(Sketchup::Face).length} faces, x #{b.min.x.round(1)}..#{b.max.x.round(1)} y #{b.min.y.round(1)}..#{b.max.y.round(1)} z #{b.min.z.round(2)}..#{b.max.z.round(2)}"
  [[XW, 6800, 'west wall'], [2850, 6537.22, 'garage front'], [3240, 6442.68, 'front bay'], [3600, 6431.17, 'right bay front'], [XE, 6431.17, 'SE corner'], [XE, 6582.17, 'east wall mid'], [XE, 6733.17, 'east wall rear'], [3480, 6992.17, 'rear main'], [3350, 7139.8, 'dining NE'], [3135.38, 7139.8, 'dining NW'], [2850, 7027.17, 'garage rear']].each do |x, y, nme|
    log format('  grade at %-16s (%.1f, %.1f) = %.2f', nme, x, y, grade(x, y))
  end

  m.commit_operation
  a = File.read(File.join(OUT, 'v1_camera.txt')).split(',').map(&:to_f)
  orig_cam = Sketchup::Camera.new(a[0, 3], a[3, 3], a[6, 3], a[9] == 1.0, a[10])
  v.camera = orig_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  # ---------- exports ----------
  cx = 3226.0; cy = 6785.0; cz = 140.0; d = 3000.0
  shot(v, 'JESB_Lot2_v4_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v4_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v4_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, 760)
  shot(v, 'JESB_Lot2_v4_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, 760)
  v.camera = orig_cam
  v.write_image(filename: File.join(OUT, 'JESB_Lot2_v4_Perspective.png'), width: 2400, height: 1500, antialias: true, transparent: false)
  shot(v, 'chk4_se.jpg', [4500, 5700, 500], [3400, 6700, 0], true, nil, 2000, 1000)
  shot(v, 'chk4_ne.jpg', [4500, 7900, 500], [3350, 6900, 0], true, nil, 2000, 1000)
  shot(v, 'chk4_nw.jpg', [2100, 7900, 500], [3050, 6950, 0], true, nil, 2000, 1000)
  shot(v, 'chk4_entry.jpg', [3300, 5950, 120], [3440, 6460, 60], true, nil, 2000, 1000)
  shot(v, 'chk4_entry2.jpg', [3700, 6150, 60], [3440, 6450, 10], true, nil, 2000, 1000)
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

