class_name Art
extends RefCounted
static func mesh(parent:Node3D, shape:Mesh, pos:Vector3, color:Color) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	n.mesh = shape
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.8
	n.material_override = mat
	parent.add_child(n)
	n.position = pos
	return n
static func box(parent:Node3D, pos:Vector3, size:Vector3, color:Color) -> MeshInstance3D:
	var s = BoxMesh.new(); s.size = size
	return mesh(parent,s,pos,color)
static func cone(parent:Node3D,pos:Vector3,radius:float,height:float,color:Color) -> MeshInstance3D:
	var s = CylinderMesh.new(); s.top_radius=0.0; s.bottom_radius=radius; s.height=height; s.radial_segments=7
	return mesh(parent,s,pos,color)
static func person(parent:Node3D,color:Color,big:float=1.0) -> Node3D:
	var n=Node3D.new();n.set_script(load("res://scripts/actor.gd"));parent.add_child(n)
	var sk=Skeleton3D.new();sk.name="Skeleton3D";n.add_child(sk)
	var names=["Spine","Head","ArmL","ArmR","LegL","LegR"]
	var positions=[Vector3(0,1.05,0),Vector3(0,.78,0),Vector3(-.44,.4,0),Vector3(.44,.4,0),Vector3(-.21,-.2,0),Vector3(.21,-.2,0)]
	for i in range(6):
		sk.add_bone(names[i])
		if i>0:sk.set_bone_parent(i,0)
		sk.set_bone_rest(i,Transform3D(Basis.IDENTITY,positions[i]))
		var attachment=BoneAttachment3D.new();attachment.bone_name=names[i];sk.add_child(attachment)
		if i==0:
			var torso=CapsuleMesh.new();torso.radius=.34;torso.height=.9;torso.radial_segments=12;torso.rings=4
			mesh(attachment,torso,Vector3(0,.15,0),color)
			box(attachment,Vector3(0,-.1,0),Vector3(.73,.12,.5),Color("a88c51"))
			box(attachment,Vector3(0,.1,.28),Vector3(.7,1.15,.06),color.darkened(.4))
		elif i==1:
			var head=SphereMesh.new();head.radius=.24;head.height=.48;head.radial_segments=12;head.rings=6
			mesh(attachment,head,Vector3.ZERO,Color("d1b598"))
			box(attachment,Vector3(0,.15,.04),Vector3(.45,.18,.43),Color("b8bdc6"))
			for x in [-.09,.09]:box(attachment,Vector3(x,.02,-.22),Vector3(.035,.04,.025),Color("1d2839"))
		else:
			box(attachment,Vector3(0,-.35,0),Vector3(.22,.65,.26),color.darkened(.2) if i<4 else Color("283441"))
			box(attachment,Vector3(0,-.66,-.07),Vector3(.26,.18,.38),Color("373844"))
	sk.reset_bone_poses()
	n.scale=Vector3.ONE*big
	return n
static func label(parent:Node3D,text:String,pos:Vector3,color:Color=Color.WHITE) -> Label3D:
	var l=Label3D.new();l.text=text;l.font_size=40;l.pixel_size=.012;l.billboard=BaseMaterial3D.BILLBOARD_ENABLED;l.modulate=color;l.no_depth_test=true
	parent.add_child(l);l.position=pos
	return l
