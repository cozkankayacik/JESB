# JESB Lot 7 - exterior model R01 builder.
# Reads r01_spec.json (tools/lot7_rebuild/lot7_r01.py) and builds the model from scratch in a copy of the owner's
# file (its materials/textures are reused, all its geometry is removed). Paths come from run_config.json next to
# this script. Model units: inches; plan coordinates = DWG plan inches; z = 0 at the top of the main floor.
require 'json'
HERE = File.dirname(__FILE__)
CFG = JSON.parse(File.read(File.join(HERE, 'run_config.json')))
SPEC = JSON.parse(File.read(CFG['spec']))
LOGF = CFG['log']
LOG = []
def log(s)
  LOG << s
  File.write(LOGF, LOG.join("\n"))
end
def pt(x, y, z) Geom::Point3d.new(x, y, z) end

# ------------------------------------------------------------------------------------------------ materials
def color_mat(m, name, rgb, alpha = 1.0)
  mat = m.materials[name] || m.materials.add(name)
  mat.texture = nil if mat.texture && rgb
  mat.color = Sketchup::Color.new(*rgb) if rgb
  mat.alpha = alpha
  mat
end
def tex_mat(m, name, src, fallback_rgb, size = nil)
  mat = m.materials[name] || m.materials.add(name)
  s = src && m.materials[src]
  if s && s.texture
    tmp = File.join(CFG['tmp'], "tex_#{src.gsub(/\W/, '_')}.png")
    s.texture.write(tmp)
    mat.texture = tmp
    mat.texture.size = size if size
    mat.color = s.color unless s.texture
  elsif CFG['textures'] && CFG['textures'][name] && File.exist?(CFG['textures'][name])
    mat.texture = CFG['textures'][name]
    mat.texture.size = size if size
  else
    mat.color = Sketchup::Color.new(*fallback_rgb)
  end
  mat
end

def tags(m)
  %w[A-WALL-EXT A-ROOF A-TRIM A-WIND A-DOOR A-SLAB A-STAIR A-FLOOR L-TOPO L-SITE].each { |t| m.layers.add(t) }
end

# ------------------------------------------------------------------------------------------------ helpers
def merge_coplanar(ents)
  loop do
    dead = ents.grep(Sketchup::Edge).select { |e| e.faces.length == 2 && e.faces[0].normal.dot(e.faces[1].normal) > 0.99999 && e.faces[0].material == e.faces[1].material && (e.faces[0].plane[3] - e.faces[1].plane[3]).abs < 0.05 }
    break if dead.empty?
    ents.erase_entities(dead)
  end
  stray = ents.grep(Sketchup::Edge).select { |e| e.faces.empty? }
  ents.erase_entities(stray) unless stray.empty?
end

def box(ents, name, x0, x1, y0, y1, z0, z1, mat, layer)
  g = ents.add_group; g.name = name
  f = g.entities.add_face(pt(x0, y0, z0), pt(x1, y0, z0), pt(x1, y1, z0), pt(x0, y1, z0))
  f.reverse! if f.normal.z > 0
  f.pushpull(-(z1 - z0))
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g.layer = layer if layer
  g
end

# bar running along y with a sloped bottom: section (x0..x1) x h, bottom z linear from za at ya to zb at yb
def sloped_bar(ents, name, x0, x1, ya, yb, za, zb, h, mat)
  g = ents.add_group; g.name = name
  f = g.entities.add_face(pt(x0, ya, za), pt(x0, yb, zb), pt(x0, yb, zb + h), pt(x0, ya, za + h))
  f.reverse! if f.normal.x < 0
  f.pushpull(x1 - x0)
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g
end

def align_texture(f, mat)
  return unless mat && mat.texture
  n = f.normal
  if n.z.abs > 0.999
    u = Geom::Vector3d.new(1, 0, 0)
  else
    u = Geom::Vector3d.new(0, 0, 1).cross(n); u.normalize!
  end
  up = n.cross(u); up.normalize!
  up.reverse! if n.z.abs <= 0.999 && up.z < 0
  p0 = f.vertices.first.position
  tw = mat.texture.width; th = mat.texture.height
  f.position_material(mat, [p0, [0, 0], p0.offset(u, tw), [1, 0], p0.offset(up, th), [0, 1]], true)
end

