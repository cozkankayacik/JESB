# JESB Lot 19 - model v1: roof rebuilt to the Revision 1 elevations (A-300 / A-310), entry tower given its hip roof.
# Source model: JESB_LOT19_MODELLING.skp (owner's model, unchanged). Geometry from roof19.json (roof19.py).
require 'json'
OUT = File.dirname(__FILE__)
SAVE_AS = File.join(OUT, 'JESB_Lot19_v1.skp')
DATA = JSON.parse(File.read(File.join(OUT, 'roof19.json')))
OLD = { 344222 => 'main roof', 356950 => 'main roof, north-east part', 356842 => 'north-east block (Br 2) roof',
        347791 => 'front-left bay roof', 347840 => 'west bump roof', 644592 => 'entry tower flat roof box' }.freeze
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result_v1.txt'), LOG.join("\n"))
end
def near(a, b, t = 0.03) (a - b).abs < t end
def b3(b) format('x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z) end
CX = 1495.0; CY = 1475.0; CZ = 190.0; H = 1000.0
def shot(view, name, eye, target, persp, height = nil, up = [0, 0, 1], w = 2400, h = 1500)
  cam = Sketchup::Camera.new(eye, target, up)
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: w, height: h, antialias: true, transparent: false)
end
def merge_coplanar(ents)
  n = 0
  loop do
    dead = ents.grep(Sketchup::Edge).select { |e| e.faces.length == 2 && e.faces[0].normal.samedirection?(e.faces[1].normal) }
    break if dead.empty?
    n += dead.length
    ents.erase_entities(dead)
  end
  stray = ents.grep(Sketchup::Edge).select { |e| e.faces.empty? }
  ents.erase_entities(stray) unless stray.empty?
  n
end
def build_roof(m, name, spec, mat)
  zb = spec['zb']
  g = m.entities.add_group
  g.name = name
  ents = g.entities
  failed = 0
  spec['faces'].each do |fc|
    begin
      f = ents.add_face(fc['pts'].map { |p| Geom::Point3d.new(*p) })
      f.reverse! if f.normal.z < 0
    rescue
      failed += 1
    end
  end
  merged = merge_coplanar(ents)
  log "#{name}: #{spec['faces'].length} cells (#{failed} failed), #{merged} edges merged -> #{ents.grep(Sketchup::Face).length} roof planes"
  ents.grep(Sketchup::Edge).select { |e| e.faces.length == 1 }.each do |e|
    a = e.start.position; b = e.end.position
    begin
      ents.add_face([a, b, Geom::Point3d.new(b.x, b.y, zb), Geom::Point3d.new(a.x, a.y, zb)])
    rescue => ex
      log "  fascia face failed: #{ex.message}"
    end
  end
  ents.grep(Sketchup::Edge).select { |e| near(e.start.position.z, zb, 0.001) && near(e.end.position.z, zb, 0.001) }.each { |e| e.find_faces if e.faces.length < 2 }
  merge_coplanar(ents)
  faces = ents.grep(Sketchup::Face)
  faces.each do |f|
    nz = f.normal.z
    next if nz.abs < 0.001
    if near(f.vertices.map { |v| v.position.z }.max, zb, 0.001)
      f.reverse! if nz > 0
    else
      f.reverse! if nz < 0
      n = f.normal
      u = Geom::Vector3d.new(0, 0, 1).cross(n); u.normalize!
      up = n.cross(u); up.normalize!; up.reverse! if up.z < 0
      p0 = f.vertices.min_by { |v| v.position.z }.position
      tw = mat.texture ? mat.texture.width : 48.0
      th = mat.texture ? mat.texture.height : 48.0
      f.position_material(mat, [p0, [0, 0], p0.offset(u, tw), [1, 0], p0.offset(up, th), [0, 1]], true)
    end
  end
  open_edges = ents.grep(Sketchup::Edge).count { |e| e.faces.length != 2 }
  log format('  faces %d, open edges %d, manifold %s; %s', faces.length, open_edges, g.manifold?, b3(g.bounds))
  g
end
def revise
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  saved_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  shingle = m.materials['Material5'] or raise 'shingle material Material5 not found'
  metal = m.materials['Material6'] or raise 'metal roof material Material6 not found'
  m.start_operation('JESB Lot 19 v1 roof', true)
  old = OLD.keys.map { |pid| m.find_entity_by_persistent_id(pid) }
  raise "old roof groups missing: #{OLD.keys.zip(old).select { |_, e| e.nil? }.map(&:first)}" if old.any?(&:nil?)
  old.each_with_index { |e, i| log format('removed %-30s pid %d  %s', OLD.values[i], e.persistent_id, b3(e.bounds)) }
  m.entities.erase_entities(old)
  # loose top-level geometry of the old roof: faces and edges entirely above the wall plates (z 279)
  loose = m.entities.grep(Sketchup::Face).select { |f| f.bounds.min.z > 278.9 && f.bounds.max.z > 279.5 }
  loose.each { |f| log '  loose old roof face removed: ' + (f.material ? f.material.name : '-') + ' ' + b3(f.bounds) }
  m.entities.erase_entities(loose)
  stray = m.entities.grep(Sketchup::Edge).select { |e| e.faces.empty? && e.vertices.all? { |x| x.position.z > 278.9 } }
  m.entities.erase_entities(stray)
  log "loose old roof faces removed: #{loose.length}, stray edges #{stray.length}"
  build_roof(m, 'Roof - Main (per Rev 1 elevations, v1)', DATA['main'], shingle)
  build_roof(m, 'Roof - Entry Tower (standing seam, per Rev 1, v1)', DATA['tower'], metal)
  m.commit_operation
  v.camera = saved_cam
  log "saved: #{m.save(SAVE_AS)} #{SAVE_AS}"
  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /Sree/i }
  d = 5000.0
  shot(v, 'JESB_Lot19_v1_Elevation_Front.png', [CX, CY - d, CZ], [CX, CY, CZ], false, H)
  shot(v, 'JESB_Lot19_v1_Elevation_Rear.png', [CX, CY + d, CZ], [CX, CY, CZ], false, H)
  shot(v, 'JESB_Lot19_v1_Elevation_Left.png', [CX - d, CY, CZ], [CX, CY, CZ], false, H)
  shot(v, 'JESB_Lot19_v1_Elevation_Right.png', [CX + d, CY, CZ], [CX, CY, CZ], false, H)
  shot(v, 'JESB_Lot19_v1_Perspective.png', [CX - 600, CY - 1600, 420], [CX - 20, CY, 170], true)
  shot(v, 'chk_persp_ne.png', [CX + 900, CY + 1500, 700], [CX, CY + 50, 200], true)
  # same frames as export_ortho.rb (2 px / in) for the drawing overlays
  [['m_south.png', [CX, CY - d, CZ]], ['m_north.png', [CX, CY + d, CZ]], ['m_west.png', [CX - d, CY, CZ]], ['m_east.png', [CX + d, CY, CZ]]].each do |n, eye|
    shot(v, n, eye, [CX, CY, CZ], false, 500.0, [0, 0, 1], 2400, 1000)
  end
  shot(v, 'm_top.png', [CX, CY, CZ + d], [CX, CY, CZ], false, 1200.0, [0, 1, 0], 2400, 2400)
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
