# Probe the opened model: group tree (names, bounds, entity counts) and material use, written to probe.txt.
require 'json'
CFG = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'vray', 'vray_config.json')))
OUT = []
def walk(ents, depth, path)
  ents.each do |e|
    next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    bb = e.bounds
    name = e.is_a?(Sketchup::Group) ? e.name : "[C] #{e.definition.name}"
    sub = e.is_a?(Sketchup::Group) ? e.entities : e.definition.entities
    faces = sub.grep(Sketchup::Face)
    mats = faces.map { |f| f.material && f.material.name }.compact.tally
    OUT << format('%s%s | %s | bb x %.1f..%.1f y %.1f..%.1f z %.1f..%.1f | faces %d | layer %s | mats %s',
                  '  ' * depth, name, e.class.name.split('::').last, bb.min.x, bb.max.x, bb.min.y, bb.max.y, bb.min.z, bb.max.z,
                  faces.length, e.layer.name, mats.to_a.first(4).map { |k, v| "#{k}=#{v}" }.join(', '))
    walk(sub, depth + 1, path + [name]) if depth < 3
  end
end
def run
  m = Sketchup.active_model
  OUT << "model: #{m.path}"
  OUT << "top-level loose faces: #{m.entities.grep(Sketchup::Face).length}, edges: #{m.entities.grep(Sketchup::Edge).length}"
  walk(m.entities, 0, [])
  OUT << '--- materials'
  m.materials.each { |mt| OUT << "#{mt.name} | tex #{mt.texture ? File.basename(mt.texture.filename.to_s) : '-'} | color #{mt.color.to_a.first(3).join(',')}" }
  OUT << '--- scenes: ' + m.pages.map(&:name).join(', ')
  File.write(File.join(CFG['work'], 'probe.txt'), OUT.join("\n"))
  File.write(CFG['done'], 'ok')
rescue => ex
  File.write(CFG['done'], "ERR #{ex.message} #{ex.backtrace.first(3).join(' ')}")
end
tries = 0
tid = UI.start_timer(3, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid); UI.start_timer(5, false) { run }
  elsif tries > 100
    UI.stop_timer(tid); File.write(CFG['done'], 'ERR no model')
  end
end