# ------------------------------------------------------------------------------------------------ roofs
def build_roof(parent, spec, mats)
  t = spec['thickness']
  down = Geom::Vector3d.new(0, 0, -t)
  bad = 0
  # 1. underside (soffit) + edge boards (fascia / rake), straight from the spec (free edges computed in Python)
  bg = parent.add_group; bg.name = spec['name'] + ' - fascia and soffit'; be = bg.entities
  spec['faces'].each do |fc|
    begin
      be.add_face(fc['pts'].map { |p| pt(*p).offset(down) })
    rescue => ex
      bad += 1
    end
  end
  spec['free_edges'].each do |a, b|
    begin
      pa = pt(*a); pb = pt(*b)
      be.add_face(pa, pb, pb.offset(down), pa.offset(down))
    rescue => ex
      bad += 1
    end
  end
  be.grep(Sketchup::Face).each do |f|
    if f.normal.z.abs > 0.05
      f.reverse! if f.normal.z > 0
      f.material = mats['soffit']; f.back_material = mats['soffit']
    else
      f.material = mats['fascia']; f.back_material = mats['fascia']
    end
  end
  # 2. roof surface
  tg = parent.add_group; tg.name = spec['name'] + ' - surface'; ents = tg.entities
  spec['faces'].each do |fc|
    begin
      f = ents.add_face(fc['pts'].map { |p| pt(*p) })
      f.reverse! if f.normal.z < 0
      f.material = mats[fc['mat']] || mats['shingle']; f.back_material = mats['soffit']
    rescue => ex
      bad += 1
    end
  end
  merge_coplanar(ents)
  ents.grep(Sketchup::Face).each { |f| align_texture(f, f.material) }
  bg.layer = 'A-ROOF'; tg.layer = 'A-ROOF'
  log format('roof %-26s surface faces %4d, under/edge faces %4d, failed %d', spec['name'],
             ents.grep(Sketchup::Face).length, be.grep(Sketchup::Face).length, bad)
  tg
end

# ------------------------------------------------------------------------------------------------ walls
def wpt(w, u, z, d = 0.0)
  # d = depth into the wall (positive inward)
  n = w['n']
  if w['axis'] == 'x' then pt(u, w['c'] - n[1] * d, z) else pt(w['c'] - n[0] * d, u, z) end
end

def build_wall(parent, w, mats, idx)
  g = parent.add_group
  g.name = format('Wall %s %s %d (%.0f..%.0f)', w['floor'], w['view'], idx, w['a'], w['b'])
  ents = g.entities
  outer = [wpt(w, w['a'], w['zb']), wpt(w, w['b'], w['zb'])] + w['top'].reverse.map { |u, z| wpt(w, u, z) }
  outer = outer.each_with_object([]) { |p, acc| acc << p if acc.empty? || acc[-1].distance(p) > 0.01 }
  outer.pop if outer.length > 2 && outer[-1].distance(outer[0]) < 0.01
  f = ents.add_face(outer)
  w['openings'].each do |o|
    z0 = [o['z0'], w['zb'] + 0.5].max
    h = ents.add_face(wpt(w, o['a'], z0), wpt(w, o['b'], z0), wpt(w, o['b'], o['z1']), wpt(w, o['a'], o['z1']))
    ents.erase_entities(h) if h && h.valid?
  end
  f = ents.grep(Sketchup::Face).max_by(&:area)
  nv = Geom::Vector3d.new(w['n'][0], w['n'][1], 0)
  f.reverse! if f.normal.dot(nv) < 0
  f.pushpull(-w['thick'])
  mat = mats[w['mat']]
  ents.grep(Sketchup::Face).each do |x|
    d = x.normal.dot(nv)
    if d < -0.999
      x.material = mats['interior']; x.back_material = mats['interior']
    else
      x.material = mat; x.back_material = mat
      align_texture(x, mat) if d > 0.999
    end
  end
  g.layer = 'A-WALL-EXT'
  g
end

# ------------------------------------------------------------------------------------------------ windows / doors
def frame_ring(ents, w, a, b, z0, z1, fw, d0, d1, mat)
  # rectangular frame ring of width fw in the opening, from depth d0 to d1
  o = [wpt(w, a, z0, d0), wpt(w, b, z0, d0), wpt(w, b, z1, d0), wpt(w, a, z1, d0)]
  f = ents.add_face(o)
  h = ents.add_face(wpt(w, a + fw, z0 + fw, d0), wpt(w, b - fw, z0 + fw, d0), wpt(w, b - fw, z1 - fw, d0), wpt(w, a + fw, z1 - fw, d0))
  ents.erase_entities(h) if h && h.valid?
  f = ents.grep(Sketchup::Face).select { |x| x.valid? }.max_by(&:area)
  nv = Geom::Vector3d.new(w['n'][0], w['n'][1], 0)
  f.reverse! if f.normal.dot(nv) < 0
  f.pushpull(-(d1 - d0))
