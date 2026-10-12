# JESB Lot 20 v6 - downspouts repositioned (2026-10-12): every downspout sits 2 in. from the end line of its wall.
# No. 4 moved to the end of the left-wing wall; no. 7 moved from the garage front to the garage's right side wall.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v6.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v6c.txt'), LOG.join("\n"))
end
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
DS_A = 4.0      # along the wall
DS_B = 3.0      # out from the wall
EDGE = 2.0      # clear distance from the wall's end line
# [label, point on the wall face (x, y) = centre of the downspout, outward normal, eave line, level, bottom z]
SPOUTS = [
  ['1 right side, front corner', [13199.83, 3818.57 + EDGE + DS_A / 2], [1, 0], 13218.8, :main, 0.0],
  ['2 rear, right corner', [13188.76 - EDGE - DS_A / 2, 4225.8], [0, 1], 4250.0, :main, 0.0],
  ['3 rear, left corner (onto the deck)', [12506.76 + EDGE + DS_A / 2, 4255.07], [0, 1], 4274.0, :main, 15.3],
  ['4 left side, rear end of the left-wing wall', [12344.76, 4040.07 - EDGE - DS_A / 2], [-1, 0], 12320.8, :main, 0.0],
  ['5 front, inside corner next to the garage', [12658.26 + EDGE + DS_A / 2, 3818.07], [0, -1], 3782.0, :main, 0.0],
  ['6 garage, left side, front corner', [12344.76, 3417.07 + EDGE + DS_A / 2], [-1, 0], 12320.8, :garage, 0.0],
  ['7 garage, right side, front corner', [12613.76, 3417.07 + EDGE + DS_A / 2], [1, 0], 12632.8, :garage, 0.0]
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

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  ht = house.transformation; hinv = ht.inverse
  old = house.entities.grep(Sketchup::Group).select { |g| g.name == 'Downspouts - Black (v6)' }
  raise "expected one downspout group, found #{old.length}" unless old.length == 1
  mat = m.materials['Gutter - Black'] or raise 'gutter material not found'
  m.start_operation('JESB Lot 20 v6 downspout positions', true)
  house.entities.erase_entities(old)
  grp = house.entities.add_group
  grp.name = 'Downspouts - Black (v6)'
  SPOUTS.each do |label, (wx, wy), (nx, ny), eave, level, zbot|
    n = Geom::Vector3d.new(nx, ny, 0); w = Geom::Vector3d.new(-ny, nx, 0)
    gut_bottom = level == :main ? 259.6 : 137.8
    out = nx != 0 ? (eave - wx) * nx : (eave - wy) * ny
    raise "#{label}: eave is not outside the wall (#{out})" unless out > 5
    wall_pt = Geom::Point3d.new(wx + nx * DS_B / 2, wy + ny * DS_B / 2, gut_bottom - 21.0)
    gut_pt = Geom::Point3d.new(wx + nx * (out + 2.5), wy + ny * (out + 2.5), gut_bottom)
    sg = grp.entities.add_group
    prism(sg.entities, gut_pt.transform(hinv), wall_pt.transform(hinv), w, n, mat)
    prism(sg.entities, wall_pt.transform(hinv), Geom::Point3d.new(wall_pt.x, wall_pt.y, zbot).transform(hinv), w, n, mat)
    log format('  %-46s centre on wall (%.2f, %.2f), eave %.1f in out, z %.1f..%.1f', label, wx, wy, out, zbot, gut_bottom)
  end
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  cx, cy, cz = 12776.80, 3838.76, 187.33
  d = 3000.0; hgt = 813.694
  shot(v, 'JESB_Lot20_v6_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v6_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_ds7.png', [12900, 3250, 160], [12620, 3440, 90], true)
  shot(v, 'chk_ds4.png', [12050, 4300, 200], [12345, 4040, 150], true)
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
