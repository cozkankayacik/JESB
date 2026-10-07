# Read-only: plan segments of vertical faces at given heights (wall outline), driveway faces, garage wall/door data.
OUT = File.dirname(__FILE__)
ROOF_PIDS = [212244, 212299, 212342]

def collect(ents, tr, zs, out, tag)
  ents.each do |e|
    if e.is_a?(Sketchup::Face)
      n = e.normal.transform(tr)
      next unless n.z.abs < 0.01
      pts = e.outer_loop.vertices.map { |v| v.position.transform(tr) }
      zmin = pts.map(&:z).min; zmax = pts.map(&:z).max
      zs.each do |z|
        next unless zmin < z - 0.5 && zmax > z + 0.5
        xs = pts.map(&:x); ys = pts.map(&:y)
        out[z] << format('%s n=(%.0f,%.0f) x %.2f..%.2f y %.2f..%.2f z %.1f..%.1f', tag, n.x, n.y, xs.min, xs.max, ys.min, ys.max, zmin, zmax)
      end
    elsif e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      next if e.hidden? || !e.layer.visible?
      collect(e.definition.entities, tr * e.transformation, zs, out, tag)
    end
  end
end

def run
  m = Sketchup.active_model
  zs = [258.0, 135.0, 118.0]
  out = Hash.new { |h, k| h[k] = [] }
  m.entities.each do |e|
    next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    next if e.hidden? || !e.layer.visible? || ROOF_PIDS.include?(e.persistent_id)
    b = e.bounds
    next if b.max.x < 2600 || b.min.x > 3800 || b.width > 2000
    collect(e.definition.entities, e.transformation, zs, out, "pid#{e.persistent_id}/#{e.definition.name}")
  end
  File.open(File.join(OUT, 'walls.txt'), 'w') do |f|
    zs.each do |z|
      f.puts "=== z=#{z}"
      out[z].uniq.sort.each { |l| f.puts l }
    end
    f.puts '=== loose top-level faces (driveway etc.)'
    m.entities.grep(Sketchup::Face).each do |fc|
      b = fc.bounds
      f.puts format('F pid=%d mat=%s n=(%.0f,%.0f,%.0f) x %.2f..%.2f y %.2f..%.2f z %.2f..%.2f', fc.persistent_id, (fc.material ? fc.material.name : '-'), fc.normal.x, fc.normal.y, fc.normal.z, b.min.x, b.max.x, b.min.y, b.max.y, b.min.z, b.max.z)
    end
    f.puts '=== roof group children'
    [212244].each do |pid|
      g = m.find_entity_by_persistent_id(pid)
      g.entities.each { |c| f.puts "child #{c.typename} pid=#{c.persistent_id} name='#{c.respond_to?(:name) ? c.name : ''}' def='#{c.respond_to?(:definition) ? c.definition.name : ''}'" unless c.is_a?(Sketchup::Edge) || c.is_a?(Sketchup::Face) }
      f.puts "roof transform identity? #{g.transformation.identity?}"
    end
    f.puts "solid tools: union=#{Sketchup::Group.method_defined?(:union)} outer_shell=#{Sketchup::Group.method_defined?(:outer_shell)} pro=#{Sketchup.is_pro?}"
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
