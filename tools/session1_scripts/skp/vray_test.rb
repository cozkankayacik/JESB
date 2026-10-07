# V-Ray production render test on a copy of the user's v4. Nothing is saved.
OUT = File.join(File.dirname(__FILE__), 'render')
Dir.mkdir(OUT) unless Dir.exist?(OUT)
LOGF = File.join(OUT, 'log.txt')
File.write(LOGF, '')
def log(s) File.open(LOGF, 'a') { |f| f.puts "#{Time.now.strftime('%H:%M:%S')} #{s}" } end
def finish(msg) File.write(File.join(File.dirname(__FILE__), 'done.txt'), msg) end

W = 960; H = 600

def run
  m = Sketchup.active_model
  v = m.active_view
  ctx = VRay::Context.active
  log "context=#{ctx.inspect[0, 80]} license?=#{(VRay::Licensing.license? rescue 'err')}"
  scene = ctx.scene
  r = ctx.renderer
  names = []
  scene.each { |p| names << p.name }
  log "scene plugins: #{names.length}; settings: " + names.select { |n| n =~ /Settings|Camera|Sun|Sky|Environment|RenderView/i }.join(', ')
  %w[/SettingsOutput /SettingsImageSampler /SettingsCamera /SettingsRTEngine /SettingsEXR /SettingsOptions].each do |pn|
    p = scene[pn] rescue nil
    next unless p
    kv = []
    p.each { |k, val| kv << "#{k}=#{val.inspect[0, 40]}" } rescue kv << '(each failed)'
    log "#{pn}: #{kv.join('; ')[0, 1800]}"
  end

  # sun: clear summer afternoon
  si = m.shadow_info
  si['ShadowTime'] = Time.gm(2026, 6, 21, 15, 0, 0)
  log "sun dir=#{si['SunDirection'].to_a.map { |a| a.round(2) }} north=#{si['NorthAngle']}"

  cx = 3226.0; cy = 6785.0; cz = 195.0
  cam = Sketchup::Camera.new([cx, cy - 3000.0, cz], [cx, cy, cz], [0, 0, 1])
  cam.perspective = false
  cam.height = 690.0
  v.camera = cam
  log "viewport #{v.vpwidth}x#{v.vpheight}"

  scene.change do
    so = scene['/SettingsOutput']
    so[:img_width] = W
    so[:img_height] = H
  end
  log "output set: #{scene['/SettingsOutput'][:img_width]}x#{scene['/SettingsOutput'][:img_height]}"

  VRay::Command.render_production
  log "render started; state=#{r.state.inspect}"
  t0 = Time.now
  seen = []
  tid = UI.start_timer(2, true) do
    st = r.state
    unless seen.last == st
      seen << st
      log "state -> #{st.inspect} at #{(Time.now - t0).round(1)}s"
    end
    idle = st.to_s =~ /idle|done|stopped|ready/i
    if (idle && Time.now - t0 > 6) || Time.now - t0 > 600
      UI.stop_timer(tid)
      path = File.join(OUT, 'test_front.png')
      ok = (r.save_vfb_image(path) rescue "ERR #{$!.class}: #{$!.message}")
      log "save_vfb_image -> #{ok.inspect}; exists=#{File.exist?(path)} elapsed=#{(Time.now - t0).round(1)}s states=#{seen.inspect}"
      finish('ok')
    end
  end
rescue => e
  log "ERR #{e.class}: #{e.message}\n#{e.backtrace.first(6).join("\n")}"
  finish('ERR')
end

tries = 0
tid0 = UI.start_timer(2, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid0)
    UI.start_timer(10, false) { run }
  elsif tries > 60
    UI.stop_timer(tid0)
    finish('ERR no model loaded')
  end
end
