# JESB Lot 7 - model R16: edits applied to the OWNER'S updated R15 model (17:30, 20.10.2026), so their own changes are
# kept (the R01-R15 generator is NOT re-run). Runs inside SketchUp on a copy (tools/lot7_rebuild/vray/run_su.ps1),
# saves as R16 and writes the standard exports (same cameras / export_meta as build_r01.rb, for the DWG overlays).
#  1. White siding (Dominika 19.10, "white siding"; DWG note "James Hardie siding - Arctic White or eq., typ."): the lap
#     siding material is switched from ACC Cobble Stone to white lap (same texture size, so the face mapping stays).
#  2. Entry steps per the xelev elevations (front: widths and risers; south: tread positions):
#     porch -7.5 (door threshold 0..-7.5), 4 risers ~7.6 / treads 10 in: -15.1 (y 423.3..433.3, between the piers),
#     -22.75 (413.3..423.3, widened to x 356..456 in front of the piers), -30.25 (403.3..413.3, x 356..456), grade -38.1;
#     iron rails on the wide steps from the bottom nosing to the pier fronts.
#  3. Garage bump corner (Dominika "please check blueprint", xelev front / south): brick base up to the sill course
#     (rowlock 22.87..24.87, wrapping front and side), white 5.5 in corner boards from the sill course to the frieze,
#     frieze board on the bump side 91.12..98.37.
#  4. Lawn patch where the old, longer entry stair stood (terrain hole y 360..408).
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

def align_texture(f, mat)
  return unless mat && mat.texture
  n = f.normal
  u = n.z.abs > 0.999 ? Geom::Vector3d.new(1, 0, 0) : Geom::Vector3d.new(0, 0, 1).cross(n)
  u.normalize!
  up = n.cross(u); up.normalize!
  up.reverse! if n.z.abs <= 0.999 && up.z < 0
  p0 = f.vertices.first.position
  f.position_material(mat, [p0, [0, 0], p0.offset(u, mat.texture.width), [1, 0], p0.offset(up, mat.texture.height), [0, 1]], true)
end

def box(ents, name, x0, x1, y0, y1, z0, z1, mat, layer)
  g = ents.add_group; g.name = name
  f = g.entities.add_face(pt(x0, y0, z0), pt(x1, y0, z0), pt(x1, y1, z0), pt(x0, y1, z0))
  f.reverse! if f.normal.z > 0
  f.pushpull(-(z1 - z0))
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat; align_texture(x, mat) }
  g.layer = layer if layer
  g
end

def sloped_bar(ents, name, x0, x1, ya, yb, za, zb, h, mat)
  g = ents.add_group; g.name = name
  f = g.entities.add_face(pt(x0, ya, za), pt(x0, yb, zb), pt(x0, yb, zb + h), pt(x0, ya, za + h))
  f.reverse! if f.normal.x < 0
  f.pushpull(x1 - x0)
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g
end

def stair_rail(gx, gs, name, xc, y_lo, y_hi, z_lo, z_hi, h_top, iron)
  k = (z_hi - z_lo) / (y_hi - y_lo)
  nose = ->(y) { z_lo + k * (y - y_lo) }
  x0, x1 = xc - 0.75, xc + 0.75
  sloped_bar(gs, name + ' top rail', x0, x1, y_lo, y_hi, nose.(y_lo) + h_top - 1.5, nose.(y_hi) + h_top - 1.5, 1.5, iron)
  sloped_bar(gs, name + ' second rail', x0, x1, y_lo, y_hi, nose.(y_lo) + h_top - 6.0, nose.(y_hi) + h_top - 6.0, 0.75, iron)
  sloped_bar(gs, name + ' ring band', xc - 0.3, xc + 0.3, y_lo, y_hi, nose.(y_lo) + h_top - 5.25, nose.(y_hi) + h_top - 5.25, 3.75, iron)
  sloped_bar(gs, name + ' bottom rail', x0, x1, y_lo, y_hi, nose.(y_lo) + 3.0, nose.(y_hi) + 3.0, 1.0, iron)
  n = ((y_hi - y_lo - 4.0) / 5.0).floor
  (1..n).each do |i|
    y = y_lo + 2.0 + i * (y_hi - y_lo - 4.0) / (n + 1)
    box(gx, name + ' picket', xc - 0.31, xc + 0.31, y - 0.31, y + 0.31, nose.(y) + 4.0, nose.(y) + h_top - 6.0, iron, 'A-STAIR')
  end
  box(gx, name + ' newel post', xc - 1.5, xc + 1.5, y_lo - 1.5, y_lo + 1.5, nose.(y_lo) - 30.0, nose.(y_lo) + h_top + 3.0, iron, 'A-STAIR')
  box(gx, name + ' newel post', xc - 1.5, xc + 1.5, y_hi - 1.5, y_hi + 1.5, nose.(y_hi) - 6.0, nose.(y_hi) + h_top + 3.0, iron, 'A-STAIR')
