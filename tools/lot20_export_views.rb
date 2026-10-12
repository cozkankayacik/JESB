# JESB Lot 20 - export the standard views from the current model. Nothing is saved.
# Fixed framing (same for every version since v6): centre (12776.80, 3838.76, 187.33), parallel height 813.694.
# The file prefix is taken from the model file name (work copy must be named like JESB_Lot20_v7*.skp).
OUT = File.dirname(__FILE__)
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
def run
  m = Sketchup.active_model
  v = m.active_view
  prefix = File.basename(m.path)[/JESB_Lot20_v\d+/] or raise 'model name does not start with JESB_Lot20_vN'
  log = ["path #{m.path}", "prefix #{prefix}"]
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  ht = house.transformation
  log << 'top-level: ' + m.entities.group_by(&:typename).map { |k, a| "#{k}=#{a.length}" }.join(' ')
  m.entities.each do |e|
    next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    b = e.bounds
    log << format('  top %s pid=%d name=%s def=%s hidden=%s x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', e.typename[0, 5], e.persistent_id, e.name, e.definition.name, e.hidden?, b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z)
  end
  log << "house children: #{house.entities.length}"
  house.entities.each do |e|
    next unless (e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)) && !e.name.to_s.empty?
    b = e.bounds
    log << format('  child pid=%d name=%s x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', e.persistent_id, e.name, b.min.x + ht.origin.x, b.max.x + ht.origin.x, b.min.y + ht.origin.y, b.max.y + ht.origin.y, b.min.z + ht.origin.z, b.max.z + ht.origin.z)
  end
  used = Hash.new(0.0)
  walk = lambda { |ents| ents.each { |e| if e.is_a?(Sketchup::Face) then used[e.material ? e.material.name : '-'] += e.area / 144.0 elsif e.is_a?(Sketchup::Group) then walk.call(e.entities) end } }
  walk.call(house.entities)
  log << 'house face areas by material (sq ft): ' + used.sort_by { |_, a| -a }.first(18).map { |k, a| "#{k}=#{a.round(0)}" }.join(', ')
  cx, cy, cz = 12776.80, 3838.76, 187.33
  d = 3000.0; hgt = 813.694
  shot(v, "#{prefix}_Elevation_Front.png", [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, "#{prefix}_Elevation_Rear.png", [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, "#{prefix}_Elevation_Left.png", [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, "#{prefix}_Elevation_Right.png", [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, "#{prefix}_Perspective.png", [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
  log << 'exports written; model not saved'
  File.write(File.join(OUT, 'result.txt'), log.join("\n"))
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => ex
  File.write(File.join(OUT, 'result.txt'), "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(6).join("\n")}")
  File.write(File.join(OUT, 'done.txt'), 'ERR')
end
tries = 0
tid = UI.start_timer(3, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid)
    UI.start_timer(8, false) { run }
  elsif tries > 100
    UI.stop_timer(tid)
    File.write(File.join(OUT, 'done.txt'), 'ERR no model loaded')
  end
end
