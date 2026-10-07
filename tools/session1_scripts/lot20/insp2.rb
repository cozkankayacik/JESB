# Read-only: Lot 20 house group - nested structure, key measurements, focused views.
OUT = File.dirname(__FILE__)
def b3(b) format('(%.1f,%.1f,%.1f)-(%.1f,%.1f,%.1f) %.0fx%.0fx%.0f', b.min.x, b.min.y, b.min.z, b.max.x, b.max.y, b.max.z, b.width, b.height, b.depth) end

def tree(ents, tr, f, depth, maxd)
  ents.each do |e|
    next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    d = e.definition
    t2 = tr * e.transformation
    bb = Geom::BoundingBox.new
    (0..7).each { |i| bb.add(d.bounds.corner(i).transform(t2)) }
    faces = d.entities.grep(Sketchup::Face)
    mats = faces.map { |x| x.material ? x.material.name : '-' }.tally.sort_by { |_, n| -n }.first(3).map { |k, n| "#{k}:#{n}" }.join(' ')
    f.puts "#{'  ' * depth}#{e.typename[0]} pid=#{e.persistent_id} name='#{e.name}' def='#{d.name}' hid=#{e.hidden?} mat=#{e.material ? e.material.name : '-'} f=#{faces.length} [#{mats}] sub=#{d.entities.grep(Sketchup::Group).length + d.entities.grep(Sketchup::ComponentInstance).length} bb #{b3(bb)}"
    tree(d.entities, t2, f, depth + 1, maxd) if depth < maxd
  end
end

def shot(v, name, eye, tgt, persp, h = nil, up = [0, 0, 1], w = 2400, hh = 1500)
  cam = Sketchup::Camera.new(eye, tgt, up)
  cam.perspective = persp
  cam.height = h if h && !persp
  v.camera = cam
  v.write_image(filename: File.join(OUT, name), width: w, height: hh, antialias: true)
end

def run
  m = Sketchup.active_model
  v = m.active_view
  house = m.entities.grep(Sketchup::Group).max_by { |g| g.bounds.diagonal }
  File.open(File.join(OUT, 'skp_tree.txt'), 'w') do |f|
    f.puts "house group pid=#{house.persistent_id} bb #{b3(house.bounds)}"
    tree(house.entities, house.transformation, f, 0, 2)
  end
  b = house.bounds
  cx, cy, cz = b.center.x, b.center.y, b.center.z
  d = 3000.0
  hgt = [b.width, b.height].max * 0.80
  shot(v, 's_front.jpg', [cx, cy - d, cz], [cx, cy, cz], false, hgt)
  shot(v, 's_rear.jpg', [cx, cy + d, cz], [cx, cy, cz], false, hgt)
  shot(v, 's_left.jpg', [cx - d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 's_right.jpg', [cx + d, cy, cz], [cx, cy, cz], false, hgt)
  shot(v, 's_top.jpg', [cx, cy, cz + d], [cx, cy, cz], false, [b.width, b.height].max * 1.15, [0, 1, 0], 2000, 2000)
  s = [b.width, b.height].max
  [[-1, -1, 'sw'], [1, -1, 'se'], [1, 1, 'ne'], [-1, 1, 'nw']].each do |dx, dy, n|
    shot(v, "s_persp_#{n}.jpg", [cx + dx * s * 1.25, cy + dy * s * 1.25, cz + s * 0.75], [cx, cy, cz - 40], true, nil, [0, 0, 1], 2000, 1250)
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
