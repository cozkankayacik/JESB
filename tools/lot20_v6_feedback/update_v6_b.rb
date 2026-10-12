# JESB Lot 20 v6 - follow-up (2026-10-12), saved into the v6 file:
#   a. black panel between the two windows of each pair on the upper wall above the garage;
#   b. rear black Hardie panel in one piece (centre joint removed);
#   c. downspouts.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v6.skp')
BLACK = 'Hardie Panel - Black'
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v6b.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
def wbb(e, tr)
  bb = Geom::BoundingBox.new
  e.vertices.each { |v| bb.add(v.position.transform(tr)) }
  bb
end

# ---------- a. black strip between the paired windows ----------
def pair_strips(m, house, ht)
  black = m.materials[BLACK]
  wall = m.find_entity_by_persistent_id(127795)
  tr = ht * wall.transformation; inv = tr.inverse
  we = wall.entities
  front = we.grep(Sketchup::Face).select { |f| near(f.normal.y, -1, 0.001) && f.loops.length == 5 }.max_by(&:area)
  raise 'upper wall front face with four openings not found' unless front
  yf = front.vertices.first.position.transform(tr).y
  holes = front.loops.reject(&:outer?).map { |l| wbb(l, tr) }.sort_by { |b| b.min.x }
  [[holes[0], holes[1]], [holes[2], holes[3]]].each do |a, b|
    xa = a.max.x; xb = b.min.x; z0 = a.min.z; z1 = a.max.z
    [z0, z1].each { |z| we.add_line(Geom::Point3d.new(xa, yf, z).transform(inv), Geom::Point3d.new(xb, yf, z).transform(inv)) }
    strip = we.grep(Sketchup::Face).find do |f|
      next false unless near(f.normal.y, -1, 0.001)
      bb = wbb(f, tr)
      near(bb.min.x, xa) && near(bb.max.x, xb) && near(bb.min.z, z0) && near(bb.max.z, z1) && near(bb.min.y, yf)
    end
    raise format('strip between the windows at x %.1f..%.1f was not created', xa, xb) unless strip
    strip.material = black
    log format('  black panel between windows: x %.2f..%.2f (%.1f in wide)  z %.2f..%.2f', xa, xb, xb - xa, z0, z1)
  end
end

# ---------- b. black panels without joints ----------
def black_one_piece(m, house, ht)
  removed = 0
  house.entities.grep(Sketchup::Group).each do |g|
    loop do
      dead = g.entities.grep(Sketchup::Edge).select do |e|
        e.faces.length == 2 && e.faces.all? { |f| f.material && f.material.name == BLACK } && e.faces[0].normal.samedirection?(e.faces[1].normal)
      end
      break if dead.empty?
      removed += dead.length
      g.entities.erase_entities(dead)
    end
  end
  log "  joint edges removed from the black panels: #{removed}"
  house.entities.grep(Sketchup::Group).each do |g|
    tr = ht * g.transformation
    g.entities.grep(Sketchup::Face).each do |f|
      next unless f.material && f.material.name == BLACK
      b = wbb(f, tr); n = f.normal.transform(tr)
      side = n.y > 0.9 ? 'rear ' : (n.y < -0.9 ? 'front' : 'side ')
      log format('    %s black panel x %.1f..%.1f z %.1f..%.1f  (%.1f x %.1f in)', side, b.min.x, b.max.x, b.min.z, b.max.z, [b.width, b.height].max, b.depth)
    end
  end
end

# ---------- c. downspouts ----------
DS_A = 4.0      # along the wall
DS_B = 3.0      # out from the wall
# [label, point on the wall face (x, y), outward normal, eave line coordinate along the normal, level (:main / :garage), bottom z]
SPOUTS = [
  ['right side, front corner', [13199.83, 3832.0], [1, 0], 13218.8, :main, 0.0],
  ['rear, right corner', [13174.0, 4225.8], [0, 1], 4250.0, :main, 0.0],
  ['rear, left corner (onto the deck)', [12518.0, 4255.07], [0, 1], 4274.0, :main, 15.3],
  ['left side, rear corner of the left wing', [12344.76, 4028.0], [-1, 0], 12320.8, :main, 0.0],
  ['front, inside corner next to the garage', [12664.5, 3818.07], [0, -1], 3782.0, :main, 0.0],
  ['garage, left side, front corner', [12344.76, 3427.0], [-1, 0], 12320.8, :garage, 0.0],
  ['garage front, right corner', [12604.0, 3417.07], [0, -1], 3398.0, :garage, 0.0]
].freeze

