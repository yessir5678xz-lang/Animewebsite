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
	var n = Node3D.new();parent.add_child(n)
	box(n,Vector3(0,1.1,0),Vector3(.7,1.2,.45),color)
	var head=SphereMesh.new();head.radius=.28;head.height=.56
	mesh(n,head,Vector3(0,1.95,0),Color("d7bfa1"))
	box(n,Vector3(-.22,.3,0),Vector3(.25,.65,.3),Color("202536"))
	box(n,Vector3(.22,.3,0),Vector3(.25,.65,.3),Color("202536"))
	box(n,Vector3(.6,1.1,0),Vector3(.12,1.5,.12),Color("e5d5a2"))
	cone(n,Vector3(0,1.55,.12),.55,1.7,color.darkened(.35))
	n.scale=Vector3.ONE*big
	return n
static func label(parent:Node3D,text:String,pos:Vector3,color:Color=Color.WHITE) -> Label3D:
	var l=Label3D.new();l.text=text;l.font_size=40;l.pixel_size=.012;l.billboard=BaseMaterial3D.BILLBOARD_ENABLED;l.modulate=color;l.no_depth_test=true
	parent.add_child(l);l.position=pos
	return l
