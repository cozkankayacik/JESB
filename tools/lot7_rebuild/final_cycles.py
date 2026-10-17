import bpy, math, json
from pathlib import Path
from mathutils import Vector
OUT=Path('C:/Projects/JESB/LOT7/04_Visualization/Renders/Blender_Cycles_R10')
s=bpy.context.scene; s.cycles.device='CPU'; s.cycles.samples=256; s.cycles.adaptive_threshold=.006; s.render.resolution_percentage=100
s.view_settings.exposure=.65
s.world.node_tree.nodes.get('Background').inputs[1].default_value=.8
center=Vector((9.5504,11.6078,4.191))
card=bpy.data.objects['Sky card']; card.visible_glossy=False
reflection=card.copy(); reflection.data=card.data.copy(); reflection.name='Sky reflection card'; s.collection.objects.link(reflection); reflection.visible_camera=False; reflection.visible_glossy=True; reflection.visible_transmission=False
# Extend model grade to the foreground without changing the house/driveway.
for o in s.objects:
    if o.type=='MESH' and o.data.materials and o.data.materials[0].name=='Terrain - Section': o.hide_render=False
# Broad fill simulates open sky at the elevation being photographed.
ld=bpy.data.lights.new('Open sky fill','AREA'); ld.energy=1800; ld.shape='DISK'; ld.size=18
fill=bpy.data.objects.new(ld.name,ld); s.collection.objects.link(fill)
sun=bpy.data.objects['Daylight sun']
for name in ('Front_West','Left_North','Rear_East','Right_South'):
    cam=bpy.data.objects[name]; direction=(center-cam.location).normalized(); cam.location.z+=5.24; cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler(); s.camera=cam
    card.location=center+direction*130; card.rotation_euler=cam.rotation_euler
    reflection.location=center-direction*70; reflection.rotation_euler=cam.rotation_euler; reflection.scale=(100,60,1)
    fill.location=center-direction*20+Vector((0,0,10)); fill.rotation_euler=(center-fill.location).to_track_quat('-Z','Y').to_euler()
    light_position=center-direction*30+Vector((15,10,35)); sun.rotation_euler=(center-light_position).to_track_quat('-Z','Y').to_euler(); sun.data.energy=2
    if name=='Front_West':
        s.render.resolution_percentage=40; s.cycles.samples=40; s.render.filepath=str(OUT/'test_final.png'); bpy.ops.render.render(write_still=True)
        break
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'JESB_Lot7_R10_Cycles.blend'))