def prism(ents, p_top, p_bot, wdir, ndir, mat)
  c = lambda do |p, sw, sn|
    Geom::Point3d.new(p.x + wdir.x * sw * DS_A / 2 + ndir.x * sn * DS_B / 2, p.y + wdir.y * sw * DS_A / 2 + ndir.y * sn * DS_B / 2, p.z)
  end
  t = [c.call(p_top, -1, -1), c.call(p_top, 1, -1), c.call(p_top, 1, 1), c.call(p_top, -1, 1)]
  b = [c.call(p_bot, -1, -1), c.call(p_bot, 1, -1), c.call(p_bot, 1, 1), c.call(p_bot, -1, 1)]
  fs = [ents.add_face(t), ents.add_face(b)]
  4.times { |i| fs << ents.add_face(t[i], t[(i + 1) % 4], b[(i + 1) % 4], b[i]) }
  fs.each { |f| f.material = mat; f.back_material = mat }
end

def downspouts(m, house, ht)
  hinv = ht.inverse
  mat = m.materials['Gutter - Black'] or raise 'gutter material not found'
  grp = house.entities.add_group
  grp.name = 'Downspouts - Black (v6)'
  SPOUTS.each do |label, (wx, wy), (nx, ny), eave, level, zbot|
    n = Geom::Vector3d.new(nx, ny, 0); w = Geom::Vector3d.new(-ny, nx, 0)
    gut_bottom = level == :main ? 259.6 : 137.8
    z_wall = gut_bottom - 21.0
    out = nx != 0 ? (eave - wx) * nx : (eave - wy) * ny                 # wall face to eave line
    raise "#{label}: eave is not outside the wall (#{out})" unless out > 5
    wall_pt = Geom::Point3d.new(wx + nx * DS_B / 2, wy + ny * DS_B / 2, z_wall)
    gut_pt = Geom::Point3d.new(wx + nx * (out + 2.5), wy + ny * (out + 2.5), gut_bottom)
    sg = grp.entities.add_group
    to_l = lambda { |p| p.transform(hinv) }
    prism(sg.entities, to_l.call(gut_pt), to_l.call(wall_pt), w, n, mat)                                        # offset from the gutter to the wall
    prism(sg.entities, to_l.call(wall_pt), to_l.call(Geom::Point3d.new(wall_pt.x, wall_pt.y, zbot)), w, n, mat)  # leader down the wall
    log format('  downspout %-42s wall point (%.1f, %.1f), eave %.1f in out, z %.1f..%.1f', label, wx, wy, out, zbot, gut_bottom)
  end
  log "  #{SPOUTS.length} downspouts, #{DS_B.to_i} x #{DS_A.to_i} in, black"
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  ht = house.transformation
  raise 'not a v6 model' unless house.entities.grep(Sketchup::Group).any? { |g| g.name == 'Gutters - Black (v6)' }
  m.start_operation('JESB Lot 20 v6 follow-up', true)
  log 'a. upper wall above the garage'; pair_strips(m, house, ht)
  log 'b. black panels'; black_one_piece(m, house, ht)
  log 'c. downspouts'; downspouts(m, house, ht)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  b = house.bounds
  cx, cy, cz = 12776.80, 3838.76, 187.33          # same framing as the earlier v6 exports (gutters widened the bounds slightly)
  d = 3000.0
  hgt = 813.694
  shot(v, 'JESB_Lot20_v6_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_upper_wall.png', [12500, 3150, 330], [12500, 3800, 225], true)
  shot(v, 'chk_ds_front.png', [12900, 3350, 200], [12640, 3800, 140], true)
  shot(v, 'chk_ds_rear_right.png', [13500, 4600, 200], [13190, 4230, 150], true)
  v.camera = saved_cam
  log format('house bounds x %.2f..%.2f y %.2f..%.2f', b.min.x, b.max.x, b.min.y, b.max.y)
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
