import bpy,bmesh,math
from mathutils import Vector
from mathutils.bvhtree import BVHTree
from pathlib import Path
OUT=Path('C:/Projects/JESB/LOT7/04_Visualization/Renders/Blender_Cycles_R10')
s=bpy.context.scene
terrain=next(o for o in s.objects if o.type=='MESH' and o.data.materials and o.data.materials[0].name=='Terrain - Lawn')
tree=BVHTree.FromPolygons([v.co for v in terrain.data.vertices],[p.vertices[:] for p in terrain.data.polygons])
xs=[v.co.x for v in terrain.data.vertices]; ys=[v.co.y for v in terrain.data.vertices]
x0,x1=min(xs),max(xs); y0,y1=min(ys),max(ys)
# Four outward strips interpolate the original perimeter grade.
vs=[]; fs=[]
for edge in range(4):
    last=None
    for i in range(161):
        t=i/160
        x,y= [(x0,y0+(y1-y0)*t),(x1,y0+(y1-y0)*t),(x0+(x1-x0)*t,y0),(x0+(x1-x0)*t,y1)][edge]
        loc,_,_,_=tree.ray_cast(Vector((min(max(x,x0+.001),x1-.001),min(max(y,y0+.001),y1-.001),20)),Vector((0,0,-1)))
        z=loc.z if loc else -2.75
        xo,yo=[(x0-1500,y),(x1+1500,y),(x,y0-1500),(x,y1+1500)][edge]
        k=len(vs); vs.extend([(x,y,z-.002),(xo,yo,z-.002)])
        if last is not None: fs.append((last,last+1,k+1,k))
        last=k
me=bpy.data.meshes.new('Grade continuation'); me.from_pydata(vs,[],fs); me.update(); ob=bpy.data.objects.new('Grade continuation',me); s.collection.objects.link(ob); me.materials.append(bpy.data.materials['Terrain - Lawn'])
for ob in s.objects:
    if ob.type=='MESH' and ob.data.materials and ob.data.materials[0].name=='Terrain - Section': ob.hide_render=True
# Remove coplanar roof edge triangles that duplicate an exterior wall.
fronts=[]; faces=[]; dirs={'front':Vector((0,-1,0)),'rear':Vector((0,1,0)),'north':Vector((-1,0,0)),'south':Vector((1,0,0))}
for ob in s.objects:
    if not ob.name.startswith('Wall '): continue
    for p in ob.data.polygons:
        if p.normal.dot(dirs[ob.name.split()[2]])>.99:
            k=len(fronts); fronts.extend([ob.data.vertices[i].co.copy() for i in p.vertices]); faces.append(tuple(range(k,len(fronts))))
bt=BVHTree.FromPolygons(fronts,faces)
for ob in s.objects:
    if not ob.name.startswith('Roof '): continue
    bm=bmesh.new(); bm.from_mesh(ob.data); dead=[]
    for f in bm.faces:
        c=f.calc_center_median(); pos,n,_,_=bt.ray_cast(c+f.normal*.004,-f.normal,.008)
        if pos is not None and abs(n.dot(f.normal))>.99: dead.append(f)
    bmesh.ops.delete(bm,geom=dead,context='FACES'); bm.to_mesh(ob.data); bm.free()
grass=bpy.data.materials['Terrain - Lawn']; ramp=next(n for n in grass.node_tree.nodes if n.type=='VALTORGB')
for el in ramp.color_ramp.elements: el.color=tuple(c*.6 for c in el.color[:3])+(1,)
s.view_settings.exposure=.25
for im in bpy.data.images:
    if im.source=='FILE': im.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'JESB_Lot7_R10_Cycles.blend'))
s.render.resolution_percentage=40; s.cycles.samples=32; s.render.filepath=str(OUT/'test_finished.png'); bpy.ops.render.render(write_still=True)