end

def bar(ents, w, a, b, z0, z1, d0, d1, mat)
  g = ents.add_group
  f = g.entities.add_face(wpt(w, a, z0, d0), wpt(w, b, z0, d0), wpt(w, b, z1, d0), wpt(w, a, z1, d0))
  nv = Geom::Vector3d.new(w['n'][0], w['n'][1], 0)
  f.reverse! if f.normal.dot(nv) < 0
  f.pushpull(-(d1 - d0))
  g.entities.grep(Sketchup::Face).each { |x| x.material = mat; x.back_material = mat }
  g
end

def glass(ents, w, a, b, z0, z1, d, mat)
  f = ents.add_face(wpt(w, a, z0, d), wpt(w, b, z0, d), wpt(w, b, z1, d), wpt(w, a, z1, d))
  f.material = mat; f.back_material = mat
end

def build_opening_unit(parent, w, o, mats)
  g = parent.add_group
  a, b, z0, z1 = o['a'], o['b'], o['z0'], o['z1']
  width = b - a; ht = z1 - z0
  kind = o['kind']
  e = g.entities
  inset = 3.0
  case kind
  when 'garage8', 'garage16'
    g.name = format('Garage door %s (%.0fx%.0f)', kind == 'garage8' ? "8'x8'" : "16'x8'", width, ht)
    bar(e, w, a, b, z0, z1, inset, inset + 2.0, mats['garage'])
    # four sections, top section with glass lites (ACC: cottage with glass on top)
    sec = ht / 4.0
    (1..3).each { |i| bar(e, w, a + 1, b - 1, z0 + sec * i - 0.4, z0 + sec * i + 0.4, inset - 0.3, inset, mats['garage_groove']) }
    n = kind == 'garage8' ? 4 : 8
    lw = (width - 6.0 - (n - 1) * 3.0) / n
    n.times do |i|
      la = a + 3.0 + i * (lw + 3.0)
      glass(e, w, la, la + lw, z0 + sec * 3 + 3.0, z1 - 4.0, inset - 0.2, mats['glass'])
    end
    # cottage vertical boards on the three lower sections
    nb = kind == 'garage8' ? 3 : 6
    (1...nb).each { |i| u = a + width * i / nb; bar(e, w, u - 0.4, u + 0.4, z0 + 1, z0 + sec * 3 - 1, inset - 0.3, inset, mats['garage_groove']) }
    g.layer = 'A-DOOR'
  when 'entry'
    g.name = 'Entry door 3080 with (2) 1680 side lights and transom'
    frame_ring(e, w, a, b, z0, z1, 2.5, inset, inset + 4.0, mats['frame'])
    dl = (a + b) / 2.0 - 18.0; dr = dl + 36.0
    bar(e, w, dl - 1.5, dl, z0, 96.0, inset, inset + 4.0, mats['frame'])
    bar(e, w, dr, dr + 1.5, z0, 96.0, inset, inset + 4.0, mats['frame'])
    bar(e, w, a + 2.5, b - 2.5, 96.0, 98.0, inset, inset + 4.0, mats['frame'])
    bar(e, w, dl, dr, z0, 96.0, inset + 1.0, inset + 3.0, mats['door'])
    glass(e, w, a + 2.5, dl - 1.5, z0 + 2.5, 96.0, inset + 2.0, mats['glass'])
    glass(e, w, dr + 1.5, b - 2.5, z0 + 2.5, 96.0, inset + 2.0, mats['glass'])
    glass(e, w, a + 2.5, b - 2.5, 98.0, z1 - 2.5, inset + 2.0, mats['glass'])
    g.layer = 'A-DOOR'
  else
    door = (kind == 'slider')
    g.name = format('%s %.0fx%.0f', door ? 'Sliding glass door' : 'Window', width, ht)
    fw = door ? 3.0 : 2.5
    frame_ring(e, w, a, b, z0, z1, fw, inset, inset + 4.0, mats['frame'])
    # twin units: frame mullion between them (xelev draws pairs as two units)
    units = width > 50 ? 2 : 1
    m = (a + b) / 2.0
    bar(e, w, m - 1.25, m + 1.25, z0 + fw, z1 - fw, inset, inset + 4.0, mats['frame']) if units == 2
    glass(e, w, a + fw, b - fw, z0 + fw, z1 - fw, inset + 2.0, mats['glass'])
    # thin grid muntins as on the elevations (xelev): one vertical and one horizontal bar per unit (4 lites);
    # sliding door: cross per panel at the drawn height 48; basement windows below grade: none
    if z1 > 0
      mw = 0.75
      # stacked units (o['rows'] = split heights): 2 in frame transom at each split, a cross grid in every unit
      splits = (o['rows'] || []).sort
      splits.each { |zs| bar(e, w, a + fw, b - fw, zs - 1.0, zs + 1.0, inset, inset + 4.0, mats['frame']) }
      edges = [z0 + fw] + splits.flat_map { |zs| [zs - 1.0, zs + 1.0] } + [z1 - fw]
      edges.each_slice(2) do |ra, rb|
        zh = door ? 48.0 : (ra + rb) / 2.0
        units.times do |i|
          ua = units == 2 ? (i == 0 ? a + fw : m + 1.25) : a + fw
          ub = units == 2 ? (i == 0 ? m - 1.25 : b - fw) : b - fw
          uc = (ua + ub) / 2.0
          bar(e, w, uc - mw / 2, uc + mw / 2, ra, rb, inset + 1.4, inset + 2.6, mats['frame'])
          bar(e, w, ua, ub, zh - mw / 2, zh + mw / 2, inset + 1.4, inset + 2.6, mats['frame'])
        end
      end
    end
    g.layer = door ? 'A-DOOR' : 'A-WIND'
  end
  g.entities.grep(Sketchup::Face).each { |x| next if x.material; x.material = mats['frame']; x.back_material = mats['frame'] }
  # sill board under windows in brick walls (white, 1.5 in proud)
  if kind == 'window' && w['mat'] == 'brick'
    s = bar(e, w, a - 1.5, b + 1.5, z0 - 2.0, z0, -1.5, inset, mats['trim'])
  end
  g
