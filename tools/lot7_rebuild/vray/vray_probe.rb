# Probe: dump the V-Ray scene of the opened model and export a .vrscene (to learn plugin names and parameters).
require 'json'
CFG = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'vray_config.json')))
LOG = []
def log(s) LOG << s.to_s; File.write(CFG['log'], LOG.join("\n")) end

def probe
  ctx = VRay::Context.active
  scene = ctx.scene
  log "context ok: #{ctx.class}"
  types = Hash.new(0)
  scene.each { |pl| types[pl.type] += 1 }
  log "plugin types: #{types.map { |k, v| "#{k}=#{v}" }.join(', ')}"
  File.write(File.join(CFG['work'], 'scene_dump.txt'), scene.dump)
  VRay::Command.export_vrscene(path: File.join(CFG['work'], 'probe.vrscene'), hex_arrays: false, hex_transforms: false)
  log 'vrscene exported'
  File.write(CFG['done'], 'ok')
rescue => ex
  log "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(8).join("\n")}"
  File.write(CFG['done'], 'ERR')
end

tries = 0
tid = UI.start_timer(3, true) do
  tries += 1
  ready = Sketchup.active_model && !Sketchup.active_model.path.to_s.empty? && defined?(VRay::Context)
  if ready
    UI.stop_timer(tid)
    UI.start_timer(15, false) { probe }
  elsif tries > 120
    UI.stop_timer(tid)
    File.write(CFG['done'], 'ERR not ready')
  end
end
