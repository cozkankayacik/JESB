# Read-only: geometry of the front upper wall above the garage, its windows, sills, and siding material usage.
OUT = File.dirname(__FILE__)
def p3(p) format('(%.2f,%.2f,%.2f)', p.x, p.y, p.z) end

def run
  m = Sketchup.active_model
  house = m.entities.grep(Sketchup::Group).max_by { |g| g.bounds.diagonal }
  ht = house.transformation
  File.open(File.join(OUT, 'wall.txt'), 'w') do |f|
    f.puts "house transform identity=#{ht.identity?} origin=#{p3(ht.origin)}"
    house.entities.each do |e|
      next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      tr = ht * e.transformation
      d = e.definition
      bb = Geom::BoundingBox.new
      (0..7).each { |i| bb.add(d.bounds.corner(i).transform(tr)) }
      near = bb.min.x < 12680 && bb.max.x > 12344 && bb.max.y > 3780 && bb.min.y < 3825 && bb.max.z > 190
      next unless near
      f.puts "=== #{e.typename[0]} pid=#{e.persistent_id} def='#{d.name}' inst=#{d.count_used_instances} mat=#{e.material ? e.material.name : '-'} tr_identity=#{e.transformation.identity?} origin=#{p3(tr.origin)} bb #{p3(bb.min)} #{p3(bb.max)} faces=#{d.entities.grep(Sketchup::Face).length}"
      next if d.entities.grep(Sketchup::Face).length > 200
      d.entities.grep(Sketchup::Face).each do |fc|
        pts = fc.outer_loop.vertices.map { |v| v.position.transform(tr) }
        next unless pts.any? { |p| p.z > 190 } && pts.any? { |p| p.y > 3780 && p.y < 3825 && p.x < 12680 }
        next if d.entities.grep(Sketchup::Face).length > 40 && !(e.persistent_id == 127795)
        n = fc.normal.transform(tr)
        f.puts "  F pid=#{fc.persistent_id} mat=#{fc.material ? fc.material.name : '-'} back=#{fc.back_material ? fc.back_material.name : '-'} n=(#{n.x.round(2)},#{n.y.round(2)},#{n.z.round(2)}) loops=#{fc.loops.length} " + pts.map { |p| p3(p) }.join(' ')
        fc.loops.each { |l| f.puts '     hole ' + l.vertices.map { |v| p3(v.position.transform(tr)) }.join(' ') unless l.outer? }
      end
    end
    f.puts '=== sill-like boxes (M05_Graphite_Haze, 6 faces) on the whole house'
    house.entities.grep(Sketchup::Group).each do |g|
      fs = g.entities.grep(Sketchup::Face)
      next unless fs.length.between?(5, 8) && fs.all? { |x| x.material && x.material.name == 'M05_Graphite_Haze' }
      b = g.bounds
      f.puts "  pid=#{g.persistent_id} def='#{g.definition.name}' bb #{p3(b.min.transform(ht))} #{p3(b.max.transform(ht))}"
    end
    f.puts '=== Material5 / Material6 usage'
    %w[Material5 Material6].each do |mn|
      mat = m.materials[mn]
      t = mat.texture
      f.puts "#{mn}: tex=#{t ? t.filename : '-'} size=#{t ? "#{t.width}x#{t.height}" : ''} px=#{t ? "#{t.image_width}x#{t.image_height}" : ''} colorize=#{mat.colorize_type} color=#{mat.color.to_a}"
      cnt = 0; area = 0.0; grp = 0; nonvert = 0
      walk = lambda do |ents|
        ents.each do |x|
          if x.is_a?(Sketchup::Face)
            if x.material == mat || x.back_material == mat then cnt += 1; area += x.area; nonvert += 1 if x.normal.z.abs > 0.01 end
          elsif x.is_a?(Sketchup::Group) || x.is_a?(Sketchup::ComponentInstance)
            grp += 1 if x.material == mat
            walk.call(x.definition.entities)
          end
        end
      end
      walk.call(m.entities)
      f.puts "  faces=#{cnt} area_sqft=#{(area / 144).round} non_vertical=#{nonvert} groups_painted=#{grp}"
    end
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
