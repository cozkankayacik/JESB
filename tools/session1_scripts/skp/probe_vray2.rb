# Read-only: dump V-Ray scene plugin parameters relevant to lighting/exposure.
OUT = File.dirname(__FILE__)
def run
  ctx = VRay::Context.active
  scene = ctx.scene
  File.open(File.join(OUT, 'probe2.txt'), 'w') do |f|
    scene.each do |p|
      n = p.name
      next unless n =~ %r{^/(SunLight|Environment|SettingsEnvironment|CameraPhysical|SettingsCamera|SettingsColorMapping|SettingsGI|RenderView|SettingsOptions|SettingsImageSampler|SettingsDMCSampler|SettingsLightCache|EnvironmentFog)}
      f.puts "== #{n} (#{p.type})"
      p.each do |k, v|
        s = v.respond_to?(:to_a) && !v.is_a?(Array) && !v.is_a?(String) ? v.to_a.inspect : (v.respond_to?(:name) ? "-> #{v.name}" : v.inspect)
        f.puts "   #{k} = #{s[0, 140]}"
      end
    end
    f.puts '== all plugin names'
    names = []
    scene.each { |p| names << "#{p.name}(#{p.type})" }
    f.puts names.join(', ')
  end
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => e
  File.write(File.join(OUT, 'done.txt'), "ERR #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
end
tries = 0
tid = UI.start_timer(2, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid)
    UI.start_timer(10, false) { run }
  elsif tries > 60
    UI.stop_timer(tid)
    File.write(File.join(OUT, 'done.txt'), 'ERR no model loaded')
  end
end
