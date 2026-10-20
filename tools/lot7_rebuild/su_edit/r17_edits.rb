# JESB Lot 7 - model R17: edits on R16 (owner answers 20.10.2026 to the Dominika review questions).
#  Q2: all window and door headers white trim (was light beige cast stone, owner decision 17.10 - now reversed).
#  Q3: apex trim on the lower front gable too, same board + post as the wing and main garage gables (R15 D03).
#  Q5: the entry / eave white trim was already updated by the owner in their R15 edit - nothing to do here.
load File.join(File.dirname(__FILE__), 'common.rb')

GARAGE_EAVE = 105.62; FASCIA = 7.25; P9 = 0.75
BUMP_Y = 4.96                     # lower gable face (garage bump front)
def under_w(u) GARAGE_EAVE + P9 * (u - -7.0) - FASCIA end     # west rake underside of the lower gable
def under_e(u) GARAGE_EAVE + P9 * (149.7 - u) - FASCIA end    # east rake underside

run_edit([['qa_lower_gable_apex', [71, -260, 150], [71, 5, 140]],
          ['qa_garage_front', [76, -243, 250], [140, 40, 120]],
          ['qa_headers_front', [470, 120, 90], [470, 440, 70]]]) do |m|
  house = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /JESB_Lot7_House/ }
  raise 'house group not found' unless house
  house.name = "JESB_Lot7_House (#{CFG['rev']})"
  trim = m.materials['ACC Lot 7 - Trims - White']
  raise 'trim material missing' unless trim

  # Q2 ----------------------------------------------------------------------------------------------------------
  stone = m.materials['Owner - Cast Stone Window Header - Light Beige']
  if stone
    n = 0
    m.definitions.each { |d| d.entities.grep(Sketchup::Face).each { |f| n += 1 if f.material == stone } }
    stone.texture = nil
    stone.color = trim.color
    stone.name = 'Owner - Window and Door Headers - White Trim (owner 20.10)'
    log "Q2: headers recoloured to white trim (#{n} faces)"
  else
    log 'Q2: cast stone header material not found'
  end

  # Q3 ----------------------------------------------------------------------------------------------------------
  gx = find_groups(house.entities) { |g| g.name == 'Porch, terrace, slabs and trim' }.first
  raise 'trim group not found' unless gx
  old = find_groups(gx.entities) { |g| g.name =~ /Apex trim .* lower gable/ }
  old.each { |g| g.erase! if g.valid? }
  # same proportions as the other two gables: board 7.25 wide, bottom 27.8 in below the apex underside;
  # post 3.5 wide from 2 in above the board bottom to 3.15 in below the apex underside
  apex = 71.35; top = under_w(apex)
  b0, b1 = apex - 3.625, apex + 3.625; zb = top - 27.8
  board = [[b0, zb], [b1, zb], [b1, under_e(b1)], [apex, top], [b0, under_w(b0)]]
  plate_y(gx.entities, 'Apex trim board - lower gable', BUMP_Y, board, 0.0, 0.75, trim)
  plate_y(gx.entities, 'Apex trim post - lower gable', BUMP_Y,
          [[apex - 1.75, zb + 2.0], [apex + 1.75, zb + 2.0], [apex + 1.75, top - 3.15], [apex - 1.75, top - 3.15]], 0.75, 1.75, trim)
  log format('Q3: lower gable apex trim, board x %.2f..%.2f from z %.2f, apex underside %.2f', b0, b1, zb, top)
end
