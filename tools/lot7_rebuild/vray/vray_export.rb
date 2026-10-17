# JESB Lot 7 - export the working model to a .vrscene for V-Ray standalone (runs inside SketchUp on a COPY of the
# model, see run_su.ps1). The model's scenes (Elevation Front West, ...) become V-Ray cameras (vray.exe -camera=).
# Only render-side changes are made on the copy: lawn / terrain-section texture, output size. The model is not saved.
require 'json'
CFG = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'vray_config.json')))
LOG = []
def log(s) LOG << s.to_s; File.write(CFG['log'], LOG.join("\n")) end

def export
  m = Sketchup.active_model
  grass = CFG['grass_texture']
  ['Terrain - Section', 'Terrain - Lawn'].each do |n|
    mat = m.materials[n]
    next unless mat && grass && File.exist?(grass)
    mat.texture = grass
    mat.texture.size = [60, 60]
    log "texture #{n} <- #{File.basename(grass)}"
  end
  ctx = VRay::Context.active
  scene = ctx.scene
  w, h = CFG['width'], CFG['height']
  scene.change do
    so = scene['/SettingsOutput']
    so[:img_width] = w
    so[:img_height] = h
  end
  log "output #{w} x #{h}"
  VRay::Command.export_vrscene(path: CFG['vrscene'], hex_arrays: true, hex_transforms: false)
  log "vrscene exported: #{CFG['vrscene']}"
  File.write(CFG['done'], 'ok')
rescue => ex
  log "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(8).join("\n")}"
  File.write(CFG['done'], 'ERR')
end

tries = 0
tid = UI.start_timer(3, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty? && defined?(VRay::Context)
    UI.stop_timer(tid)
    UI.start_timer(15, false) { export }
  elsif tries > 120
    UI.stop_timer(tid)
    File.write(CFG['done'], 'ERR not ready')
  end
end
