# JESB Lot 20 - model v9: entry door brought flush with the black Hardie panel and the window above it.
# In v8 the black panel sits on the wall face (y 3854.07) and the window frame is flush with it (y 3854.03),
# but the double door sat 1.2 in. further back (frame front y 3855.25), so the panel read as projecting over the door.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot20_v9.skp')
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v9.txt'), LOG.join("\n"))
end
def shot(view, name, eye, target, persp, height = nil, w = 2400, h = 1500)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: w, height: h, antialias: true, transparent: false)
end
def wb(e, ht)
  bb = Geom::BoundingBox.new
  (0..7).each { |i| bb.add(e.bounds.corner(i).transform(ht)) }
  bb
end
def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  ht = house.transformation
  doors = [131211, 131212].map { |pid| m.find_entity_by_persistent_id(pid) }
  win = m.find_entity_by_persistent_id(130012)
  wallg = m.find_entity_by_persistent_id(129973)
  raise 'entry doors, window or wall not found' if (doors + [win, wallg]).any?(&:nil?)
  panel = wallg.entities.grep(Sketchup::Face).find { |f| f.material && f.material.name == 'Hardie Panel - Black' }
  raise 'black entry panel not found' unless panel
  y_panel = panel.vertices.first.position.transform(ht * wallg.transformation).y
  y_win = wb(win, ht).min.y
  # front face of the door leaf (the component bounds also include the handle, which projects 1.2 in.)
  leaf_y = lambda do |d|
    ys = []
    walk = lambda do |ents, tr|
      ents.each do |e|
        if e.is_a?(Sketchup::Face)
          n = e.normal.transform(tr)
          ys << e.vertices.first.position.transform(tr).y if n.y < -0.99 && e.area > 300
        elsif e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
          walk.call(e.definition.entities, tr * e.transformation) unless e.definition.name =~ /Handle/
        end
      end
    end
    walk.call(d.definition.entities, ht * d.transformation)
    ys.min
  end
  y_door = doors.map { |d| leaf_y.call(d) }.min
  log format('before: panel face y %.2f, window frame front y %.2f, door leaf face y %.2f (door %.2f in behind the panel)', y_panel, y_win, y_door, y_door - y_panel)
  m.start_operation('JESB Lot 20 v9 entry door flush', true)
  # 0.05 in. behind the panel plane: the door is 2.5 in. wider than the wall opening, and exactly coplanar its edges
  # would show on the face of the white wall beside the opening
  dy = y_panel + 0.05 - y_door
  doors.each { |d| d.transform!(Geom::Transformation.translation([0, dy, 0])) }
  y_door2 = doors.map { |d| leaf_y.call(d) }.min
  log format('after:  panel face y %.2f, window frame front y %.2f, door leaf face y %.2f (doors moved %.2f in toward the front)', y_panel, y_win, y_door2, -dy)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  cx, cy, cz = 12776.80, 3838.76, 187.33
  d = 3000.0; hgt = 813.694
  shot(v, 'JESB_Lot20_v9_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v9_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v9_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v9_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'JESB_Lot20_v9_Perspective.png', [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  shot(v, 'chk_entry_oblique.png', [12990, 3700, 135], [12885, 3854, 128], true)
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