end

# ------------------------------------------------------------------------------------------------ terrain
def build_terrain(parent, t, mat)
  g = parent.add_group; g.name = 'Terrain (from elevation grade lines)'
  mesh = Geom::PolygonMesh.new
  xs = t['x']; ys = t['y']; zz = t['z']; sk = t['skip']
  (0...ys.length - 1).each do |j|
    (0...xs.length - 1).each do |i|
      next if sk[j][i]
      p1 = pt(xs[i], ys[j], zz[j][i]); p2 = pt(xs[i + 1], ys[j], zz[j][i + 1])
      p3 = pt(xs[i + 1], ys[j + 1], zz[j + 1][i + 1]); p4 = pt(xs[i], ys[j + 1], zz[j + 1][i])
      mesh.add_polygon(p1, p2, p3); mesh.add_polygon(p1, p3, p4)
    end
  end
  g.entities.add_faces_from_mesh(mesh, Geom::PolygonMesh::AUTO_SOFTEN | Geom::PolygonMesh::SMOOTH_SOFT_EDGES, mat, mat)
  # skirt down to z -100 around the grid so elevations read the ground as a section (Lot 2 convention)
  sec = Sketchup.active_model.materials['Terrain - Section']
  ring = []
  (0...xs.length).each { |i| ring << [i, 0] }
  (1...ys.length).each { |j| ring << [xs.length - 1, j] }
  (xs.length - 2).downto(0) { |i| ring << [i, ys.length - 1] }
  (ys.length - 2).downto(1) { |j| ring << [0, j] }
  ring.each_with_index do |(i, j), k|
    i2, j2 = ring[(k + 1) % ring.length]
    a = pt(xs[i], ys[j], zz[j][i]); b = pt(xs[i2], ys[j2], zz[j2][i2])
    f = g.entities.add_face(a, b, pt(b.x, b.y, -100.0), pt(a.x, a.y, -100.0))
    f.material = sec; f.back_material = sec
    f.edges.each { |e| e.hidden = true if (e.start.position.z - e.end.position.z).abs > 1 }
  end
  g.layer = 'L-TOPO'
  g
