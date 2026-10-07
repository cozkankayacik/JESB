# Opened on v1: store its camera. Opened on v2/v3: apply the stored camera, save, export perspective.
OUT = File.dirname(__FILE__)
CAMFILE = File.join(OUT, 'v1_camera.txt')

def run
  m = Sketchup.active_model
  v = m.active_view
  base = File.basename(m.path, '.skp')
  if base == 'work_v1'
    c = v.camera
    File.write(CAMFILE, [c.eye.to_a, c.target.to_a, c.up.to_a, [c.perspective? ? 1 : 0, c.fov]].flatten.join(','))
    File.write(File.join(OUT, 'done.txt'), 'ok stored')
  else
    a = File.read(CAMFILE).split(',').map(&:to_f)
    cam = Sketchup::Camera.new(a[0, 3], a[3, 3], a[6, 3], a[9] == 1.0, a[10])
    v.camera = cam
    m.start_operation('Restore saved view', true)
    m.set_attribute('JESB', 'saved_view', 'v1 camera')
    m.commit_operation
    ok = m.save(m.path)
    v.write_image(filename: File.join(OUT, "#{base}_Perspective.png"), width: 2400, height: 1500, antialias: true, transparent: false)
    tag = m.layers['REF_DWG_Rev_2026-10-05']
    File.write(File.join(OUT, 'done.txt'), "ok saved=#{ok} #{base} ref_tag_visible=#{tag ? tag.visible? : 'n/a'} eye=#{v.camera.eye.to_a.map { |x| x.round(1) }}")
  end
rescue => e
  File.write(File.join(OUT, 'done.txt'), "ERR #{e.class}: #{e.message}")
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
