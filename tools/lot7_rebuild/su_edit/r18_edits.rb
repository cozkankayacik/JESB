# JESB Lot 7 - model R18: white siding only where Dominika wrote "white siding" (review 19.10.2026; owner 20.10.2026).
#  R16 had turned ALL lap siding white. R18:
#   - lap siding back to ACC Lot 7 Cobble Stone everywhere (material restored),
#   - white lap siding only on the marked areas: (1) the two small triangle walls beside the wing gable (front),
#     (2) the main garage gable (front, above the lower gable and the pent roof), (3) the south gablet.
#  The triangles (xelev front): the dormer bay front faces (DL y 101.3, x 16.9..; DR y 176.2, ..x 282) above the wing
#  rake, below a white frieze board 216..225 under the dormer eave. They are built as white-siding plates on those faces,
#  with the frieze board, so they read as drawn.
load File.join(File.dirname(__FILE__), 'common.rb')

WING_EAVE = 201.12; P9 = 0.75
def wing_w(x) WING_EAVE + P9 * (x - 17.0) end        # wing roof top surface, west slope (x < 150)
def wing_e(x) WING_EAVE + P9 * (282.96 - x) end      # east slope

run_edit([['qa_wing_gable_left', [-60, -230, 230], [25, 101, 215]],
          ['qa_wing_gable_right', [360, -230, 230], [275, 176, 215]],
          ['qa_garage_front', [76, -243, 250], [140, 40, 120]],
          ['qa_gablet_south', [1100, 715, 330], [637, 715, 285]]]) do |m|
  house = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /JESB_Lot7_House/ }
  raise 'house group not found' unless house
  house.name = "JESB_Lot7_House (#{CFG['rev']})"
  mt = m.materials
  trim = mt['ACC Lot 7 - Trims - White']

  # 1. restore Cobble Stone on the R16 siding material ------------------------------------------------------------
  sid = mt.find { |x| x.name =~ /White Lap \(James Hardie/ } || mt['ACC Lot 7 - Siding - Cobble Stone']
  raise 'siding material not found' unless sid
  sid.texture = CFG['cobble']; sid.texture.size = [13.6, 14.0]
  sid.name = 'ACC Lot 7 - Siding - Cobble Stone'
  # 2. white lap material for the marked areas ---------------------------------------------------------------------
  white = mt['Owner - Siding - White Lap (Dominika 19.10)'] || mt.add('Owner - Siding - White Lap (Dominika 19.10)')
  white.texture = CFG['white_lap']; white.texture.size = [13.6, 14.0]

  walls = find_groups(house.entities) { |g| g.name =~ /\AWall / }
  marked = walls.select do |g|
    b = g.bounds
    garage_gable = b.min.y > 15.5 && b.max.y < 27.0 && b.max.x < 276.5 && b.max.z > 150      # garage gable face y 16
    gablet = b.min.x > 633.0 && b.max.x < 638.5 && b.min.z > 250                          # south gablet infill
    garage_gable || gablet
  end
  n = 0
  marked.each do |g|
    g.entities.grep(Sketchup::Face).each do |f|
      next unless f.material == sid
      f.material = white; f.back_material = white; align_texture(f, white); n += 1
    end
  end
  log "white siding: #{n} faces on #{marked.map(&:name).join(', ')}"

  # 3. triangle walls beside the wing gable + frieze under the dormer eave ---------------------------------------
  gx = find_groups(house.entities) { |g| g.name == 'Porch, terrace, slabs and trim' }.first
  raise 'trim group not found' unless gx
  find_groups(gx.entities) { |g| g.name =~ /wing gable side triangle|dormer front frieze/ }.each { |g| g.erase! if g.valid? }
  xl = 17.0 + (216.0 - WING_EAVE) / P9               # west triangle: rake meets the frieze bottom
  xr = 282.96 - (216.0 - WING_EAVE) / P9
  plate_y(gx.entities, 'White siding - wing gable side triangle west', 101.3,
          [[16.9, wing_w(16.9)], [xl, 216.0], [16.9, 216.0]], 0.0, 0.5, white, 'A-WALL-EXT')
  plate_y(gx.entities, 'White siding - wing gable side triangle east', 176.2,
          [[282.0, wing_e(282.0)], [282.0, 216.0], [xr, 216.0]], 0.0, 0.5, white, 'A-WALL-EXT')
  xl2 = 17.0 + (225.0 - WING_EAVE) / P9; xr2 = 282.96 - (225.0 - WING_EAVE) / P9
  plate_y(gx.entities, 'Trim - dormer front frieze west', 101.3, [[16.9, 216.0], [xl, 216.0], [xl2, 225.0], [16.9, 225.0]], 0.0, 0.75, trim)
  plate_y(gx.entities, 'Trim - dormer front frieze east', 176.2, [[xr, 216.0], [282.0, 216.0], [282.0, 225.0], [xr2, 225.0]], 0.0, 0.75, trim)
  log format('triangles: west x 16.9..%.1f, east x %.1f..282.0, z rake..216; friezes 216..225', xl, xr)
end
