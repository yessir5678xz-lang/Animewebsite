extends Node
## Licensed scene library and bounded, asynchronous texture delivery.
var catalog:Dictionary
var by_id:Dictionary={}
var pools:Dictionary={}
var scene_cache:Dictionary={}
var pending:Array=[]
var requested:Dictionary={}
var surfaces:Array=[]
func _ready() -> void:
	catalog=JSON.parse_string(FileAccess.get_file_as_string("res://data/library.json"))
	for entry in catalog.models:
		by_id[entry.id]=entry
		var key=entry.kit+"/"+entry.category
		if not pools.has(key):pools[key]=[]
		pools[key].append(entry.id)
	if FileAccess.file_exists("res://data/surfaces.json"):
		surfaces=JSON.parse_string(FileAccess.get_file_as_string("res://data/surfaces.json")).materials
func model(id:String) -> Node3D:
	if not by_id.has(id):push_error("Unknown model: "+id);return Node3D.new()
	if not scene_cache.has(id):
		if scene_cache.size()>=48:scene_cache.erase(scene_cache.keys()[0])
		scene_cache[id]=load(by_id[id].path)
	return scene_cache[id].instantiate()
func place(parent:Node3D,id:String,pos:Vector3,size:float=1.0,angle:float=0.0) -> Node3D:
	var n=model(id);parent.add_child(n);n.position=pos;n.scale=Vector3.ONE*size;n.rotation.y=angle
	visibility(n)
	return n
func visibility(node:Node) -> void:
	if node is GeometryInstance3D:node.visibility_range_end=110;node.visibility_range_end_margin=12
	for child in node.get_children():visibility(child)
func pool(kit:String,category:String) -> Array:return pools.get(kit+"/"+category,[])
func instanced(parent:Node3D,id:String,transforms:Array) -> void:
	var source=model(id)
	_mesh_batches(parent,source,Transform3D.IDENTITY,transforms)
	source.free()
func _mesh_batches(parent:Node3D,node:Node,transform:Transform3D,transforms:Array) -> void:
	if node is Node3D:transform=transform*node.transform
	if node is MeshInstance3D:
		var batch=MultiMeshInstance3D.new();var mm=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=node.mesh;mm.instance_count=transforms.size()
		for i in range(transforms.size()):mm.set_instance_transform(i,transforms[i]*transform)
		batch.multimesh=mm;batch.material_override=node.material_override;batch.visibility_range_end=95;batch.visibility_range_end_margin=10;parent.add_child(batch)
	for child in node.get_children():_mesh_batches(parent,child,transform,transforms)
func surface(target:MeshInstance3D,id:String,high:bool=false,scale_uv:float=.2) -> void:
	var material=StandardMaterial3D.new();material.roughness=.85;material.uv1_triplanar=true;material.uv1_world_triplanar=true;material.uv1_scale=Vector3.ONE*scale_uv
	material.albedo_color=Color("555b58")
	if target.material_override is StandardMaterial3D:
		material.albedo_color=target.material_override.albedo_color
		material.albedo_texture=target.material_override.albedo_texture
	target.material_override=material
	for entry in surfaces:
		if entry.id!=id:continue
		for map in entry.maps:
			if map.quality!=("high" if high else "mobile"):continue
			# Weak owners let queued loads finish safely after a chunk is unloaded.
			pending.append({"owner":weakref(target),"material":weakref(material),"path":map.path,"role":map.role})
		break
func _process(_delta:float) -> void:
	# At most two files are in flight, and at most two assignments per frame.
	var camera=get_viewport().get_camera_3d()
	if camera:
		var position=camera.global_position
		pending.sort_custom(func(a,b):return task_priority(a,position)<task_priority(b,position))
	var assigned=0
	for task in pending.duplicate():
		var owner=task.owner.get_ref();var mat=task.material.get_ref()
		if not is_instance_valid(owner) or not is_instance_valid(mat) or owner.material_override!=mat:
			pending.erase(task);continue
		if not requested.has(task.path):
			if requested.size()>=2:continue
			if ResourceLoader.load_threaded_request(task.path)!=OK:pending.erase(task);continue
			requested[task.path]=true
		var status=ResourceLoader.load_threaded_get_status(task.path)
		if status==ResourceLoader.THREAD_LOAD_LOADED:
			var texture=ResourceLoader.load_threaded_get(task.path)
			match task.role:
				"albedo":mat.albedo_texture=texture;mat.albedo_color=owner.get_meta("surface_tint",Color.WHITE)
				"normal":mat.normal_enabled=true;mat.normal_texture=texture
				"roughness":mat.roughness_texture=texture;mat.roughness_texture_channel=BaseMaterial3D.TEXTURE_CHANNEL_RED
				"ao":mat.ao_enabled=true;mat.ao_texture=texture
			pending.erase(task);requested.erase(task.path);assigned+=1
		elif status==ResourceLoader.THREAD_LOAD_FAILED or status==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Texture failed: "+task.path);pending.erase(task);requested.erase(task.path)
		if assigned>=2:break
	# Drain requests whose owners disappeared, to release completed resources.
	for path in requested.keys():
		var used=false
		for task in pending:
			if task.path==path:used=true;break
		if not used and ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_LOADED:
			ResourceLoader.load_threaded_get(path);requested.erase(path)
		elif not used and ResourceLoader.load_threaded_get_status(path) in [ResourceLoader.THREAD_LOAD_FAILED,ResourceLoader.THREAD_LOAD_INVALID_RESOURCE]:requested.erase(path)

func task_priority(task:Dictionary,position:Vector3) -> float:
	var owner=task.owner.get_ref()
	if not is_instance_valid(owner) or not owner.is_inside_tree():return INF
	return owner.global_position.distance_squared_to(position)+(0.0 if task.role=="albedo" else 100000000.0)
