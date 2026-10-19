# JESB Lot 19 - model v7 (from the owner's v6 of 2026-10-19 12:06): rear patio deck railing in light brown METAL
# instead of wood, and a light brown metal railing on the two steps up to the deck (north-west corner, x 1373..1383).
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot19_v7.skp')
RAILINGS = [355002, 355003, 355031, 355033, 355035, 357403].freeze          # 15.Balcony Railing instances
POSTS = [357018, 355032, 355034, 355024, 355004, 355030].freeze             # deck posts (wood boxes)
OLD_STEP_POST = 355025                                                     # post standing on the step
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v7.txt'), LOG.join("\n"))
end
def b3(b) format('x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) end
# paint every face and nested instance of a definition (recursively, each definition once)
def paint(defn, mat, seen)
  return 0 if seen[defn]
  seen[defn] = true
  n = 0
  defn.entities.each do |e|
    if e.is_a?(Sketchup::Face)
      e.material = mat; e.back_material = mat; n += 1
    elsif e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      e.material = mat
      n += paint(e.definition, mat, seen)
    end
  end
  n
end
def box(ents, x0, x1, y0, y1, z0, z1, mat)
  g = ents.add_group
  f = g.entities.add_face([x0, y0, z0], [x1, y0, z0], [x1, y1, z0], [x0, y1, z0])
  f.reverse! if f.normal.z > 0
  f.pushpull(-(z1 - z0))
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g
end
# bar sloping along x: square section, bottom z = za at x0 and zb at x1
def bar(ents, x0, x1, za, zb, y0, y1, h, mat)
  g = ents.add_group
  f = g.entities.add_face([x0, y0, za], [x1, y0, zb], [x1, y0, zb + h], [x0, y0, za + h])
  f.reverse! if f.normal.y < 0
  f.pushpull(y1 - y0)
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g
end
def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  lb = m.materials['ACC Lot 19 - Siding dec - Light Brown']
  log "ACC Light Brown material now: #{lb ? "rgb #{lb.color.to_a.first(3)} tex #{lb.texture ? File.basename(lb.texture.filename) : '-'}" : 'missing'}"
  m.start_operation('JESB Lot 19 v7 metal railing', true)
  metal = m.materials.add('ACC Lot 19 - Railing - Light Brown metal')
  metal.color = Sketchup::Color.new(145, 118, 92)                    # ACC Lot 19 Light Brown sample (I17) average

  log '1. deck railing and posts -> light brown metal'
  seen = {}
  RAILINGS.each do |pid|
    r = m.find_entity_by_persistent_id(pid) or raise "railing #{pid} missing"
    r.material = metal
    n = paint(r.definition, metal, seen)
    log "  railing #{pid} #{r.definition.name} #{b3(r.bounds)}: #{n} faces painted"
  end
  POSTS.each do |pid|
    p = m.find_entity_by_persistent_id(pid) or raise "post #{pid} missing"
    p.make_unique
    n = paint(p.definition, metal, {})
    log "  post #{pid} #{b3(p.bounds)}: #{n} faces"
  end

  log '2. railing on the two steps (north side, y 1991..1997.2)'
  old = m.find_entity_by_persistent_id(OLD_STEP_POST) or raise 'step post missing'
  log "  removed post on the step #{b3(old.bounds)}"
  old.erase!
  top_post = m.find_entity_by_persistent_id(355024)                  # deck corner post x 1384.4..1389.5, z 36.8..67.2
  sg = m.entities.add_group; sg.name = 'Deck steps railing - light brown metal (v7)'; se = sg.entities
  ground = 21.8; k = 7.5 / 10.0                                      # 7.5" risers, 10" tread
  xb0, xb1 = 1361.0, 1366.1                                         # bottom post on grade, 12" past the lower riser (x 1373.1)
  box(se, xb0, xb1, 1991.0, 1997.2, ground, 59.0, metal)
  box(se, xb0 - 0.4, xb1 + 0.4, 1990.6, 1997.6, 59.0, 60.0, metal)  # cap
  xt = top_post.bounds.min.x                                         # 1384.4
  ztop = 63.6                                                        # handrail bottom at the top post (rail 1.5 -> top 65.1)
  zr = lambda { |x| ztop - k * (xt - x) }
  bar(se, xb1, xt, zr.call(xb1), ztop, 1993.35, 1994.85, 1.5, metal)                 # handrail
  bar(se, xb1, xt, zr.call(xb1) - 24.0, ztop - 24.0, 1993.35, 1994.85, 1.5, metal)   # bottom rail
  x = xb1 + 3.5
  while x < xt - 1.0
    box(se, x, x + 0.75, 1993.725, 1994.475, zr.call(x) - 22.5, zr.call(x), metal)  # balusters, ~4" spacing
    x += 4.0
  end
  log "  bottom post x #{xb0}..#{xb1} on grade, handrail #{zr.call(xb1).round(1)}..#{ztop} + 1.5, #{se.length} pieces; #{b3(sg.bounds)}"
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"

  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /Sree|\.dwg/i }
  cx = 1505.0; cy = 1478.0; cz = 210.0; hh = 700.0; d = 5000.0
  shot(v, 'JESB_Lot19_v7_Elevation_Front.png', [cx, cy - d, cz], [cx, cy, cz], false, hh)
  shot(v, 'JESB_Lot19_v7_Elevation_Rear.png', [cx, cy + d, cz], [cx, cy, cz], false, hh)
  shot(v, 'JESB_Lot19_v7_Elevation_Left.png', [cx - d, cy, cz], [cx, cy, cz], false, hh)
  shot(v, 'JESB_Lot19_v7_Elevation_Right.png', [cx + d, cy, cz], [cx, cy, cz], false, hh)
  shot(v, 'JESB_Lot19_v7_Perspective.png', [cx - 620, cy - 1650, 420], [cx - 30, cy - 50, 170], true)
  shot(v, 'JESB_Lot19_v7_Rear_Deck_Detail.png', [900, 2450, 280], [1400, 1950, 40], true)
  shot(v, 'chk_steps.png', [1250, 2150, 110], [1378, 1975, 40], true)
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
