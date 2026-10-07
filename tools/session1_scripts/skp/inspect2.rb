# Read-only: dump geometry of roof, entry tower, garage wall groups; close-up images.
OUT = File.dirname(__FILE__)
PIDS = [212244, 212534, 212536, 189634, 190328, 190521, 191755, 191779, 192973, 194339, 196417, 182223, 189294, 189632, 189633, 188642, 188616, 212299, 211538, 212342, 212806, 212669, 195023, 195361, 195362, 195681, 195682, 212581]

def p3(pt)
  format('(%.2f,%.2f,%.2f)', pt.x, pt.y, pt.z)
end

def dump(ents, tr, f, ind, depth)
  ents.each do |e|
    case e
    when Sketchup::Face
      n = e.normal.transform(tr)
      mat = e.material ? e.material.name : '-'
      bm = e.back_material ? e.back_material.name : '-'
      f.puts "#{ind}F mat=#{mat} back=#{bm} n=(#{'%.2f' % n.x},#{'%.2f' % n.y},#{'%.2f' % n.z}) loops=#{e.loops.length} " + e.outer_loop.vertices.map { |v| p3(v.position.transform(tr)) }.join(' ')
      e.loops.each { |l| next if l.outer?; f.puts "#{ind}  hole " + l.vertices.map { |v| p3(v.position.transform(tr)) }.join(' ') }
    when Sketchup::Group, Sketchup::ComponentInstance
      d = e.definition
      f.puts "#{ind}#{e.is_a?(Sketchup::Group) ? 'G' : 'C'} pid=#{e.persistent_id} def='#{d.name}' mat=#{e.material ? e.material.name : '-'} ents=#{d.entities.length} tr_origin=#{p3((tr * e.transformation).origin)}"
      dump(d.entities, tr * e.transformation, f, ind + '  ', depth + 1) if depth < 2 && d.entities.length < 400
    end
  end
end

def run
  m = Sketchup.active_model
  File.open(File.join(OUT, 'geom.txt'), 'w') do |f|
    m.entities.each do |e|
      next unless e.respond_to?(:persistent_id) && PIDS.include?(e.persistent_id)
      d = e.definition
      f.puts "=== pid=#{e.persistent_id} def='#{d.name}' mat=#{e.material ? e.material.name : '-'} instances=#{d.count_used_instances} bb_min=#{p3(e.bounds.min)} bb_max=#{p3(e.bounds.max)}"
      dump(d.entities, e.transformation, f, '  ', 0)
    end
    f.puts '=== loose top-level faces/edges'
    m.entities.grep(Sketchup::Face).each { |fc| f.puts "  F mat=#{fc.material ? fc.material.name : '-'} " + fc.outer_loop.vertices.map { |v| p3(v.position) }.join(' ') }
    f.puts "  edges=#{m.entities.grep(Sketchup::Edge).length}"
    f.puts "=== style/rendering: #{m.styles.active_style.name}; shadows=#{m.shadow_info['DisplayShadows']}"
  end
  v = m.active_view
  shots = {
    'front' => [[3225, 4500, 150], [3225, 6700, 150], false],
    'left' => [[1000, 6780, 130], [3000, 6780, 130], false],
    'tower' => [[3350, 6000, 330], [3480, 6500, 230], true],
    'garage' => [[2150, 6500, 160], [2760, 6790, 80], true],
    'roof_top' => [[3225, 6730, 3000], [3225, 6730, 0], false],
    'aerial_front' => [[3900, 5300, 900], [3300, 6600, 200], true]
  }
  shots.each do |n, (eye, tgt, persp)|
    up = n == 'roof_top' ? [0, 1, 0] : [0, 0, 1]
    cam = Sketchup::Camera.new(eye, tgt, up)
    cam.perspective = persp
    cam.height = (n == 'roof_top' ? 1100 : 720) unless persp
    v.camera = cam
    v.write_image(filename: File.join(OUT, "c_#{n}.jpg"), width: 1800, height: 1100, antialias: true)
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