end

def export_views(m)
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
  [['qa_entry_stair_front', [406, 150, 40], [406, 430, -10]], ['qa_entry_stair_SW', [700, 250, 60], [405, 415, -15]],
   ['qa_garage_bump_corner', [330, -150, 60], [138, 10, 50]], ['qa_garage_front', [cx - 300, cy - 700, 250], [140, 40, 120]],
   ['qa_wing_gable_siding', [150, -500, 260], [150, 60, 220]]].each do |name, eye, tg|
    cam = Sketchup::Camera.new(eye, tg, [0, 0, 1]); cam.perspective = true; cam.fov = 40.0
    v.camera = cam
    v.write_image(filename: File.join(qa, name + '.png'), width: 1600, height: 1000, antialias: true, transparent: false)
  end
  pg = m.pages['Perspective Front SW']
  if pg then m.pages.selected_page = pg; v.camera = pg.camera end
  log "exports written to #{out}"
end

def run
  m = Sketchup.active_model
  m.start_operation("JESB Lot 7 #{CFG['rev']}", true)
  house = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /JESB_Lot7_House/ }
  raise 'house group not found' unless house
  house.name = "JESB_Lot7_House (#{CFG['rev']})"
  mt = m.materials
  brick = mt['ACC Lot 7 - Brick - Magnolia (US Brick)']; trim = mt['ACC Lot 7 - Trims - White']
  conc = mt['Concrete']; iron = mt['Not in ACC - Railing - Black Iron']; lawn = mt['Terrain - Lawn']
  raise 'materials missing' unless brick && trim && conc && iron && lawn

  # 1. white siding ---------------------------------------------------------------------------------------------
  sid = mt['ACC Lot 7 - Siding - Cobble Stone']
  if sid
    n = 0
    m.definitions.each { |d| d.entities.grep(Sketchup::Face).each { |f| n += 1 if f.material == sid || f.back_material == sid } }
    sid.texture = CFG['white_lap']; sid.texture.size = [13.6, 14.0]
    sid.name = 'Owner - Siding - White Lap (James Hardie Arctic White per DWG, Dominika 19.10)'
    log "siding: Cobble Stone -> white lap on #{n} faces"
  else
    log 'siding: Cobble Stone material not found (already changed?)'
  end

  # 2. entry steps ------------------------------------------------------------------------------------------------
  old = find_groups(house.entities) { |g| g.name =~ /\A(Porch stoop|Porch step \d|Entry stair railing)/ }
  log "entry: removing #{old.length} old groups (stoop, 5 steps, railings)"
  old.each { |g| g.erase! if g.valid? }
  gx = find_groups(house.entities) { |g| g.name == 'Porch, terrace, slabs and trim' }.first
  gs = find_groups(house.entities) { |g| g.name == 'Stair railings' }.first
  raise 'trim / railing groups not found' unless gx && gs
  ge = gx.entities; se = gs.entities
  box(ge, 'Porch floor (xelev -7.5)', 362.96, 448.96, 433.3, 480.96, -40.0, -7.5, conc, 'A-SLAB')
  box(ge, 'Entry door threshold step', 369.85, 441.85, 469.96, 480.96, -7.5, 0.0, conc, 'A-STAIR')
  box(ge, 'Entry step 1 (-15.1)', 362.96, 448.96, 423.3, 433.3, -40.0, -15.1, conc, 'A-STAIR')
  box(ge, 'Entry step 2 (-22.75)', 362.96, 448.96, 413.3, 423.3, -40.0, -22.75, conc, 'A-STAIR')
  box(ge, 'Entry step 2 (-22.75) west flare', 356.0, 362.96, 413.3, 420.32, -40.0, -22.75, conc, 'A-STAIR')
  box(ge, 'Entry step 2 (-22.75) east flare', 448.96, 456.0, 413.3, 420.32, -40.0, -22.75, conc, 'A-STAIR')
  box(ge, 'Entry step 3 (-30.25)', 356.0, 456.0, 403.3, 413.3, -40.0, -30.25, conc, 'A-STAIR')
  [[358.0, 'west'], [454.0, 'east']].each do |xc, side|
    stair_rail(ge, se, "Entry stair railing #{side}", xc, 403.3, 418.8, -30.25, -30.25 + 0.76 * 15.5, 33.0, iron)
  end
  log 'entry: porch -7.5, threshold, 3 steps (2 flared), 2 railings'

  # 3. garage bump corner -----------------------------------------------------------------------------------------
  # brick skin 16.7..22.87 just proud of the bump front panel (y 4.96), sill course and water table wrapping the corner
  box(ge, 'Bump brick base 16.7-22.87', 0.0, 137.68, 4.71, 4.96, 16.7, 22.87, brick, 'A-WALL-EXT')
  box(ge, 'Sill course (rowlock) - bump front', -1.0, 139.68, 2.96, 4.96, 22.87, 24.87, brick, 'A-TRIM')
  box(ge, 'Sill course (rowlock) - bump side', 137.68, 139.68, 4.96, 16.0, 22.87, 24.87, brick, 'A-TRIM')
  box(ge, 'Water table (rowlock) - bump side', 137.68, 138.68, 3.96, 16.0, 12.21, 14.87, brick, 'A-TRIM')
  box(ge, 'Corner board - bump north', 0.0, 5.5, 4.21, 4.96, 24.87, 98.37, trim, 'A-TRIM')
  box(ge, 'Corner board - bump south (front)', 132.18, 137.68, 4.21, 4.96, 24.87, 98.37, trim, 'A-TRIM')
  box(ge, 'Corner board - bump south (side)', 137.68, 138.43, 4.21, 10.46, 24.87, 98.37, trim, 'A-TRIM')
  box(ge, 'Frieze board - bump side', 137.68, 138.68, 3.96, 16.0, 91.12, 98.37, trim, 'A-TRIM')
  log 'bump corner: brick base to 22.87, sill course + water table wrapped, corner boards, frieze'

  # 4. lawn patch -------------------------------------------------------------------------------------------------
  site = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /\ASite/ }
  ter = site && site.entities.grep(Sketchup::Group).find { |g| g.name =~ /\ATerrain/ }
  if ter
    zs = {}
    ter.entities.grep(Sketchup::Edge).each do |e|
      [e.start.position, e.end.position].each { |p| zs[[p.x.round, p.y.round]] = p.z.to_f if p.z > -99 }
    end
    xs = [360, 384, 408, 432, 456]; ys = [360, 384, 408]
    known = (xs.product(ys)).map { |k| zs[k] }.compact
    zdef = known.empty? ? -38.1 : known.sum / known.length
    zf = ->(x, y) { zs[[x, y]] || zdef }
    cnt = 0
    xs.each_cons(2) do |x0, x1|
      ys.each_cons(2) do |y0, y1|
        a = pt(x0, y0, zf.(x0, y0)); b = pt(x1, y0, zf.(x1, y0)); c = pt(x1, y1, zf.(x1, y1)); dd = pt(x0, y1, zf.(x0, y1))
        [[a, b, c], [a, c, dd]].each do |tri|
          f = ter.entities.add_face(*tri) rescue nil
          next unless f
          f.reverse! if f.normal.z < 0
          f.material = lawn; f.back_material = lawn; cnt += 1
        end
      end
    end
    log "lawn patch: #{cnt} triangles (known grid z #{known.length}, default #{zdef.round(2)})"
  else
    log 'lawn patch: terrain group not found'
  end
  m.commit_operation
  export_views(m)
  ok = m.save(CFG['save_as'])
  log "saved #{ok}: #{CFG['save_as']}"
  File.write(CFG['done'], 'ok')
rescue => ex
  log "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(8).join("\n")}"
  File.write(CFG['done'], 'ERR')
end

tries = 0
tid = UI.start_timer(3, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid); UI.start_timer(6, false) { run }
  elsif tries > 100
    UI.stop_timer(tid); File.write(CFG['done'], 'ERR no model')
  end
end
