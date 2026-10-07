# Read-only probe: what rendering options and V-Ray Ruby API are available.
OUT = File.dirname(__FILE__)
def describe(mod, f, depth = 0, seen = {})
  return if seen[mod] || depth > 3
  seen[mod] = true
  f.puts "#{'  ' * depth}#{mod.class} #{mod.name}"
  sm = (mod.singleton_methods(false) rescue []).sort
  f.puts "#{'  ' * depth}  singleton: #{sm.join(', ')}" unless sm.empty?
  if mod.is_a?(Class)
    im = (mod.instance_methods(false) rescue []).sort
    f.puts "#{'  ' * depth}  instance: #{im.join(', ')}" unless im.empty?
  end
  (mod.constants(false) rescue []).sort.each do |c|
    v = (mod.const_get(c) rescue nil)
    if v.is_a?(Module) then describe(v, f, depth + 1, seen)
    else f.puts "#{'  ' * depth}  const #{c} = #{v.inspect[0, 80]}" end
  end
end

def run
  m = Sketchup.active_model
  File.open(File.join(OUT, 'probe.txt'), 'w') do |f|
    f.puts "SketchUp #{Sketchup.version} pro=#{Sketchup.is_pro?}"
    f.puts '--- extensions'
    Sketchup.extensions.each { |e| f.puts "  #{e.name} v#{e.version} loaded=#{e.loaded?}" }
    f.puts '--- rendering_options'
    m.rendering_options.each_pair { |k, v| f.puts "  #{k} = #{v.inspect[0, 60]}" }
    f.puts '--- shadow_info'
    m.shadow_info.each_pair { |k, v| f.puts "  #{k} = #{v.inspect[0, 60]}" }
    f.puts '--- environments: ' + (m.respond_to?(:environments) ? m.environments.map(&:name).inspect + " current=#{m.environments.current.inspect}" : 'n/a')
    f.puts '--- materials (pbr?)'
    m.materials.each { |x| f.puts "  #{x.name} tex=#{x.texture ? File.basename(x.texture.filename) + " #{x.texture.width.round(1)}x#{x.texture.height.round(1)}in #{x.texture.image_width}x#{x.texture.image_height}px" : '-'} color=#{x.color.to_a.first(3)} alpha=#{x.alpha}" + (x.respond_to?(:workflow) ? " wf=#{x.workflow} rough=#{(x.roughness_factor rescue '?')} metal=#{(x.metallic_factor rescue '?')}" : '') }
    f.puts '--- VRay'
    if defined?(VRay) then describe(VRay, f) else f.puts '  VRay module not defined' end
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
    UI.start_timer(8, false) { run }
  elsif tries > 60
    UI.stop_timer(tid)
    File.write(File.join(OUT, 'done.txt'), 'ERR no model loaded')
  end
end
