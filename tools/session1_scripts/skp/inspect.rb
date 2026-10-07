# Read-only inspection of the model: structure report + reference images.
require 'json'
OUT = File.dirname(__FILE__)

def bb(b)
  return 'empty' if b.empty?
  mn = b.min; mx = b.max
  format('[%.1f,%.1f,%.1f]-[%.1f,%.1f,%.1f] size %.1fx%.1fx%.1f', mn.x, mn.y, mn.z, mx.x, mx.y, mx.z, b.width, b.height, b.depth)
end

def describe(ents, f, depth, maxdepth, path = '')
  counts = Hash.new(0)
  ents.each { |e| counts[e.typename] += 1 }
  f.puts "#{'  ' * depth}(#{counts.map { |k, v| "#{k}=#{v}" }.join(' ')})"
  i = 0
  ents.each do |e|
    next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    i += 1
    d = e.definition
    kind = e.is_a?(Sketchup::Group) ? 'G' : 'C'
    f.puts "#{'  ' * depth}#{kind} pid=#{e.persistent_id} name='#{e.name}' def='#{d.name}' tag='#{e.layer.name}' hidden=#{e.hidden?} mat='#{e.material ? e.material.name : ''}' bb=#{bb(e.bounds)}"
    describe(d.entities, f, depth + 1, maxdepth, path) if depth < maxdepth
  end
end

def run
  m = Sketchup.active_model
  File.open(File.join(OUT, 'report.txt'), 'w') do |f|
    f.puts "path: #{m.path}"
    f.puts "units: #{m.options['UnitsOptions']['LengthUnit']} fmt #{m.options['UnitsOptions']['LengthFormat']}"
    f.puts "bounds: #{bb(m.bounds)}"
    f.puts "tags: " + m.layers.map { |l| "#{l.name}(#{l.visible? ? 'on' : 'off'})" }.join(', ')
    f.puts "scenes: " + m.pages.map(&:name).join(', ')
    f.puts "materials: " + m.materials.map(&:name).join(', ')
    f.puts '--- definitions'
    m.definitions.each { |d| f.puts "  '#{d.name}' inst=#{d.count_used_instances} group=#{d.group?} ents=#{d.entities.length} bb=#{bb(d.bounds)}" if d.count_used_instances > 0 }
    f.puts '--- tree'
    describe(m.entities, f, 0, 3)
  end
  v = m.active_view
  v.write_image(filename: File.join(OUT, 'cur_view.jpg'), width: 1600, height: 1000, antialias: true)
  c = m.bounds.center
  dist = m.bounds.diagonal * 2
  views = { 'top' => [[0, 0, 1], [0, 1, 0]], 'south' => [[0, -1, 0], [0, 0, 1]], 'north' => [[0, 1, 0], [0, 0, 1]], 'east' => [[1, 0, 0], [0, 0, 1]], 'west' => [[-1, 0, 0], [0, 0, 1]] }
  views.each do |n, (dir, up)|
    eye = [c.x + dir[0] * dist, c.y + dir[1] * dist, c.z + dir[2] * dist]
    cam = Sketchup::Camera.new(eye, c, up)
    cam.perspective = false
    v.camera = cam
    v.zoom_extents
    v.write_image(filename: File.join(OUT, "cur_#{n}.jpg"), width: 1600, height: 1000, antialias: true)
  end
  [[1, -1, 0.6, 'se'], [-1, -1, 0.6, 'sw'], [1, 1, 0.6, 'ne'], [-1, 1, 0.6, 'nw']].each do |dx, dy, dz, n|
    cam = Sketchup::Camera.new([c.x + dx * dist, c.y + dy * dist, c.z + dz * dist], c, [0, 0, 1])
    cam.perspective = true
    v.camera = cam
    v.zoom_extents
    v.write_image(filename: File.join(OUT, "cur_persp_#{n}.jpg"), width: 1600, height: 1000, antialias: true)
  end
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => e
  File.write(File.join(OUT, 'done.txt'), "ERR #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}")
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
