# Read-only look at the user's updated v4.
OUT = File.dirname(__FILE__)
def run
  m = Sketchup.active_model
  v = m.active_view
  c = v.camera
  File.open(File.join(OUT, 'v4user.txt'), 'w') do |f|
    f.puts "camera eye=#{c.eye.to_a.map { |a| a.round(1) }} target=#{c.target.to_a.map { |a| a.round(1) }} persp=#{c.perspective?} fov=#{c.fov.round(1)}"
    f.puts "scenes: #{m.pages.map(&:name).join(', ')}"
    f.puts "style: #{m.styles.active_style.name}; tags: " + m.layers.map { |l| "#{l.name}(#{l.visible? ? 'on' : 'off'})" }.select { |s| s =~ /REF|Layer0|Untagged/ }.join(', ')
    f.puts "shadows=#{m.shadow_info['DisplayShadows']} use_sun_shading=#{m.shadow_info['UseSunForAllShading']} light=#{m.shadow_info['Light']} dark=#{m.shadow_info['Dark']}"
    f.puts "top-level: " + m.entities.group_by(&:typename).map { |k, a| "#{k}=#{a.length}" }.join(' ')
    m.entities.each do |e|
      next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      nm = e.name.to_s
      next if nm.empty? && e.persistent_id < 328000
      b = e.bounds
      f.puts format("%s pid=%d name='%s' def='%s' hidden=%s tag=%s bb (%.1f,%.1f,%.1f)-(%.1f,%.1f,%.1f) faces=%d", e.typename, e.persistent_id, nm, e.definition.name, e.hidden?, e.layer.name, b.min.x, b.min.y, b.min.z, b.max.x, b.max.y, b.max.z, e.definition.entities.grep(Sketchup::Face).length)
    end
    t = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /Terrain/ }
    if t
      fs = t.entities.grep(Sketchup::Face)
      f.puts "terrain: faces=#{fs.length} vertical=#{fs.count { |x| x.normal.z.abs < 0.01 }} mats=#{fs.map { |x| x.material ? x.material.name : '-' }.uniq} transform_identity=#{t.transformation.identity?}"
      tm = m.materials['Terrain_Grade']
      f.puts "Terrain_Grade color=#{tm.color.to_a} texture=#{tm.texture ? tm.texture.filename : 'none'}" if tm
    else
      f.puts 'terrain group not found by name'
    end
    f.puts "materials count=#{m.materials.length}: " + m.materials.map(&:name).last(8).join(', ')
  end
  v.write_image(filename: File.join(OUT, 'v4user_view.jpg'), width: 2000, height: 1100, antialias: true)
  File.write(File.join(OUT, 'done.txt'), 'ok')
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
