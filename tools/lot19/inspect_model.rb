# JESB Lot 19 - read-only inspection of a SketchUp model: structure report + reference views. Nothing is saved.
OUT = File.dirname(__FILE__)
def b3(b) b.empty? ? 'empty' : format('x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f (%.0fx%.0fx%.0f)', b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z, b.width, b.height, b.depth) end
def shot(view, name, eye, target, persp, height = nil, up = [0, 0, 1])
  cam = Sketchup::Camera.new(eye, target, up)
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2400, height: 1500, antialias: true, transparent: false)
end
def run
  m = Sketchup.active_model
  v = m.active_view
  c = v.camera
  o = File.open(File.join(OUT, 'model.txt'), 'w')
  o.puts "path #{m.path}"
  o.puts "units #{m.options['UnitsOptions']['LengthUnit']}"
  o.puts "camera eye=#{c.eye.to_a.map { |a| a.round(1) }} target=#{c.target.to_a.map { |a| a.round(1) }} persp=#{c.perspective?}"
  o.puts "scenes: #{m.pages.map(&:name).join(', ')}"
  o.puts 'tags: ' + m.layers.map { |l| "#{l.name}(#{l.visible? ? 'on' : 'off'})" }.join(', ')
  o.puts "model bounds #{b3(m.bounds)}"
  o.puts 'top-level: ' + m.entities.group_by(&:typename).map { |k, a| "#{k}=#{a.length}" }.join(' ')
  vb = Geom::BoundingBox.new
  dump = lambda do |ents, tr, depth|
    ents.each do |e|
      next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      bb = Geom::BoundingBox.new
      (0..7).each { |i| bb.add(e.bounds.corner(i).transform(tr)) }
      fs = e.definition.entities.grep(Sketchup::Face)
      mats = fs.map { |f| f.material ? f.material.name : '-' }.tally.sort_by { |_, n| -n }.first(4).to_h
      vis = !e.hidden? && e.layer.visible?
      vb.add(bb) if depth == 0 && vis && bb.width < 5000 && bb.height < 5000
      o.puts format('%s%s pid=%d name=%s def=%s tag=%s vis=%s faces=%d %s %s', '  ' * depth, e.typename[0, 4], e.persistent_id, e.name, e.definition.name, e.layer.name, vis, fs.length, mats, b3(bb))
      dump.call(e.definition.entities, tr * e.transformation, depth + 1) if depth < 1
    end
  end
  dump.call(m.entities, Geom::Transformation.new, 0)
  loose = m.entities.grep(Sketchup::Face)
  o.puts "loose top-level faces: #{loose.length}, by material #{loose.map { |f| f.material ? f.material.name : '-' }.tally}"
  o.puts "visible bounds (top-level objects) #{b3(vb)}"
  o.puts '--- materials'
  m.materials.each { |x| col = x.color; o.puts format('  %-34s rgb %3d %3d %3d %s', x.name, col.red, col.green, col.blue, x.texture ? File.basename(x.texture.filename) + format(' %.1fx%.1f', x.texture.width, x.texture.height) : '') }
  o.close
  b = vb.empty? ? m.bounds : vb
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  d = [b.width, b.height].max * 3
  hgt = [b.width, b.height].max * 0.8
  v.write_image(filename: File.join(OUT, 'saved_view.png'), width: 2400, height: 1500, antialias: true, transparent: false)
  shot(v, 'v_south.png', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'v_north.png', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 'v_west.png', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'v_east.png', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 'v_top.png', [cx, cy, cz + d], [cx, cy, cz], false, hgt * 1.1, [0, 1, 0])
  shot(v, 'v_persp_sw.png', [cx - d * 0.5, cy - d * 0.6, cz + d * 0.35], [cx, cy, cz], true)
  shot(v, 'v_persp_ne.png', [cx + d * 0.5, cy + d * 0.6, cz + d * 0.35], [cx, cy, cz], true)
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
