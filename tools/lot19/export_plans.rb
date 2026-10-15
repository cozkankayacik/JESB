# JESB Lot 19 - plan cuts of the model (section plane, top orthographic, 2 px per inch, same frame as export_ortho.rb).
# Nothing is saved.
OUT = File.dirname(__FILE__)
PX = 2.0
CX = 1495.0; CY = 1475.0
def run
  m = Sketchup.active_model
  v = m.active_view
  m.entities.each { |e| e.hidden = true if e.is_a?(Sketchup::ComponentInstance) && (e.definition.name =~ /Sree|\.dwg/i) }
  ro = m.rendering_options
  ro['DisplaySectionCuts'] = true if ro.keys.include?('DisplaySectionCuts')
  ro['SectionCutWidth'] = 4 if ro.keys.include?('SectionCutWidth')
  [[100.0, 'plan_flr1.png'], [215.0, 'plan_flr2.png']].each do |z, name|
    sp = m.entities.add_section_plane([CX, CY, z], [0, 0, 1])
    sp.activate
    cam = Sketchup::Camera.new([CX, CY, 5000], [CX, CY, 0], [0, 1, 0])
    cam.perspective = false
    cam.height = 2400 / PX
    v.camera = cam
    v.write_image(filename: File.join(OUT, name), width: 2400, height: 2400, antialias: true, transparent: false)
    sp.erase!
  end
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => ex
  File.write(File.join(OUT, 'done.txt'), "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(6).join("\n")}")
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
