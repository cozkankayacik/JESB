# Shared helpers for the scripted edits on the owner's Lot 7 model (R17 on). Loaded by su_edit/r*_edits.rb, which run
# inside SketchUp on a copy of the model (tools/lot7_rebuild/vray/run_su.ps1 writes vray_config.json).
require 'json'
CFG = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'vray', 'vray_config.json')))
LOG = []
def log(s) LOG << s.to_s; File.write(CFG['log'], LOG.join("\n")) end
def pt(x, y, z) Geom::Point3d.new(x, y, z) end

def find_groups(ents, &blk)
  out = []
  ents.each do |e|
    next unless e.is_a?(Sketchup::Group)
    out << e if blk.call(e)
    out.concat(find_groups(e.entities, &blk))
  end
  out
end

# flat plate in a vertical plane y = c (outward normal -y): polygon of (x, z), from depth d0 to d1 in front of the face
def plate_y(ents, name, c, poly, d0, d1, mat, layer = 'A-TRIM')
  g = ents.add_group; g.name = name
  f = g.entities.add_face(poly.map { |x, z| pt(x, c - d0, z) })
  f.reverse! if f.normal.y > 0
  f.pushpull(d1 - d0)
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g.layer = layer
  g
end

# standard exports (same cameras / export_meta as build_r01.rb, so overlay_check.py works) + QA close-ups
def export_views(m, qa_views)
  v = m.active_view
  out = CFG['export_dir']; Dir.mkdir(out) unless File.directory?(out)
  cx, cy, cz = 376.0, 457.0, 165.0
  eh = 620.0; ew_px = 3200; eh_px = 1850; d = 6000.0
  ro = m.rendering_options
  ro['DrawSilhouettes'] = true; ro['DisplayColorByLayer'] = false
  m.shadow_info['DisplayShadows'] = false
  ro['DrawHorizon'] = false; ro['DrawGround'] = false; ro['BackgroundColor'] = Sketchup::Color.new(255, 255, 255)
  File.write(File.join(out, 'export_meta.json'), JSON.generate({ 'cx' => cx, 'cy' => cy, 'cz' => cz, 'height' => eh, 'w' => ew_px, 'h' => eh_px }))
  [['Elevation_Front_West', [cx, cy - d, cz]], ['Elevation_Rear_East', [cx, cy + d, cz]],
   ['Elevation_Right_South', [cx + d, cy, cz]], ['Elevation_Left_North', [cx - d, cy, cz]]].each do |name, eye|
    cam = Sketchup::Camera.new(eye, [cx, cy, cz], [0, 0, 1]); cam.perspective = false; cam.height = eh
    v.camera = cam
    v.write_image(filename: File.join(out, "JESB_Lot7_#{CFG['rev']}_#{name}.png"), width: ew_px, height: eh_px, antialias: true, transparent: false)
  end
  cam = Sketchup::Camera.new([cx, cy, cz + d], [cx, cy, cz], [0, 1, 0]); cam.perspective = false; cam.height = 1100.0
  v.camera = cam
  site = m.entities.find { |e| e.is_a?(Sketchup::Group) && e.name.start_with?('Site') }
  site.hidden = true if site
  v.write_image(filename: File.join(out, "JESB_Lot7_#{CFG['rev']}_Roof_Plan.png"), width: 2400, height: 2400, antialias: true, transparent: false)
  site.hidden = false if site
  ro['DrawHorizon'] = true
  [['Perspective_Front_SW', [cx + 1150, cy - 1450, 560], [cx - 30, cy - 60, 110]],
   ['Perspective_Front_NW', [cx - 1300, cy - 1300, 600], [cx + 10, cy - 60, 110]],
   ['Perspective_Rear_SE', [cx + 1350, cy + 1350, 640], [cx, cy + 60, 90]],
   ['Perspective_Rear_NE', [cx - 1250, cy + 1400, 600], [cx, cy + 40, 90]]].each do |name, eye, tg|
    cam = Sketchup::Camera.new(eye, tg, [0, 0, 1]); cam.perspective = true; cam.fov = 35.0
    v.camera = cam
    v.write_image(filename: File.join(out, "JESB_Lot7_#{CFG['rev']}_#{name}.png"), width: 2400, height: 1500, antialias: true, transparent: false)
  end
  qa = File.join(out, 'QA_Detail_Views'); Dir.mkdir(qa) unless File.directory?(qa)
  qa_views.each do |name, eye, tg|
    cam = Sketchup::Camera.new(eye, tg, [0, 0, 1]); cam.perspective = true; cam.fov = 40.0
    v.camera = cam
    v.write_image(filename: File.join(qa, name + '.png'), width: 1600, height: 1000, antialias: true, transparent: false)
  end
  pg = m.pages['Perspective Front SW']
  if pg then m.pages.selected_page = pg; v.camera = pg.camera end
  log "exports written to #{out}"
end

# wait for the model, run the edit block, export, save as CFG['save_as']
def run_edit(qa_views, &edit)
  tries = 0
  tid = UI.start_timer(3, true) do
    tries += 1
    if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
      UI.stop_timer(tid)
      UI.start_timer(6, false) do
        begin
          m = Sketchup.active_model
          m.start_operation("JESB Lot 7 #{CFG['rev']}", true)
          edit.call(m)
          m.commit_operation
          export_views(m, qa_views)
          ok = m.save(CFG['save_as'])
          log "saved #{ok}: #{CFG['save_as']}"
          File.write(CFG['done'], 'ok')
        rescue => ex
          log "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(8).join("\n")}"
          File.write(CFG['done'], 'ERR')
        end
      end
    elsif tries > 100
      UI.stop_timer(tid); File.write(CFG['done'], 'ERR no model')
    end
  end
end
