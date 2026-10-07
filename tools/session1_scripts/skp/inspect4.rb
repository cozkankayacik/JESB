# Read-only: everything below the sill band (foundation / grade-related geometry) + views.
OUT = File.dirname(__FILE__)
def p3(pt) format('(%.1f,%.1f,%.1f)', pt.x, pt.y, pt.z) end

def dump_faces(ents, tr, f, ind, zmax)
  ents.each do |e|
    if e.is_a?(Sketchup::Face)
      pts = e.outer_loop.vertices.map { |v| v.position.transform(tr) }
      next if pts.map(&:z).min > zmax
      n = e.normal.transform(tr)
      f.puts "#{ind}F pid=#{e.persistent_id} mat=#{e.material ? e.material.name : '-'} n=(#{n.x.round(2)},#{n.y.round(2)},#{n.z.round(2)}) holes=#{e.loops.length - 1} " + pts.map { |p| p3(p) }.join(' ')
    elsif e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      b = e.bounds
      f.puts "#{ind}#{e.typename} pid=#{e.persistent_id} def='#{e.definition.name}' mat=#{e.material ? e.material.name : '-'}"
      dump_faces(e.definition.entities, tr * e.transformation, f, ind + '  ', zmax) if e.definition.entities.length < 300
    end
  end
end

def shot(view, name, eye, target, persp, height = nil)
  cam = Sketchup::Camera.new(eye, target, [0, 0, 1])
  cam.perspective = persp
  cam.height = height if height && !persp
  view.camera = cam
  view.write_image(filename: File.join(OUT, name), width: 2000, height: 1000, antialias: true)
end

def run
  m = Sketchup.active_model
  File.open(File.join(OUT, 'base.txt'), 'w') do |f|
    m.entities.each do |e|
      next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      next if e.hidden? || !e.layer.visible?
      b = e.bounds
      next if b.min.z > 5.9 || b.min.x < 2300 || b.max.x > 3800
      f.puts "=== #{e.typename} pid=#{e.persistent_id} def='#{e.definition.name}' mat=#{e.material ? e.material.name : '-'} bb #{p3(b.min)} #{p3(b.max)} ents=#{e.definition.entities.length}"
      dump_faces(e.definition.entities, e.transformation, f, '  ', 5.9)
    end
    f.puts '=== loose faces'
    dump_faces(m.entities.grep(Sketchup::Face), Geom::Transformation.new, f, '  ', 1000)
    f.puts "=== ground: #{m.rendering_options['DrawGround']} sky=#{m.rendering_options['DrawHorizon']} groundcolor=#{m.rendering_options['GroundColor'].to_a} materials: " + m.materials.map { |x| "#{x.name}[#{x.texture ? File.basename(x.texture.filename) : x.color.to_a.join('/')}]" }.join(', ')
    g17 = m.find_entity_by_persistent_id(191755)
    f.puts "=== entry wall group mat=#{g17.material ? g17.material.name : '-'}"
    g17.entities.grep(Sketchup::Face).each { |fc| f.puts "  F mat=#{fc.material ? fc.material.name : '-'} n=#{fc.normal.to_a.map { |a| a.round(1) }} area=#{fc.area.round(0)}" }
  end
  v = m.active_view
  cx = 3226.0; cy = 6785.0
  shot(v, 'b_front.jpg', [cx, cy - 3000, 0], [cx, cy, 0], false, 520)
  shot(v, 'b_rear.jpg', [cx, cy + 3000, 0], [cx, cy, 0], false, 520)
  shot(v, 'b_left.jpg', [cx - 3000, cy, 0], [cx, cy, 0], false, 520)
  shot(v, 'b_right.jpg', [cx + 3000, cy, 0], [cx, cy, 0], false, 520)
  shot(v, 'b_se.jpg', [4500, 5700, 500], [3400, 6700, 0], true)
  shot(v, 'b_ne.jpg', [4500, 7900, 500], [3350, 6900, 0], true)
  shot(v, 'b_nw.jpg', [2100, 7900, 500], [3050, 6950, 0], true)
  File.write(File.join(OUT, 'done.txt'), 'ok')
rescue => e
  File.write(File.join(OUT, 'done.txt'), "ERR #{e.class}: #{e.message}\n#{e.backtrace.first(6).join("\n")}")
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
