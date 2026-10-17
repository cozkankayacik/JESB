require 'json'
OUT='C:/Projects/JESB/LOT7/04_Visualization/Working/Blender_Cycles_R10'
def export_cycles
 m=Sketchup.active_model
 mats={}
 m.materials.each_with_index do |mat,i|
  rec={'name'=>mat.name,'color'=>mat.color.to_a[0,3],'alpha'=>mat.alpha}
  if mat.texture
   path=OUT+"/textures/material_#{i}.png"
   begin
    mat.texture.write(path)
    rec['texture']=path
   rescue
   end
  end
  mats[mat.name]=rec
 end
 batches={}
 walk=nil
 walk=lambda do |ents,tr,inherit,label|
  ents.each do |e|
   next if e.hidden? || !e.layer.visible?
   if e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    nm=e.name.empty? ? label : e.name
    walk.call(e.is_a?(Sketchup::Group) ? e.entities : e.definition.entities,tr*e.transformation,e.material || inherit,nm)
   elsif e.is_a?(Sketchup::Face)
    mat=e.material || e.back_material || inherit
    name=mat ? mat.name : 'Default'
    key=label+'|'+name
    b=batches[key] ||= {'name'=>label,'material'=>name,'vertices'=>[],'faces'=>[],'uv'=>[]}
    mesh=e.mesh(7)
    offset=b['vertices'].length
    mesh.points.each_with_index do |pt,i|
     p=pt.transform(tr); b['vertices'] << p.to_a.map{|v| v*0.0254}
     uv=mesh.uv_at(i+1,true); q=uv.z == 0 ? 1 : uv.z
     b['uv'] << [uv.x/q,uv.y/q]
    end
    mesh.polygons.each{|poly| b['faces'] << poly.map{|i| offset+i.abs-1}}
   end
  end
 end
 walk.call(m.entities,Geom::Transformation.new,nil,'Model')
 File.write(OUT+'/scene.json',JSON.generate({'source'=>m.path,'materials'=>mats,'meshes'=>batches.values}))
 File.write(OUT+'/export_done.txt',"OK #{batches.length} batches")
rescue => ex
 File.write(OUT+'/export_done.txt',"ERROR #{ex.message}\n#{ex.backtrace.join("\n")}")
end
tries=0
tid=UI.start_timer(2,true) do
 tries+=1
 if !Sketchup.active_model.path.empty?
  UI.stop_timer(tid)
  UI.start_timer(3,false){export_cycles}
 elsif tries>60
  UI.stop_timer(tid)
 end
end
