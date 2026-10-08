# JESB Lot 20 - model v4: facade revision notes of "Kami Export - Lot-20-ACC response.pdf" (2026-10-08).
# Every stucco / panel area becomes siding boards: fields Arctic White, panels between window rows Black.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v4.skp')
TEX = 'C:/Projects/JESB/LOT20/textures'
TILE = 28.0
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v4.txt'), LOG.join("\n"))
end
# face pid => [colour, note]
WHITE = {
  125173 => 'F1 front - garage bay',
  125205 => 'F1 front - garage bay, left return',
  125199 => 'F1 front - garage bay, right return',
  127288 => 'F3 front - window bay left of the entry',
  132014 => 'F4 front - tall window bay right of the entry',
  132021 => 'F4 front - tall window bay, side return',
  157982 => 'S1 right side - panel bay',
  157989 => 'S1 right side - panel bay, return',
  157985 => 'S1 right side - panel bay, return'
}.freeze
BLACK = {
  127831 => 'F2 front - panel between window rows, bay left of the entry',
  131648 => 'F5 front - panel between window rows, right bay',
  165484 => 'R1 rear - panel between upper windows and lower glazing'
}.freeze

def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end

def world_tr(face, house)
  # faces sit one group below the house group
  g = face.parent.instances.first
  house.transformation * g.transformation
end

def paint(m, house, pid, mat, note)
  f = m.find_entity_by_persistent_id(pid)
  raise "face #{pid} not found (#{note})" unless f.is_a?(Sketchup::Face)
  tr = world_tr(f, house)
  inv = tr.inverse
  n = f.normal.transform(tr)
  raise "face #{pid} is not vertical" if n.z.abs > 0.01
  u = Geom::Vector3d.new(0, 0, 1).cross(n); u.normalize!          # horizontal, along the wall
  pw = f.vertices.first.position.transform(tr)
  p0 = Geom::Point3d.new(pw.x, pw.y, 0)                            # courses start at slab level on every face
  p1 = p0.offset(u, TILE); p2 = p0.offset(Geom::Vector3d.new(0, 0, 1), TILE)
  old = f.material ? f.material.name : '-'
  f.position_material(mat, [p0.transform(inv), [0, 0], p1.transform(inv), [1, 0], p2.transform(inv), [0, 1]], true)
  bb = Geom::BoundingBox.new
  f.vertices.each { |v| bb.add(v.position.transform(tr)) }
  log format('  %-58s pid %d  %s -> %s  x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f  %.1f sq ft', note, pid, old, mat.name, bb.min.x, bb.max.x, bb.min.y, bb.max.y, bb.min.z, bb.max.z, f.area / 144.0)
  f.area / 144.0
end

def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  m.start_operation('JESB Lot 20 v4 siding boards', true)
  white = m.materials.add('Siding Boards - Arctic White')
  white.texture = File.join(TEX, 'siding_boards_arctic_white_7in.jpg'); white.texture.size = [TILE, TILE]
  black = m.materials.add('Siding Boards - Black')
  black.texture = File.join(TEX, 'siding_boards_black_7in.jpg'); black.texture.size = [TILE, TILE]
  log "materials: #{white.name} (#{File.basename(white.texture.filename)}), #{black.name} (#{File.basename(black.texture.filename)})"
  aw = 0.0; ab = 0.0
  log 'Arctic White:'
  WHITE.each { |pid, note| aw += paint(m, house, pid, white, note) }
  log 'Black:'
  BLACK.each { |pid, note| ab += paint(m, house, pid, black, note) }
  log format('totals: arctic white %.1f sq ft, black %.1f sq ft', aw, ab)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  b = house.bounds
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  d = 3000.0
  hgt = [b.width, b.height].max * 0.80
  shot(v, 'JESB_Lot20_v4_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v4_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v4_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v4_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v4_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_front_close.png', [12850, 3300, 140], [12850, 3800, 130], true)
  shot(v, 'chk_garage_close.png', [12476, 3150, 80], [12476, 3410, 70], true)
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
