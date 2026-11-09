extends Node3D
## Imported CC0 rigid-part animation, preserving the existing combat interface.
var player:AnimationPlayer
var last=Vector3.ZERO
var action_left=0.0
var dead=false
var current=""
var model_id="blocky-characters/character-a"
func build(id:String) -> void:
	model_id=id
	var model=Library.model(id);model.name="Model";add_child(model)
	var bounds=model_bounds(model,Transform3D.IDENTITY)
	model.scale=Vector3.ONE*(2.2/maxf(bounds.size.y,.1))
	if id.begins_with("blocky-characters/"):wardrobe(model,id.unicode_at(id.length()-1)-97)
	player=model.find_child("AnimationPlayer",true,false)
	last=global_position
	if player:
		for name in ["idle","walk","sprint","sit"]:
			if player.has_animation(name):player.get_animation(name).loop_mode=Animation.LOOP_LINEAR
		play("idle")
func play(name:String) -> void:
	if player and player.has_animation(name) and current!=name:
		player.play(name,.12);current=name
func _process(delta:float) -> void:
	if dead:return
	action_left=maxf(0,action_left-delta)
	var speed=global_position.distance_to(last)/maxf(delta,.001);last=global_position
	if action_left<=0:play("sprint" if speed>5 else ("walk" if speed>.3 else "idle"))
func animate_attack(effect:String) -> void:
	action_left=.55;current=""
	play("holding-both-shoot" if effect in ["arrow","bolt","arcane"] else ("attack-melee-left" if effect=="dual" else "attack-melee-right"))
func gesture(name:String,duration:float=.8) -> void:
	action_left=duration;current="";play(name)
func fall() -> void:
	dead=true;current="";play("die")
func attachment() -> Node3D:
	return get_node("Model").find_child("arm-right",true,false)

func wardrobe(node:Node,index:int) -> void:
	var colors=[Color("586a7b"),Color("763d48"),Color("4f7568"),Color("9d8050"),Color("675675"),Color("594d42")]
	if node is MeshInstance3D and not "head" in String(node.name):
		var mat=StandardMaterial3D.new();mat.roughness=.85
		mat.albedo_color=colors[posmod(index,colors.size())] if "torso" in String(node.name) or "arm" in String(node.name) else Color("38333c")
		node.material_override=mat
	for child in node.get_children():wardrobe(child,index)
	if String(node.name)=="torso":
		var art=preload("res://scripts/art.gd")
		art.box(node,Vector3(0,-.1,.3),Vector3(.9,1.2,.08),colors[posmod(index,6)].darkened(.3))
		art.box(node,Vector3(0,-.35,-.02),Vector3(1.02,.12,.6),Color("b69b63"))
		if index%3==0:
			for x in [-.5,.5]:art.box(node,Vector3(x,.32,0),Vector3(.35,.2,.7),Color("a5a8ad"))

func model_bounds(node:Node,transform:Transform3D) -> AABB:
	if node is Node3D:transform=transform*node.transform
	var bounds=AABB()
	if node is MeshInstance3D:bounds=transform*node.mesh.get_aabb()
	for child in node.get_children():bounds=bounds.merge(model_bounds(child,transform))
	return bounds
