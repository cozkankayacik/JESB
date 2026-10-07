# Re-align the hidden reference DWG: SketchUp import moved the drawing's min corner to the origin.
OUT = File.dirname(__FILE__)
LOG = []
def log(s)
  LOG << s
  File.write(File.join(OUT, 'result2.txt'), LOG.join("\n"))
end

def layer_bounds(ents, tr, name, bb)
  ents.each do |e|
    if e.is_a?(Sketchup::Edge)
      next unless e.layer.name == name
      e.vertices.each { |v| bb.add(v.position.transform(tr)) }
    elsif e.is_a?(Sketchup::ComponentInstance) || e.is_a?(Sketchup::Group)
      layer_bounds(e.definition.entities, tr * e.transformation, name, bb)
    end
  end
  bb
end

def run
  m = Sketchup.active_model
  v = m.active_view
  c0 = v.camera
  orig_cam = Sketchup::Camera.new(c0.eye, c0.target, c0.up, c0.perspective?, c0.fov)
  tag = m.layers['REF_DWG_Rev_2026-10-05']
  ref = m.entities.find { |e| e.respond_to?(:layer) && e.layer == tag }
  raise 'reference not found' unless ref
  bb = layer_bounds(ref.definition.entities, ref.transformation, '4-ROOF', Geom::BoundingBox.new)
  log "4-ROOF bounds now: #{bb.min.to_a.map { |a| a.round(2) }} .. #{bb.max.to_a.map { |a| a.round(2) }} (DWG: 10617.14,1735.00 .. 11571.14,2464.00)"
  # DWG roof plan wall line (10629.14, 1853.00) = garage SW corner -> model (2755.44, 6537.40); 4-ROOF min is (10617.14, 1735.00)
  target_min = [2755.44 - 12.0, 6537.40 - 118.0, 0]
  m.start_operation('Align reference DWG', true)
  ref.transform!(Geom::Transformation.translation([target_min[0] - bb.min.x, target_min[1] - bb.min.y, 0]))
  m.commit_operation
  bb2 = layer_bounds(ref.definition.entities, ref.transformation, '4-ROOF', Geom::BoundingBox.new)
  log "4-ROOF bounds after: #{bb2.min.to_a.map { |a| a.round(2) }} .. #{bb2.max.to_a.map { |a| a.round(2) }}"
  log "saved: #{m.save(m.path)}"
  # overlay check (not saved): roof plan linework over the model, top view
  tag.visible = true
  cam = Sketchup::Camera.new([3226, 6790, 3000], [3226, 6790, 0], [0, 1, 0])
  cam.perspective = false
  cam.height = 900
  v.camera = cam
  m.rendering_options['ModelTransparency'] = true
  v.write_image(filename: File.join(OUT, 'chk_overlay_top.jpg'), width: 2400, height: 1500, antialias: true)
  m.rendering_options['ModelTransparency'] = false
  tag.visible = false
  v.camera = orig_cam
  log "tag visible at exit: #{tag.visible?}; model modified flag: #{m.modified?}"
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => ex
  log "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(6).join("\n")}"
  File.write(File.join(OUT, 'done.txt'), 'ERR')
end

tries = 0
tid = UI.start_timer(2, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid)
    UI.start_timer(3, false) { run }
  elsif tries > 60
    UI.stop_timer(tid)
    File.write(File.join(OUT, 'done.txt'), 'ERR no model loaded')
  end
end
