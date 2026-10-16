# JESB Lot 19 - model v5 (from v4): entry tower above the canopy per xelev_lot19.dwg (front elevation).
# The DWG shows the stone piers of the tower running straight to the grey window surround. In the model the piers
# stopped 13 in. short, leaving a recessed stone strip and dark slot on each side. Above the canopy (z >= 194.18) the
# pier front faces are extended to the window surround (left x 1545.17 -> 1558.40, right x 1650.67 -> 1637.56).
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot19_v5.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v5.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.02) (a - b).abs < t end
ZB = 194.18                     # top of the entry canopy
def extend(m, pid, x_side, x_new, y_front, y_back, z_top)
  g = m.find_entity_by_persistent_id(pid) or raise "pier group #{pid} not found"
  tr = g.transformation; inv = tr.inverse; e = g.entities
  front = e.grep(Sketchup::Face).find { |f| f.normal.transform(tr).y < -0.99 && f.vertices.all? { |v| near(v.position.transform(tr).y, y_front) } }
  raise "front face of #{pid} not found" unless front
  mat = front.material
  pt = lambda { |x, y, z| Geom::Point3d.new(x, y, z).transform(inv) }
  faces = [
    [[x_side, y_front, ZB], [x_new, y_front, ZB], [x_new, y_front, z_top], [x_side, y_front, z_top]],   # front
    [[x_new, y_front, ZB], [x_new, y_back, ZB], [x_new, y_back, z_top], [x_new, y_front, z_top]],       # new side
    [[x_side, y_front, ZB], [x_side, y_back, ZB], [x_new, y_back, ZB], [x_new, y_front, ZB]],           # bottom
    [[x_side, y_front, z_top], [x_new, y_front, z_top], [x_new, y_back, z_top], [x_side, y_back, z_top]] # top
  ]
  faces.each { |q| f = e.add_face(q.map { |p| pt.call(*p) }); f.material = mat; f.back_material = mat }
  # upper part of the old inner side face is now inside the pier
  inner = e.grep(Sketchup::Face).select do |f|
    ps = f.vertices.map { |v| v.position.transform(tr) }
    f.normal.transform(tr).x.abs > 0.99 && ps.all? { |p| near(p.x, x_side) && p.z > ZB - 0.02 && p.y > y_front - 0.02 && p.y < y_back + 0.02 }
  end
  e.erase_entities(inner)
  # orient outward
  e.grep(Sketchup::Face).each do |f|
    c = Geom::BoundingBox.new; f.vertices.each { |v| c.add(v.position.transform(tr)) }
    next unless c.min.z > ZB - 0.05 && ((c.min.x - [x_side, x_new].min) > -0.05) && ((c.max.x - [x_side, x_new].max) < 0.05)
    n = f.normal.transform(tr)
    out = c.center - Geom::Point3d.new((x_side + x_new) / 2.0, (y_front + y_back) / 2.0, (ZB + z_top) / 2.0)
    f.reverse! if n.dot(out) < 0
  end
  # merge coplanar faces of the same material (front with front, top with top)
  loop do
    dead = e.grep(Sketchup::Edge).select { |ed| ed.faces.length == 2 && ed.faces[0].normal.parallel?(ed.faces[1].normal) && ed.faces[0].vertices.first.position.distance_to_plane(ed.faces[1].plane) < 0.01 && ed.faces[0].material == ed.faces[1].material }
    break if dead.empty?
    e.erase_entities(dead)
  end
  # any seam left on the front plane at the old pier edge is hidden, and the texture is re-projected from the old face
  seams = e.grep(Sketchup::Edge).select { |ed| ps = ed.vertices.map { |v| v.position.transform(tr) }; ps.all? { |p| near(p.x, x_side) && near(p.y, y_front) } }
  seams.each { |ed| ed.hidden = true }
  old = e.grep(Sketchup::Face).select { |f| f.normal.transform(tr).y < -0.99 && f.vertices.all? { |v| near(v.position.transform(tr).y, y_front) } }
  ref = old.max_by(&:area)
  uvh = ref.get_UVHelper(true, false)
  p0 = ref.vertices[0].position; p1 = ref.vertices[1].position; p2 = ref.vertices[2].position
  pts = [p0, uvh.get_front_UVQ(p0), p1, uvh.get_front_UVQ(p1), p2, uvh.get_front_UVQ(p2)].each_slice(2).flat_map { |p, q| [p, Geom::Point3d.new(q.x / q.z, q.y / q.z, 0)] }
  old.each { |f| f.position_material(mat, pts, true) unless f == ref }
  log "    seam edges hidden: #{seams.length}, front faces: #{old.length}"
  log format('  pier %d: front face now reaches x %.2f above z %.2f (%d inner faces removed), y %.2f..%.2f', pid, x_new, ZB, inner.length, y_front, y_back)
end
def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  m.start_operation('JESB Lot 19 v5 tower piers', true)
  extend(m, 333607, 1545.17, 1558.40, 1394.60, 1412.91, 298.12)
  extend(m, 334788, 1650.67, 1637.56, 1398.86, 1412.89, 298.12)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /Sree/i }
  cx = 1495.0; cy = 1475.0; cz = 190.0
  cam = Sketchup::Camera.new([cx, cy - 5000, cz], [cx, cy, cz], [0, 0, 1]); cam.perspective = false; cam.height = 500.0; v.camera = cam
  v.write_image(filename: File.join(OUT, 'm_south.png'), width: 2400, height: 1000, antialias: true, transparent: false)
  [['chk_tower.png', [1650, 1050, 230], [1598, 1410, 225]], ['chk_tower_side.png', [1820, 1180, 300], [1600, 1410, 230]]].each do |n, eye, tg|
    cam = Sketchup::Camera.new(eye, tg, [0, 0, 1]); cam.perspective = true; v.camera = cam
    v.write_image(filename: File.join(OUT, n), width: 2400, height: 1500, antialias: true, transparent: false)
  end
  v.camera = saved_cam
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
