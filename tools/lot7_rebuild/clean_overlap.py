import bpy, bmesh, re
from mathutils import Vector
from mathutils.bvhtree import BVHTree
from pathlib import Path
OUT=Path('C:/Projects/JESB/LOT7/04_Visualization/Renders/Blender_Cycles_R10')
walls=[o for o in bpy.context.scene.objects if o.name.startswith('Wall ') and o.type=='MESH']
dirs={'front':Vector((0,-1,0)),'rear':Vector((0,1,0)),'north':Vector((-1,0,0)),'south':Vector((1,0,0))}
vs=[]; fs=[]
for o in walls:
    direction=dirs[o.name.split()[2]]
    for p in o.data.polygons:
        if p.normal.dot(direction)>.99:
            k=len(vs); vs.extend([o.data.vertices[i].co.copy() for i in p.vertices]); fs.append(tuple(range(k,len(vs))))
tree=BVHTree.FromPolygons(vs,fs)
removed=0
for o in walls:
    direction=dirs[o.name.split()[2]]; bm=bmesh.new(); bm.from_mesh(o.data); bm.faces.ensure_lookup_table(); dead=[]
    for f in bm.faces:
        if abs(f.normal.dot(direction))>.9: continue
        c=f.calc_center_median(); pos,n,i,dist=tree.ray_cast(c+f.normal*.003,-f.normal,.006)
        if pos is not None and abs(n.dot(f.normal))>.99: dead.append(f)
    removed+=len(dead); bmesh.ops.delete(bm,geom=dead,context='FACES'); bm.to_mesh(o.data); bm.free()
print('Removed coincident return triangles',removed)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'JESB_Lot7_R10_Cycles.blend'))
s=bpy.context.scene; s.render.resolution_percentage=40; s.cycles.samples=32; s.render.filepath=str(OUT/'test_clean.png'); bpy.ops.render.render(write_still=True)
