# JESB Lot 20 - export the standard views from the current model (read-only: the model is not saved).
OUT = File.dirname(__FILE__)
PREFIX = 'JESB_Lot20_v3'
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result.txt'), LOG.join("\n"))
end
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
  c0 = v.camera
  log "path #{m.path}"
  log "saved camera eye=#{c0.eye.to_a.map { |a| a.round(1) }} target=#{c0.target.to_a.map { |a| a.round(1) }} persp=#{c0.perspective?}"
  log "scenes: #{m.pages.map(&:name).join(', ')}"
  log 'top-level: ' + m.entities.group_by(&:typename).map { |k, a| "#{k}=#{a.length}" }.join(' ')
  m.entities.each do |e|
    next unless e.respond_to?(:bounds)
    b = e.bounds
    nm = e.respond_to?(:name) ? e.name : ''
    dn = e.respond_to?(:definition) ? e.definition.name : ''
    log format('  top %s pid=%d name=%s def=%s hidden=%s x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', e.typename, e.persistent_id, nm, dn, e.hidden?, b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) if e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
  end
  house = m.find_entity_by_persistent_id(198219)
  raise 'house group not found' unless house
  ht = house.transformation
  log "house children: #{house.entities.length}"
  house.entities.each do |e|
    next unless (e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)) && (e.name.to_s =~ /Roof|Sill/ || e.persistent_id > 198219)
    b = e.bounds
    log format('  child pid=%d name=%s x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', e.persistent_id, e.name, b.min.x + ht.origin.x, b.max.x + ht.origin.x, b.min.y + ht.origin.y, b.max.y + ht.origin.y, b.min.z + ht.origin.z, b.max.z + ht.origin.z)
  end
  b = house.bounds
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  hgt = [b.width, b.height].max * 0.80
  log format('house bounds x %.2f..%.2f y %.2f..%.2f z %.2f..%.2f  cam height %.2f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z, hgt)
  d = 3000.0
  v.write_image(filename: File.join(OUT, 'saved_view.png'), width: 2400, height: 1500, antialias: true, transparent: false)
  shot(v, "#{PREFIX}_Elevation_Front.png", [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, "#{PREFIX}_Elevation_Rear.png", [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, "#{PREFIX}_Elevation_Left.png", [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, "#{PREFIX}_Elevation_Right.png", [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, "#{PREFIX}_Perspective.png", [cx - 300, cy - 1500, 170], [cx - 40, cy, 150], true)
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
    UI.start_timer(8, false) { run }
  elsif tries > 100
    UI.stop_timer(tid)
    File.write(File.join(OUT, 'done.txt'), 'ERR no model loaded')
  end
end
