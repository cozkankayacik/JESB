# JESB Lot 7 - model R19: no gaps at the wing gable side triangles (owner mark-up 20.10.2026, front elevation).
# R18 ended the white frieze above the triangles at z 225, but the dormer eave soffit is at 234.5 - 7.25 = 227.25, so a
# 2.25 in strip showed the faces behind (dark interior / window / siding). The frieze now runs from 216 up to the soffit
# and out to where the wing rake meets the soffit.
load File.join(File.dirname(__FILE__), 'common.rb')

WING_EAVE = 201.12; P9 = 0.75
SOFFIT = 234.5 - 7.25

run_edit([['qa_wing_gable_left', [-60, -230, 230], [25, 101, 215]],
          ['qa_wing_gable_right', [360, -230, 230], [275, 176, 215]],
          ['qa_wing_gable_front', [150, -260, 225], [150, 80, 222]]]) do |m|
  house = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /JESB_Lot7_House/ }
  raise 'house group not found' unless house
  house.name = "JESB_Lot7_House (#{CFG['rev']})"
  trim = m.materials['ACC Lot 7 - Trims - White']
  gx = find_groups(house.entities) { |g| g.name == 'Porch, terrace, slabs and trim' }.first
  raise 'trim group not found' unless gx
  old = find_groups(gx.entities) { |g| g.name =~ /dormer front frieze/ }
  old.each { |g| g.erase! if g.valid? }
  xl = 17.0 + (216.0 - WING_EAVE) / P9; xl2 = 17.0 + (SOFFIT - WING_EAVE) / P9
  xr = 282.96 - (216.0 - WING_EAVE) / P9; xr2 = 282.96 - (SOFFIT - WING_EAVE) / P9
  plate_y(gx.entities, 'Trim - dormer front frieze west', 101.3, [[16.9, 216.0], [xl, 216.0], [xl2, SOFFIT], [16.9, SOFFIT]], 0.0, 0.75, trim)
  plate_y(gx.entities, 'Trim - dormer front frieze east', 176.2, [[xr, 216.0], [282.0, 216.0], [282.0, SOFFIT], [xr2, SOFFIT]], 0.0, 0.75, trim)
  log format('friezes: replaced %d, now 216..%.2f, west x 16.9..%.1f, east x %.1f..282.0', old.length, SOFFIT, xl2, xr2)
end
