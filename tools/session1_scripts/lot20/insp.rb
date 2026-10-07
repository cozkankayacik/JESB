# Read-only inspection of the Lot 20 SketchUp model: structure report + reference views.
OUT = File.dirname(__FILE__)
def b3(b) b.empty? ? 'empty' : format('(%.1f,%.1f,%.1f)-(%.1f,%.1f,%.1f) %.0fx%.0fx%.0f', b.min.x, b.min.y, b.min.z, b.max.x, b.max.y, b.max.z, b.width, b.height, b.depth) end

def visible_bounds(m)
  bb = Geom::BoundingBox.new
  m.entities.each do |e|
    next if e.respond_to?(:hidden?) && e.hidden?
    next if e.respond_to?(:layer) && !e.layer.visible?
    b = e.bounds
    next if b.empty? || b.width > 4000 || b.height > 4000
    next if e.is_a?(Sketchup::ComponentInstance) && e.definition.name =~ /\.dwg$/i
    bb.add(b)
  end
  bb
end

def run
  m = Sketchup.active_model
  v = m.active_view
  File.open(File.join(OUT, 'skp.txt'), 'w') do |f|
    c = v.camera
    f.puts "path #{m.path}"
    f.puts "camera eye=#{c.eye.to_a.map { |a| a.round(1) }} target=#{c.target.to_a.map { |a| a.round(1) }} persp=#{c.perspective?}"
    f.puts "scenes: #{m.pages.map(&:name).join(', ')}"
    f.puts "tags: " + m.layers.map { |l| "#{l.name}(#{l.visible? ? 'on' : 'off'})" }.join(', ')
    f.puts "model bounds #{b3(m.bounds)}"
    vb = visible_bounds(m)
    f.puts "visible bounds #{b3(vb)}"
    f.puts "top-level: " + m.entities.group_by(&:typename).map { |k, a| "#{k}=#{a.length}" }.join(' ')
    f.puts '--- materials'
    m.materials.each { |x| f.puts "  #{x.name} tex=#{x.texture ? File.basename(x.texture.filename) : '-'} color=#{x.color.to_a.first(3)} alpha=#{x.alpha}" }
    f.puts '--- top-level groups/components'
    m.entities.each do |e|
      next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      d = e.definition
      mats = d.entities.grep(Sketchup::Face).map { |x| x.material ? x.material.name : '-' }.tally.sort_by { |_, n| -n }.first(3).map { |k, n| "#{k}:#{n}" }.join(' ')
      f.puts format("%s pid=%d name='%s' def='%s' tag=%s hidden=%s mat=%s faces=%d [%s] bb %s", e.typename[0], e.persistent_id, e.name, d.name, e.layer.name, e.hidden?, (e.material ? e.material.name : '-'), d.entities.grep(Sketchup::Face).length, mats, b3(e.bounds))
    end
    f.puts '--- component definitions in use'
    m.definitions.each { |d| f.puts "  '#{d.name}' inst=#{d.count_used_instances} group=#{d.group?} bb #{b3(d.bounds)}" if d.count_used_instances > 0 && !d.group? }
    f.puts '--- loose faces'
    m.entities.grep(Sketchup::Face).each { |fc| f.puts "  F mat=#{fc.material ? fc.material.name : '-'} n=#{fc.normal.to_a.map { |a| a.round(1) }} bb #{b3(fc.bounds)}" }
  end
  v.write_image(filename: File.join(OUT, 'skp_saved_view.jpg'), width: 2000, height: 1200, antialias: true)
  vb = visible_bounds(m)
  cx, cy, cz = vb.center.x, vb.center.y, vb.center.z
  span = [vb.width, vb.height].max
  d = 4000.0
  shots = { 'front' => [0, -1], 'rear' => [0, 1], 'left' => [-1, 0], 'right' => [1, 0] }
  shots.each do |n, (dx, dy)|
    cam = Sketchup::Camera.new([cx + dx * d, cy + dy * d, cz], [cx, cy, cz], [0, 0, 1])
    cam.perspective = false
    cam.height = [span * 0.72, vb.depth * 1.25].max
    v.camera = cam
    v.write_image(filename: File.join(OUT, "skp_#{n}.jpg"), width: 2400, height: 1500, antialias: true)
  end
  cam = Sketchup::Camera.new([cx, cy, cz + d], [cx, cy, cz], [0, 1, 0])
  cam.perspective = false
  cam.height = span * 1.15
  v.camera = cam
  v.write_image(filename: File.join(OUT, 'skp_top.jpg'), width: 2000, height: 2000, antialias: true)
  [[-1, -1, 'sw'], [1, -1, 'se'], [1, 1, 'ne'], [-1, 1, 'nw']].each do |dx, dy, n|
    cam = Sketchup::Camera.new([cx + dx * span * 1.5, cy + dy * span * 1.5, cz + span * 0.7], [cx, cy, cz], [0, 0, 1])
    cam.perspective = true
    v.camera = cam
    v.write_image(filename: File.join(OUT, "skp_persp_#{n}.jpg"), width: 2000, height: 1200, antialias: true)
  end
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => e
  File.write(File.join(OUT, 'done.txt'), "ERR #{e.class}: #{e.message}\n#{e.backtrace.first(6).join("\n")}")
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
