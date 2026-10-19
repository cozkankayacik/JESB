# JESB Lot 19 - model v6 (from the owner's v5 of 2026-10-19 10:19): materials only.
# 1. Accent panels between the windows (Material8, pale wood) -> ACC Lot 19 "Siding dec - Light Brown" (ACC MATERIAL
#    PACKAGE.xlsx, EXTERIOR H17/I17, image29: light brown lap siding; 3 boards per 292 px -> 19.3 x 20.2 in.).
#    Material8 stays on the entry door, garage doors and the rear deck.
# 2. Cobble Stone siding (Material9, Material3) a little lighter: textures blended 22 % towards white, same size.
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot19_v6.skp')
PANELS = [352505, 351512, 348235, 334843, 334452, 347116, 346879].freeze   # groups holding the accent panel faces
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v6.txt'), LOG.join("\n"))
end
def b3(b) format('x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) end
def shot(view, name, eye, target, persp, height = nil, w = 2400, h = 1500)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: w, height: h, antialias: true, transparent: false)
end
def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  old = m.materials['Material8'] or raise 'Material8 missing'
  m.start_operation('JESB Lot 19 v6 materials', true)

  log '1. accent panels -> ACC Lot 19 Siding dec Light Brown'
  lb = m.materials.add('ACC Lot 19 - Siding dec - Light Brown')
  lb.texture = File.join(OUT, 'ACC_Lot19_Siding_dec_Light_Brown.png')
  lb.texture.size = [19.3, 20.2]
  n = 0
  PANELS.each do |pid|
    g = m.find_entity_by_persistent_id(pid) or raise "panel group #{pid} missing"
    g.make_unique if g.is_a?(Sketchup::Group)
    g.entities.grep(Sketchup::Face).each do |f|
      next unless f.material == old || f.back_material == old
      nrm = f.normal
      u = Geom::Vector3d.new(0, 0, 1).cross(nrm); u.normalize!
      up = nrm.cross(u); up.normalize!; up.reverse! if up.z < 0
      p0 = f.vertices.min_by { |vx| vx.position.z }.position
      [true, false].each do |front|
        next unless (front ? f.material : f.back_material) == old
        f.position_material(lb, [p0, [0, 0], p0.offset(u, 19.3), [1, 0], p0.offset(up, 20.2), [0, 1]], front)
      end
      n += 1
      log format('  %d %s face %.0f sq in, %s', pid, g.name.empty? ? g.definition.name : g.name, f.area, b3(f.bounds))
    end
  end
  log "  #{n} panel faces; Material8 kept on the entry door, garage doors and deck"

  log '2. Cobble Stone lighter'
  [['Material9', 'Cobble_Stone_siding_light.png'], ['Material3', 'Cobble_Stone_siding2_light.png']].each do |name, file|
    mt = m.materials[name] or raise "#{name} missing"
    w = mt.texture.width; h = mt.texture.height; c1 = mt.color.to_a
    mt.texture = File.join(OUT, file)
    mt.texture.size = [w, h]
    log "  #{name}: #{w.round(1)}x#{h.round(1)} in., colour #{c1.first(3)} -> #{mt.color.to_a.first(3)}"
  end
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /Sree|\.dwg/i }
  cx = 1505.0; cy = 1478.0; cz = 210.0; hh = 700.0; d = 5000.0
  shot(v, 'JESB_Lot19_v6_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hh)
  shot(v, 'JESB_Lot19_v6_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hh)
  shot(v, 'JESB_Lot19_v6_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hh)
  shot(v, 'JESB_Lot19_v6_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hh)
  shot(v, 'JESB_Lot19_v6_Perspective.png', [cx - 620, cy - 1650, 420], [cx - 30, cy - 50, 170], true)
  shot(v, 'chk_front_panels.png', [1560, 1000, 200], [1560, 1410, 160], true)
  shot(v, 'chk_rear_panels.png', [1450, 2350, 220], [1450, 1820, 170], true)
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