end

def purge_cpoints(ents)
  cp = ents.grep(Sketchup::ConstructionPoint).to_a
  ents.erase_entities(cp) unless cp.empty?
  ents.grep(Sketchup::Group).each { |g| purge_cpoints(g.entities) }
end

# ------------------------------------------------------------------------------------------------ main
def build
  m = Sketchup.active_model
  m.start_operation("JESB Lot 7 #{CFG['rev']}", true)
  src_names = m.materials.map(&:name)
  log "owner materials: #{src_names.join(', ')}"
  # R08: every finish selected in the ACC Material Package (sheet EXTERIOR, Lot 7 = columns F/G) is applied from the
  # ACC sample image (texture) or its colour; names start with 'ACC Lot 7 - <item> - <selection>'. Texture sizes
  # are real-world: brick module 8 x 2 2/3 in, shingle exposure 5 5/8 in, lap siding exposure 7 in.
  tx = lambda { |f| File.join(CFG['acc_textures'].to_s, f) }
  acc_tex = lambda do |name, file, size, rgb|
    mat = m.materials[name] || m.materials.add(name)
    if File.exist?(tx.call(file))
      mat.texture = tx.call(file); mat.texture.size = size
    else
      mat.color = Sketchup::Color.new(*rgb)
    end
    mat
  end
  mats = {}
  mats['shingle'] = acc_tex.call('ACC Lot 7 - Roof - Mission Brown', 'ACC_Lot7_Roof_Mission_Brown.png', [23.4, 24.2], [94, 83, 75])
  mats['brick'] = acc_tex.call('ACC Lot 7 - Brick - Magnolia (US Brick)', 'ACC_Lot7_Brick_Magnolia_USBrick.png', [17.6, 17.3], [207, 202, 195])
  mats['siding'] = acc_tex.call('ACC Lot 7 - Siding - Cobble Stone', 'ACC_Lot7_Siding_Cobble_Stone.png', [13.6, 14.0], [184, 180, 163])
  dec_white = color_mat(m, 'ACC Lot 7 - Siding Dec - White', [246, 248, 248])
  mats['panel'] = dec_white
  mats['deco'] = dec_white                      # decorative panels: ACC siding dec = White (plain)
  mats['trim'] = color_mat(m, 'ACC Lot 7 - Trims - White', [244, 244, 240])
  mats['fascia'] = color_mat(m, 'ACC Lot 7 - Soffit and Fascia - White (LP SmartSide)', [246, 248, 248])
  mats['soffit'] = mats['fascia']
  mats['gutter'] = color_mat(m, 'ACC Lot 7 - Gutters and Downspouts - White', [248, 250, 250])
  mats['frame'] = color_mat(m, 'ACC Lot 7 - Windows and Patio Doors - White', [236, 234, 233])
  mats['door'] = color_mat(m, 'ACC Lot 7 - Front Door - Brown', [75, 57, 47])
  mats['garage'] = color_mat(m, 'ACC Lot 7 - Garage Door - Brown (Cottage, glass on top)', [75, 57, 47])
  mats['garage_groove'] = color_mat(m, 'ACC Lot 7 - Garage Door - Brown groove', [58, 44, 36])
  # not in the ACC package (to verify): accent metal roofs, cast-stone headers, railings
  mats['metal'] = tex_mat(m, 'Not in ACC - Metal Roof - Standing Seam', CFG['src_metal'], [70, 62, 56], nil)
  mats['stone'] = color_mat(m, 'Not in ACC - Cast Stone Window Header (ACC: no stone)', [214, 206, 190])
  mats['iron'] = color_mat(m, 'Not in ACC - Railing - Black Iron', [28, 28, 28])
  mats['iron_band'] = mats['iron']
  mats['glass'] = color_mat(m, 'Glass', [96, 118, 136], 0.85)
  mats['concrete'] = color_mat(m, 'Concrete', [196, 194, 188])
  mats['asphalt'] = color_mat(m, 'Asphalt', [72, 72, 72])
  mats['lawn'] = color_mat(m, 'Terrain - Lawn', [118, 142, 88])
  mats['interior'] = color_mat(m, 'Interior - Dark', [58, 58, 58])
  mats['section'] = color_mat(m, 'Terrain - Section', [66, 72, 55])
  tags(m)
  # remove every entity of the owner's model, then unused definitions/materials
  m.entities.erase_entities(m.entities.to_a)
  m.definitions.purge_unused
  keep = mats.values
  m.materials.to_a.each { |x| m.materials.remove(x) unless keep.include?(x) rescue nil }
  log "materials now: #{m.materials.map(&:name).join(', ')}"

  house = m.entities.add_group; house.name = "JESB_Lot7_House (#{CFG['rev']})"
  he = house.entities
  gw = he.add_group; gw.name = 'Exterior walls'
  SPEC['walls'].each_with_index do |w, i|
    begin
      build_wall(gw.entities, w, mats, i)
    rescue => ex
      log "wall #{i} #{w['view']} #{w['a']}..#{w['b']} FAILED: #{ex.message}"
    end
  end
  log "walls: #{gw.entities.length}"
  go = he.add_group; go.name = 'Windows and doors'
  n = 0
  SPEC['walls'].each do |w|
    w['openings'].each do |o|
      begin
        build_opening_unit(go.entities, w, o, mats); n += 1
      rescue => ex
        log "opening #{w['view']} #{o['a']}..#{o['b']} FAILED: #{ex.message}"
      end
    end
  end
  log "openings: #{n}"
  gr = he.add_group; gr.name = 'Roofs'; gr.entities.add_cpoint(pt(0, 0, 0))
  SPEC['roofs'].each { |r| build_roof(gr.entities, r, mats) }
  gx = he.add_group; gx.name = 'Porch, terrace, slabs and trim'
  SPEC['boxes'].each do |b|
    name, x0, x1, y0, y1, z0, z1, mat, layer = b
    next if layer == 'L-SITE'
    box(gx.entities, name, x0, x1, y0, y1, z0, z1, mats[mat], layer)
  end
  gs = he.add_group; gs.name = 'Stair railings'
  (SPEC['sloped'] || []).each do |sb|
    name, x0, x1, ya, yb, za, zb, h, mat = sb
    sloped_bar(gs.entities, name, x0, x1, ya, yb, za, zb, h, mats[mat])
  end
  gs.layer = 'A-STAIR'
  gf = he.add_group; gf.name = 'Floor plates (interior, to stop see-through)'
  SPEC['floors'].each do |fl|
    f = gf.entities.add_face(fl['poly'].map { |x, y| pt(x, y, fl['z']) })
    f.material = mats['interior']; f.back_material = mats['interior']
  end
  gf.layer = 'A-FLOOR'
  site = m.entities.add_group; site.name = "Site (#{CFG['rev']}, from elevation grade lines - no site plan)"
  build_terrain(site.entities, SPEC['terrain'], mats['lawn'])
  SPEC['boxes'].each do |b|
    name, x0, x1, y0, y1, z0, z1, mat, layer = b
    next unless layer == 'L-SITE'
    box(site.entities, name, x0, x1, y0, y1, z0, z1, mats[mat], layer)
  end

  # geo-location: South Barrington IL; plan north = -x  ->  north angle 270
  si = m.shadow_info
  si['City'] = 'South Barrington'; si['Country'] = 'USA'
  si['Latitude'] = 42.0917; si['Longitude'] = -88.1392
  si['NorthAngle'] = 270.0
  si['TZOffset'] = -6.0
  m.entities.each { |e| nil }
  purge_cpoints(m.entities)
  m.commit_operation
  log 'build done'
