# JESB Lot 20 - model v7: the four windows on the wall above the garage placed symmetrically, per the revised
# second floor plan in "Lot-20 base rend.dwg" (saved 2026-10-12) / "Lot-20 second floor_r1.pdf".
# DWG plan, from the wall's left corner: 29" | 32" window | 14.5" | 32" window | 98.5" | 32" | 14.5" | 32" | 29"  (= 313.5")
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v7.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v7.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
CORNER = 12344.80                       # DWG framing corner of the wall (second floor plan x -3728.84)
OLD = [12374.26, 12410.26, 12552.26, 12588.26].freeze
NEW = [29.0, 75.5, 206.0, 252.5].map { |d| CORNER + d }.freeze
W = 32.0
Z0 = 218.33
Z1 = 248.33

def openings(we, tr)
  # the reveal sill faces give the openings as built
  we.grep(Sketchup::Face).select { |f| near(f.normal.z.abs, 1, 0.001) && f.vertices.all? { |x| near(x.position.transform(tr).z, Z0, 0.02) } }.map { |f| xs = f.vertices.map { |x| x.position.transform(tr).x }; [xs.min, xs.max] }.sort
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  wall = m.find_entity_by_persistent_id(127795)
  raise 'house or wall group not found' unless house && wall
  ht = house.transformation
  tr = ht * wall.transformation
  we = wall.entities
  before = openings(we, tr)
  raise "expected 4 openings, found #{before.length}" unless before.length == 4
  raise 'openings are not at the v6 positions' unless before.each_with_index.all? { |h, i| near(h[0], OLD[i], 0.05) }
  # the black strips join the two openings of a pair, so the wall face has two inner loops
  front = we.grep(Sketchup::Face).select { |f| near(f.normal.y, -1, 0.001) && f.loops.length == 3 && f.area > 20_000 }.max_by(&:area)
  raise 'upper wall front face not found' unless front
  yf = front.vertices.first.position.transform(tr).y
  m.start_operation('JESB Lot 20 v7 symmetric windows', true)
  # jamb vertices of the four openings (front edge and reveal back edge) move with their window
  vs = []; vecs = []
  we.grep(Sketchup::Edge).flat_map(&:vertices).uniq.each do |vx|
    p = vx.position.transform(tr)
    next unless p.y > yf - 0.05 && p.y < yf + 7.3 && p.z > Z0 - 0.05 && p.z < Z1 + 0.05
    OLD.each_with_index do |ox, i|
      next unless near(p.x, ox) || near(p.x, ox + W)
      vs << vx; vecs << Geom::Vector3d.new(NEW[i] - ox, 0, 0)
    end
  end
  we.transform_by_vectors(vs, vecs)
  log "opening vertices moved: #{vs.length} (expected 32)"
  holes = openings(we, tr)
  holes.each_with_index { |h, i| log format('  window %d: x %.2f..%.2f  (%.2f..%.2f in from the wall corner)  z %.2f..%.2f', i + 1, h[0], h[1], h[0] - CORNER, h[1] - CORNER, Z0, Z1) }
  log format('  spacing from the left corner: %.2f | 32 | %.2f | 32 | %.2f | 32 | %.2f | 32 | %.2f', holes[0][0] - CORNER, holes[1][0] - holes[0][1], holes[2][0] - holes[1][1], holes[3][0] - holes[2][1], CORNER + 313.5 - holes[3][1])
  we.grep(Sketchup::Face).each do |f|
    next unless f.material && f.material.name == 'Hardie Panel - Black'
    xs = f.vertices.map { |x| x.position.transform(tr).x }
    next unless xs.max < 12660 && f.vertices.all? { |x| x.position.transform(tr).z > 200 }
    log format('  black panel between windows: x %.2f..%.2f (%.1f in wide)', xs.min, xs.max, xs.max - xs.min)
  end
  bad = we.grep(Sketchup::Face).count { |f| !f.valid? }
  log "wall group invalid faces: #{bad}"
  # window units
  moved = 0
  house.entities.grep(Sketchup::Group).each do |g|
    bb = Geom::BoundingBox.new
    (0..7).each { |i| bb.add(g.bounds.corner(i).transform(ht)) }
    next unless near(bb.min.z, Z0, 0.05) && near(bb.max.z, Z1, 0.05) && near(bb.width, W, 0.05) && bb.min.y > 3798 && bb.max.y < 3804
    i = OLD.index { |ox| near(bb.min.x, ox, 0.05) }
    next unless i
    g.transform!(Geom::Transformation.translation([NEW[i] - OLD[i], 0, 0]))
    moved += 1
  end
  log "window units moved: #{moved} (expected 4)"
  raise 'not everything was found' unless moved == 4 && vs.length == 32 && holes.each_with_index.all? { |h, i| near(h[0], NEW[i], 0.05) && near(h[1], NEW[i] + W, 0.05) }
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  cx, cy, cz = 12776.80, 3838.76, 187.33
  d = 3000.0; hgt = 813.694
  shot(v, 'JESB_Lot20_v7_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v7_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v7_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v7_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v7_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_upper_wall.png', [12500, 3150, 330], [12500, 3800, 225], true)
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
