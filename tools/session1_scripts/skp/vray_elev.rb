# V-Ray production renders of the four elevations, from a copy of the user's v4. Nothing is saved to the model.
OUT = File.join(File.dirname(__FILE__), 'render')
Dir.mkdir(OUT) unless Dir.exist?(OUT)
LOGF = File.join(OUT, 'log.txt')
File.write(LOGF, '')
def log(s) File.open(LOGF, 'a') { |f| f.puts "#{Time.now.strftime('%H:%M:%S')} #{s}" } end
def finish(msg) File.write(File.join(File.dirname(__FILE__), 'done.txt'), msg) end

W = (ENV['JESB_W'] || 2400).to_i
H = (W * 0.625).round
CX = 3226.0; CY = 6785.0; CZ = 195.0; D = 3000.0
# name, camera direction (x, y), sun bearing in plan as seen in the model (unit vector pointing toward the sun)
VIEWS = [
  ['Front', [0, 1],  [-0.64, -0.77]],
  ['Left',  [1, 0],  [-0.77, 0.64]],
  ['Rear',  [0, -1], [0.64, 0.77]],
  ['Right', [-1, 0], [0.77, -0.64]]
].freeze

def aim_sun(m, want)
  si = m.shadow_info
  si['NorthAngle'] = 0.0
  s = si['SunDirection']
  cur = Math.atan2(s.y, s.x)
  des = Math.atan2(want[1], want[0])
  [1, -1].each do |sign|
    si['NorthAngle'] = ((sign * (des - cur)) * 180.0 / Math::PI) % 360.0
    s2 = si['SunDirection']
    return s2 if (Math.atan2(s2.y, s2.x) - des).abs < 0.03 || ((Math.atan2(s2.y, s2.x) - des).abs - 2 * Math::PI).abs < 0.03
  end
  si['SunDirection']
end

def render_next(m, ctx, i)
  if i >= VIEWS.length
    log 'all views done'
    finish('ok')
    return
  end
  name, dir, sun = VIEWS[i]
  v = m.active_view
  s = aim_sun(m, sun)
  cam = Sketchup::Camera.new([CX - dir[0] * D, CY - dir[1] * D, CZ], [CX, CY, CZ], [0, 0, 1])
  cam.perspective = false
  cam.height = 690.0
  v.camera = cam
  r = ctx.renderer
  VRay::Command.render_production
  t0 = Time.now
  log "#{name}: started, sun=#{s.to_a.map { |a| a.round(2) }} north=#{m.shadow_info['NorthAngle'].round(1)}"
  tid = UI.start_timer(2, true) do
    st = r.state
    done = st.to_s =~ /idle/i && Time.now - t0 > 6
    if done || Time.now - t0 > 1500
      UI.stop_timer(tid)
      path = File.join(OUT, "JESB_Lot2_v4_Render_#{name}.png")
      ok = (r.save_vfb_image(path) rescue "ERR #{$!.message}")
      log "#{name}: state=#{st.inspect} saved=#{ok.inspect} #{(Time.now - t0).round(1)}s"
      UI.start_timer(2, false) { render_next(m, ctx, i + 1) }
    end
  end
end

def run
  m = Sketchup.active_model
  ctx = VRay::Context.active
  scene = ctx.scene
  # sun height: pick the hour on 21 June closest to ~38 degrees altitude
  si = m.shadow_info
  si['NorthAngle'] = 0.0
  best = nil
  (10..23).each do |h|
    si['ShadowTime'] = Time.gm(2026, 6, 21, h, 0, 0)
    z = si['SunDirection'].z
    best = [h, z] if z > 0 && (best.nil? || (z - 0.62).abs < (best[1] - 0.62).abs)
  end
  si['ShadowTime'] = Time.gm(2026, 6, 21, best[0], 0, 0)
  log "sun hour #{best[0]} altitude z=#{best[1].round(2)}"

  # driveway slab profile on the near (west) face of the ground so it reads in the left elevation
  t = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /Terrain/ }
  drive = m.entities.grep(Sketchup::Face).select { |f| f.material && f.material.name == 'Asphalt_02_1K' }
  if t && !drive.empty?
    bb = Geom::BoundingBox.new
    drive.each { |f| bb.add(f.bounds) }
    x = t.bounds.min.x - 0.5
    g = m.entities.add_group
    f = g.entities.add_face([x, bb.min.y, bb.min.z], [x, bb.max.y, bb.min.z], [x, bb.max.y, bb.max.z], [x, bb.min.y, bb.max.z])
    f.material = m.materials['Asphalt_02_1K']
    f.back_material = f.material
  end

  cp = scene['/CameraPhysical']
  kv = []
  cp.each { |k, val| kv << "#{k}=#{val.inspect[0, 30]}" } rescue nil
  log "CameraPhysical: #{kv.join('; ')[0, 1500]}"
  scene.change do
    so = scene['/SettingsOutput']
    so[:img_width] = W
    so[:img_height] = H
    scene['/SettingsColorMapping'][:adaptation_only] = 0   # burn the 2.2 gamma into the saved image
    is = scene['/SettingsImageSampler']
    is[:progressive_threshold] = 0.01
    is[:dmc_threshold] = 0.01
    scene['/CameraPhysical'][:shutter_speed] = 520.0   # about 0.8 stop darker than the default, keeps sunlit white brick from clipping
  end
  log "output #{scene['/SettingsOutput'][:img_width]}x#{scene['/SettingsOutput'][:img_height]} adaptation_only=#{scene['/SettingsColorMapping'][:adaptation_only]} threshold=#{scene['/SettingsImageSampler'][:progressive_threshold]}"
  render_next(m, ctx, 0)
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
