# JESB Lot 19 - horizontal cuts through the model's vertical faces at given heights -> JSON segments (model inches).
# Also dumps every roof-like face (shingle / metal materials, or sloped faces) as polygons. Nothing is saved.
require 'json'
OUT = File.dirname(__FILE__)
ZS = [60.0, 100.0, 180.0, 230.0].freeze
def run
  m = Sketchup.active_model
  cuts = Hash.new { |h, k| h[k] = [] }
  roofs = []
  walk = lambda do |ents, tr, path, inh|
    ents.each do |e|
      if e.is_a?(Sketchup::Face)
        mat = e.material || inh
        n = e.normal.transform(tr)
        pts = e.outer_loop.vertices.map { |v| v.position.transform(tr) }
        if n.z.abs < 0.05
          ZS.each do |z|
            ip = []
            pts.each_with_index do |a, i|
              b = pts[(i + 1) % pts.length]
              next if (a.z - z) * (b.z - z) > 0 || (a.z - b.z).abs < 1e-6
              t = (z - a.z) / (b.z - a.z)
              ip << [a.x + t * (b.x - a.x), a.y + t * (b.y - a.y)]
            end
            next if ip.length < 2
            ip = ip.sort_by { |p| [p[0], p[1]] }
            cuts[z] << [ip.first, ip.last, (mat ? mat.name : '-'), path].flatten
          end
        elsif n.z > 0.05 && n.z < 0.995 && e.area > 30
          roofs << { 'mat' => (mat ? mat.name : '-'), 'path' => path, 'n' => [n.x, n.y, n.z].map { |a| a.round(4) }, 'pts' => pts.map { |p| [p.x, p.y, p.z].map { |a| a.round(2) } } }
        end
      elsif e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
        next if e.hidden? || !e.layer.visible?
        next if e.definition.name =~ /Sree|\.dwg/i
        walk.call(e.definition.entities, tr * e.transformation, path + '/' + e.persistent_id.to_s, e.material || inh)
      end
    end
  end
  walk.call(m.entities, Geom::Transformation.new, '', nil)
  File.write(File.join(OUT, 'cuts.json'), JSON.generate({ 'cuts' => cuts, 'roofs' => roofs }))
  File.write(File.join(OUT, 'done.txt'), "ok #{cuts.map { |k, v| "#{k}:#{v.length}" }.join(' ')} roofs #{roofs.length}")
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