end

def export_views
  m = Sketchup.active_model
  v = m.active_view
  out = CFG['export_dir']
  Dir.mkdir(out) unless File.directory?(out)
  # fixed framing centre (plan box of the house incl. guest bay and covered terrace), so exports are repeatable
  cx, cy, cz = 376.0, 457.0, 165.0
  eh = 620.0; ew_px = 3200; eh_px = 1850
  d = 6000.0
  ro = m.rendering_options
  ro['DrawSilhouettes'] = true
  ro['DisplayColorByLayer'] = false
  m.shadow_info['DisplayShadows'] = false
  white = Sketchup::Color.new(255, 255, 255)
  ro['DrawHorizon'] = false; ro['DrawGround'] = false; ro['BackgroundColor'] = white
  views = [
    ['Elevation_Front_West', [cx, cy - d, cz]],
    ['Elevation_Rear_East', [cx, cy + d, cz]],
    ['Elevation_Right_South', [cx + d, cy, cz]],
    ['Elevation_Left_North', [cx - d, cy, cz]]
  ]
  pages = m.pages
  File.write(File.join(out, 'export_meta.json'), JSON.generate({ 'cx' => cx, 'cy' => cy, 'cz' => cz, 'height' => eh, 'w' => ew_px, 'h' => eh_px }))
  views.each do |name, eye|
    cam = Sketchup::Camera.new(eye, [cx, cy, cz], [0, 0, 1]); cam.perspective = false; cam.height = eh
    v.camera = cam
    v.write_image(filename: File.join(out, "JESB_Lot7_#{CFG['rev']}_#{name}.png"), width: ew_px, height: eh_px, antialias: true, transparent: false)
    pages.add(name.tr('_', ' ')).update
  end
  cam = Sketchup::Camera.new([cx, cy, cz + d], [cx, cy, cz], [0, 1, 0]); cam.perspective = false; cam.height = 1100.0
  v.camera = cam
  site = m.entities.find { |e| e.is_a?(Sketchup::Group) && e.name.start_with?('Site') }
  site.hidden = true if site
  v.write_image(filename: File.join(out, "JESB_Lot7_#{CFG['rev']}_Roof_Plan.png"), width: 2400, height: 2400, antialias: true, transparent: false)
  site.hidden = false if site
  pages.add('Roof Plan').update
  ro['DrawHorizon'] = true; ro['DrawGround'] = false
  [['Perspective_Front_SW', [cx + 1150, cy - 1450, 560], [cx - 30, cy - 60, 110]],
   ['Perspective_Front_NW', [cx - 1300, cy - 1300, 600], [cx + 10, cy - 60, 110]],
   ['Perspective_Rear_SE', [cx + 1350, cy + 1350, 640], [cx, cy + 60, 90]],
   ['Perspective_Rear_NE', [cx - 1250, cy + 1400, 600], [cx, cy + 40, 90]]].each do |name, eye, tg|
    cam = Sketchup::Camera.new(eye, tg, [0, 0, 1]); cam.perspective = true; cam.fov = 35.0
    v.camera = cam
    v.write_image(filename: File.join(out, "JESB_Lot7_#{CFG['rev']}_#{name}.png"), width: 2400, height: 1500, antialias: true, transparent: false)
    pages.add(name.tr('_', ' ')).update
  end
  qa = File.join(out, 'qa'); Dir.mkdir(qa) unless File.directory?(qa)
  [['qa_wing_main_junction_S', [cx + 500, cy - 300, 420], [150, 430, 260]], ['qa_wing_main_junction_N', [cx - 700, cy - 250, 450], [100, 430, 260]],
   ['qa_portico', [cx - 100, cy - 650, 300], [400, 430, 200]], ['qa_gablet', [cx + 700, cy + 200, 420], [620, 714, 280]],
   ['qa_garage_front', [cx - 300, cy - 700, 250], [140, 40, 120]],
   ['qa_entry_stair', [470, 230, 70], [400, 410, -5]], ['qa_terrace_stair', [cx + 520, cy - 120, 40], [732, 555, -20]],
   ['qa_rear_headers', [cx - 60, cy + 900, 110], [250, 912, 70]]].each do |name, eye, tg|
    cam = Sketchup::Camera.new(eye, tg, [0, 0, 1]); cam.perspective = true; cam.fov = 40.0
    v.camera = cam
    v.write_image(filename: File.join(qa, name + '.png'), width: 1600, height: 1000, antialias: true, transparent: false)
  end
  pages.selected_page = pages['Perspective Front SW']
  v.camera = pages['Perspective Front SW'].camera
  log "exports written to #{out}"
end

def run
  build
  export_views
  ok = Sketchup.active_model.save(CFG['save_as'])
  log "saved #{ok}: #{CFG['save_as']}"
  File.write(CFG['done'], 'ok')
rescue => ex
  log "ERR #{ex.class}: #{ex.message}\n#{ex.backtrace.first(10).join("\n")}"
  File.write(CFG['done'], 'ERR')
end

tries = 0
tid = UI.start_timer(3, true) do
  tries += 1
  if Sketchup.active_model && !Sketchup.active_model.path.to_s.empty?
    UI.stop_timer(tid)
    UI.start_timer(6, false) { run }
  elsif tries > 100
    UI.stop_timer(tid)
    File.write(CFG['done'], 'ERR no model loaded')
  end
end