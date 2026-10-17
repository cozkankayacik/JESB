import bpy, math, random
from mathutils import Vector
from pathlib import Path
OUT=Path('C:/Projects/JESB/LOT7/04_Visualization/Renders/Blender_Cycles_R10')
s=bpy.context.scene; s.cycles.device='CPU'; s.view_settings.exposure=0
# Soft daylight, consistent physically lit materials.
w=s.world; n=w.node_tree.nodes; l=w.node_tree.links; n.clear()
o=n.new('ShaderNodeOutputWorld'); b=n.new('ShaderNodeBackground'); b.inputs[0].default_value=(.56,.72,1,1); b.inputs[1].default_value=.55; l.new(b.outputs[0],o.inputs[0])
ld=bpy.data.lights.new('Daylight sun','SUN'); ld.energy=2.5; ld.angle=math.radians(12); ob=bpy.data.objects.new(ld.name,ld); s.collection.objects.link(ob); ob.rotation_euler=(math.radians(28),math.radians(-25),math.radians(-25))
for ob in list(s.objects):
    if ob.type=='MESH' and ob.data.materials and ob.data.materials[0].name=='Terrain - Section': ob.hide_render=True
# Grass blades follow existing terrain triangles and keep the driveway clear.
terrain=next(o for o in s.objects if o.type=='MESH' and o.data.materials and o.data.materials[0].name=='Terrain - Lawn')
random.seed(79); verts=[]; faces=[]
for p in terrain.data.polygons:
    if p.area<1e-7: continue
    points=[terrain.data.vertices[i].co for i in p.vertices]
    if len(points)!=3: continue
    a,b,c=points
    for _ in range(int(p.area*170)):
        r=math.sqrt(random.random()); t=random.random(); v=(1-r)*a+r*(1-t)*b+r*t*c
        x,y,z=v
        if (7.0<x<13.12 and -12.3<y<10.2) or (0<x<16.3 and 0<y<23.2): continue
        h=random.uniform(.025,.065); width=random.uniform(.002,.006); ang=random.random()*math.tau; dx=math.cos(ang)*width; dy=math.sin(ang)*width
        k=len(verts); verts.extend([(x-dx,y-dy,z),(x+dx,y+dy,z),(x+dx*3,y+dy*3,z+h)]); faces.append((k,k+1,k+2))
me=bpy.data.meshes.new('Lawn blades'); me.from_pydata(verts,[],faces); me.update(); ob=bpy.data.objects.new('Lawn blades',me); s.collection.objects.link(ob); me.materials.append(bpy.data.materials['Terrain - Lawn'])
# An emission sky card supplies a spatial sky in orthographic elevations.
mat=bpy.data.materials.new('Sky backdrop'); mat.use_nodes=True; n=mat.node_tree.nodes; l=mat.node_tree.links; n.clear()
o=n.new('ShaderNodeOutputMaterial'); e=n.new('ShaderNodeEmission'); l.new(e.outputs[0],o.inputs[0]); e.inputs[1].default_value=.8
tc=n.new('ShaderNodeTexCoord'); noise=n.new('ShaderNodeTexNoise'); noise.inputs['Scale'].default_value=5; noise.inputs['Detail'].default_value=5; noise.inputs['Roughness'].default_value=.7; l.new(tc.outputs['Generated'],noise.inputs[0])
r=n.new('ShaderNodeValToRGB'); r.color_ramp.elements[0].position=.49; r.color_ramp.elements[0].color=(.13,.38,.72,1); r.color_ramp.elements[1].position=.7; r.color_ramp.elements[1].color=(.95,.97,1,1); l.new(noise.outputs['Fac'],r.inputs[0]); l.new(r.outputs[0],e.inputs[0])
cam=s.camera; direction=cam.rotation_euler.to_quaternion()@Vector((0,0,-1))
bpy.ops.mesh.primitive_plane_add(size=1,location=Vector((9.55,11.6,4.19))+direction*90); card=bpy.context.object; card.name='Sky card'; card.rotation_euler=cam.rotation_euler; card.scale=(100,60,1); card.data.materials.append(mat); card.visible_shadow=False; card.visible_diffuse=False
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'JESB_Lot7_R10_Cycles.blend'))
s.render.resolution_percentage=40; s.cycles.samples=48; s.render.filepath=str(OUT/'test_refined.png'); bpy.ops.render.render(write_still=True)
