extends RefCounted
const Art=preload("res://scripts/art.gd")
static func equip(hero:Node3D,id:String) -> void:
	var previous=hero.find_child("WeaponPivot",true,false)
	if previous:previous.get_parent().remove_child(previous);previous.queue_free()
	var parent=hero.attachment() if hero.has_method("attachment") else hero
	if not parent:parent=hero
	var pivot=Node3D.new();pivot.name="WeaponPivot";parent.add_child(pivot);pivot.position=Vector3(0,-.3,0)
	var model=""
	match id:
		"sword","greatsword","daggers","dual":model="mini-dungeon/weapon-sword"
		"spear":model="mini-dungeon/weapon-spear"
		"axe":model="survival-kit/tool-axe-upgraded"
	if not model.is_empty():
		var n=Library.place(pivot,model,Vector3.ZERO,1.5 if id=="greatsword" else (.7 if id=="daggers" else 1.0));n.rotation.x=PI
		if id=="dual":Library.place(pivot,model,Vector3(-.8,0,0),1)
	elif id in ["bow","crossbow"]:
		for i in range(9):
			var angle=-PI/2+i*PI/8
			var limb=Art.box(pivot,Vector3(cos(angle)*.3,sin(angle)*.7,0),Vector3(.06,.2,.08),Color("795237"));limb.rotation.z=-angle
		Art.box(pivot,Vector3.ZERO,Vector3(.015,1.4,.015),Color("e5dbc2"))
		if id=="crossbow":pivot.rotation.z=PI/2;Art.box(pivot,Vector3(0,0,-.2),Vector3(.18,.2,.85),Color("684c36"))
	else:
		Art.box(pivot,Vector3(0,.4,0),Vector3(.1,1.7,.1),Color("8f7545"))
		var crystal=Art.cone(pivot,Vector3(0,1.35,0),.25,.6,Color("69d8f4") if id=="staff" else Color("ed7642"))
		crystal.material_override.emission_enabled=true;crystal.material_override.emission=crystal.material_override.albedo_color
