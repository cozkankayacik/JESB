# JESB Lot 7 - model R20 (owner 21.10.2026):
#  1. Covered terrace (patio) base wall in the same brick as the house walls (was white lap siding, R13). The base now
#     runs from the deck (-4) down to -100 like the house walls, so the terrain closes on it; the deck top keeps its
#     material.
#  2. All railings dark brown: entry and terrace stair railings (were black iron) and the terrace guardrail (was white).
#  3. Lawn under the rear terrace: the terrain grid had a hole under the terrace footprint (cells skipped), which showed
#     as an opening under the deck in the rear / side views. The skipped cells of the terrace and its stair are filled
#     with lawn at the grade of the surrounding terrain.
load File.join(File.dirname(__FILE__), 'common.rb')

TD = -4.0
TERR = [638.96, 783.3, 581.5, 847.7]          # raised terrace footprint
STAIR = [705.0, 760.0, 526.5, 581.5]          # terrace stair footprint
def inside?(r, x, y) x >= r[0] && x <= r[1] && y >= r[2] && y <= r[3] end

run_edit([['qa_terrace_rear', [1150, 1250, 60], [720, 720, -20]],
          ['qa_terrace_south', [1250, 500, 40], [720, 700, -20]],
          ['qa_entry_stair_SW', [700, 250, 60], [405, 415, -15]]]) do |m|
  house = m.entities.grep(Sketchup::Group).find { |g| g.name =~ /JESB_Lot7_House/ }
  raise 'house group not found' unless house
  house.name = "JESB_Lot7_House (#{CFG['rev']})"
  mt = m.materials
  brick = mt['ACC Lot 7 - Brick - Magnolia (US Brick)']; lawn = mt['Terrain - Lawn']; trim = mt['ACC Lot 7 - Trims - White']
  raise 'materials missing' unless brick && lawn && trim

  # 1. brick terrace base ----------------------------------------------------------------------------------------
  deck = find_groups(house.entities) { |g| g.name =~ /\ARaised terrace (deck|base)/ }.first
  raise 'terrace deck not found' unless deck
  top_face = deck.entities.grep(Sketchup::Face).find { |f| f.normal.z > 0.9 }
  top_mat = top_face && top_face.material
  parent = deck.parent.entities
  deck.erase!
  g = box(parent, 'Raised terrace base - brick (deck top unchanged)', TERR[0], TERR[1], TERR[2], TERR[3], -100.0, TD, brick, 'A-SLAB')
  t = g.entities.grep(Sketchup::Face).find { |f| f.normal.z > 0.9 }
  if t && top_mat then t.material = top_mat; t.back_material = top_mat; align_texture(t, top_mat) end
  log "terrace base: brick, -100..#{TD}; deck top kept as #{top_mat && top_mat.name}"

  # 2. railings dark brown -----------------------------------------------------------------------------------------
  brown = mt['Owner - Railings - Dark Brown'] || mt.add('Owner - Railings - Dark Brown')
  brown.color = Sketchup::Color.new(60, 44, 34)
  iron = mt['Not in ACC - Railing - Black Iron']
  n = 0
  rails = find_groups(house.entities) { |x| x.name =~ /railing|Terrace guard/i }
  rails.each do |r|
    r.entities.grep(Sketchup::Face).each do |f|
      next unless f.material == iron || f.material == trim
      f.material = brown; f.back_material = brown; n += 1
    end
  end
  if iron
    m.definitions.each { |d| d.entities.grep(Sketchup::Face).each { |f| (f.material = brown; f.back_material = brown; n += 1) if f.material == iron } }
  end
  log "railings: #{rails.length} groups, #{n} faces -> dark brown"

  # 3. lawn under the terrace --------------------------------------------------------------------------------------
  site = m.entities.grep(Sketchup::Group).find { |x| x.name =~ /\ASite/ }
  ter = site && site.entities.grep(Sketchup::Group).find { |x| x.name =~ /\ATerrain/ }
  raise 'terrain not found' unless ter
  zs = {}
  ter.entities.grep(Sketchup::Edge).each do |e|
    [e.start.position, e.end.position].each { |p| zs[[p.x.round, p.y.round]] = p.z.to_f if p.z > -99.0 }
  end
  known = zs.to_a
  zat = lambda do |x, y|
    return zs[[x, y]] if zs.key?([x, y])
    near = known.select { |(kx, ky), _| (kx - x).abs <= 96 && (ky - y).abs <= 96 }
    near = known if near.empty?
    wsum = 0.0; zsum = 0.0
    near.each { |(kx, ky), z| w = 1.0 / ((kx - x)**2 + (ky - y)**2 + 1.0); wsum += w; zsum += w * z }
    zsum / wsum
  end
  step = 24
  cnt = 0
  (624..792).step(step).each do |x0|
    (504..864).step(step).each do |y0|
      cx = x0 + step / 2.0; cy = y0 + step / 2.0
      next unless inside?(TERR, cx, cy) || inside?(STAIR, cx, cy)
      next if cx < 638.96                                     # house footprint
      pts = [[x0, y0], [x0 + step, y0], [x0 + step, y0 + step], [x0, y0 + step]].map { |x, y| pt(x, y, zat.(x, y)) }
      [[pts[0], pts[1], pts[2]], [pts[0], pts[2], pts[3]]].each do |tri|
        f = (ter.entities.add_face(*tri) rescue nil)
        next unless f
        f.reverse! if f.normal.z < 0
        f.material = lawn; f.back_material = lawn; cnt += 1
      end
    end
  end
  log "lawn under the terrace: #{cnt} triangles"

  # 4. same opening along the rear of the house: the grade at the rear wall falls to about -88..-107, below the wall
  #    bottoms (-84), and the terrain cells straddling the walls were skipped - so a white gap showed along the rear
  #    wall base next to the terrace. Brick footings down to -130 under the rear, south and north walls of the main
  #    block, and the skipped cells inside the house outline filled with lawn at grade (hidden under the house).
  [['Brick below grade - rear wall', 0.0, 638.96, 901.82, 912.32],
   ['Brick below grade - south wall', 628.46, 638.96, 429.36, 912.32],
   ['Brick below grade - north wall', 0.0, 10.5, 590.08, 912.32]].each do |nm, x0, x1, y0, y1|
    box(parent, nm, x0, x1, y0, y1, -130.0, -84.0, brick, 'A-WALL-EXT')
  end
  outline = [[0, 4.96], [137.68, 4.96], [137.68, 16.0], [276.0, 16.0], [276.0, 434.32], [362.96, 434.32], [362.96, 480.96],
             [448.96, 480.96], [448.96, 429.36], [638.96, 429.36], [638.96, 912.32], [0, 912.32], [0, 590.08], [-31.04, 590.08],
             [-31.04, 394.96], [0, 394.96]]
  in_poly = lambda do |x, y|
    c = false
    outline.each_with_index do |(x0, y0), i|
      x1, y1 = outline[(i + 1) % outline.length]
      c = !c if (y0 > y) != (y1 > y) && x < x0 + (y - y0) * (x1 - x0) / (y1 - y0)
    end
    c
  end
  cnt2 = 0
  (-48..672).step(step).each do |x0|
    (-24..936).step(step).each do |y0|
      next unless in_poly.(x0 + step / 2.0, y0 + step / 2.0)
      pts = [[x0, y0], [x0 + step, y0], [x0 + step, y0 + step], [x0, y0 + step]].map { |x, y| pt(x, y, zat.(x, y)) }
      [[pts[0], pts[1], pts[2]], [pts[0], pts[2], pts[3]]].each do |tri|
        f = (ter.entities.add_face(*tri) rescue nil)
        next unless f
        f.reverse! if f.normal.z < 0
        f.material = lawn; f.back_material = lawn; cnt2 += 1
      end
    end
  end
  log "lawn in the house-outline cells: #{cnt2} triangles; brick below grade on rear / south / north walls to -130"
end
