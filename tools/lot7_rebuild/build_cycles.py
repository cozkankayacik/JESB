import bpy, json, math, os, sys
from mathutils import Vector
from pathlib import Path
BASE=Path('C:/Projects/JESB/LOT7/04_Visualization/Working/Blender_Cycles_R10')
OUT=Path('C:/Projects/JESB/LOT7/04_Visualization/Renders/Blender_Cycles_R10'); OUT.mkdir(parents=True,exist_ok=True)
data=json.loads((BASE/'scene.json').read_text())
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def linear(c):
    c=c/255; return c/12.92 if c<0.04045 else ((c+.055)/1.055)**2.4
mats={}
for name,rec in data['materials'].items():
    m=bpy.data.materials.new(name); m.use_nodes=True; mats[name]=m
    n=m.node_tree.nodes; l=m.node_tree.links; p=n.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*[linear(v) for v in rec['color']],1)
    p.inputs['Roughness'].default_value=.58
    if 'texture' in rec:
        t=n.new('ShaderNodeTexImage'); t.image=bpy.data.images.load(rec['texture']); l.new(t.outputs['Color'],p.inputs['Base Color'])
        bump=n.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.22; bump.inputs['Distance'].default_value=.003
        l.new(t.outputs['Color'],bump.inputs['Height']); l.new(bump.outputs['Normal'],p.inputs['Normal'])
    if 'Metal Roof' in name or 'Iron' in name:
        p.inputs['Metallic'].default_value=.7; p.inputs['Roughness'].default_value=.32
    if 'White' in name: p.inputs['Roughness'].default_value=.3
    if name=='Glass':
        p.inputs['Base Color'].default_value=(.88,.94,.98,1); p.inputs['Transmission Weight'].default_value=1; p.inputs['Roughness'].default_value=.055; p.inputs['IOR'].default_value=1.5
    if name in ('Concrete','Asphalt','Terrain - Lawn'):
        tex=n.new('ShaderNodeTexNoise'); tex.inputs['Scale'].default_value=130 if name!='Terrain - Lawn' else 35; tex.inputs['Detail'].default_value=3
        coord=n.new('ShaderNodeTexCoord'); l.new(coord.outputs['Object'],tex.inputs['Vector'])
        ramp=n.new('ShaderNodeValToRGB'); base=[linear(v) for v in rec['color']]
        for el,f in zip(ramp.color_ramp.elements,(.5,1.15)): el.color=(*[min(v*f,1) for v in base],1)
        l.new(tex.outputs['Fac'],ramp.inputs[0]); l.new(ramp.outputs['Color'],p.inputs['Base Color'])
        b=n.new('ShaderNodeBump'); b.inputs['Strength'].default_value=.4; b.inputs['Distance'].default_value=.015 if name=='Terrain - Lawn' else .0015
        l.new(tex.outputs['Fac'],b.inputs['Height']); l.new(b.outputs[0],p.inputs['Normal']); p.inputs['Roughness'].default_value=.85
for b in data['meshes']:
    me=bpy.data.meshes.new(b['name']); me.from_pydata(b['vertices'],[],b['faces']); me.update()
    ob=bpy.data.objects.new(b['name'],me); bpy.context.collection.objects.link(ob)
    if b['material'] in mats: me.materials.append(mats[b['material']])
    uv=me.uv_layers.new(name='SketchUp UV')
    for poly in me.polygons:
        for li in poly.loop_indices: uv.data[li].uv=b['uv'][me.loops[li].vertex_index]
    if b['material'] not in ('Terrain - Lawn','Terrain - Section','Glass'):
        bevel=ob.modifiers.new('Physical edge highlights','BEVEL'); bevel.width=.001; bevel.segments=2
        bevel.limit_method='ANGLE'
# Existing grade is retained. A distant lawn plane closes the horizon below model grade.
terrain=[v for b in data['meshes'] if b['material']=='Terrain - Lawn' for v in b['vertices']]
low=min(v[2] for v in terrain)-.03
bpy.ops.mesh.primitive_plane_add(size=2000,location=(9,11,low)); bpy.context.object.name='Distant grass horizon'; bpy.context.object.data.materials.append(mats['Terrain - Lawn'])
scene=bpy.context.scene; scene.render.engine='CYCLES'; scene.cycles.samples=256; scene.cycles.use_denoising=True; scene.cycles.adaptive_threshold=.01
scene.cycles.max_bounces=10; scene.cycles.transmission_bounces=8
prefs=bpy.context.preferences.addons['cycles'].preferences
try:
    prefs.compute_device_type='HIP'; prefs.refresh_devices()
    for d in prefs.devices: d.use=d.type=='HIP'
    scene.cycles.device='GPU'
except: scene.cycles.device='CPU'
world=bpy.data.worlds.new('Daylight sky'); scene.world=world; world.use_nodes=True
n=world.node_tree.nodes; l=world.node_tree.links; sky=n.new('ShaderNodeTexSky'); sky.sky_type='NISHITA'; sky.sun_elevation=math.radians(38); sky.sun_rotation=math.radians(210); sky.sun_size=math.radians(2); sky.air_density=1.1; sky.dust_density=.5
l.new(sky.outputs[0],n.get('Background').inputs[0]); n.get('Background').inputs[1].default_value=.45
scene.view_settings.view_transform='AgX'; scene.view_settings.look='AgX - Medium High Contrast'; scene.view_settings.exposure=.5
scene.render.resolution_x=3200; scene.render.resolution_y=1850; scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'; scene.render.image_settings.color_depth='16'
scene.render.film_transparent=False
center=Vector((376*.0254,457*.0254,165*.0254))
views={'Front_West':(0,-100,0),'Left_North':(-100,0,0),'Rear_East':(0,100,0),'Right_South':(100,0,0)}
for name,delta in views.items():
    cam=bpy.data.cameras.new(name); ob=bpy.data.objects.new(name,cam); scene.collection.objects.link(ob)
    ob.location=center+Vector(delta); ob.rotation_euler=(center-ob.location).to_track_quat('-Z','Y').to_euler(); cam.type='ORTHO'; cam.ortho_scale=620*.0254*3200/1850; cam.clip_end=3000
scene.camera=bpy.data.objects['Front_West']
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'JESB_Lot7_R10_Cycles.blend'))
scene.render.resolution_percentage=35; scene.cycles.samples=32; scene.render.filepath=str(OUT/'test_front.png'); bpy.ops.render.render(write_still=True)
