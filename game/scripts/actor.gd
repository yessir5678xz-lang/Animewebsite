extends Node3D
var last=Vector3.ZERO
var clock=0.0
var skeleton:Skeleton3D
var attack_time=0.0
var category="slash"
func _ready() -> void:
	last=global_position
	skeleton=get_node_or_null("Skeleton3D")
func _process(delta:float) -> void:
	if not is_instance_valid(skeleton):skeleton=get_node_or_null("Skeleton3D")
	if not skeleton:return
	var speed=global_position.distance_to(last)/maxf(delta,.001);last=global_position
	clock+=delta*(8 if speed>.1 else 1)
	var stride=sin(clock)*minf(speed*.08,.65)
	skeleton.set_bone_pose_rotation(4,Quaternion(Vector3.RIGHT,stride))
	skeleton.set_bone_pose_rotation(5,Quaternion(Vector3.RIGHT,-stride))
	skeleton.set_bone_pose_rotation(2,Quaternion(Vector3.RIGHT,-stride*.6))
	skeleton.set_bone_pose_rotation(3,Quaternion(Vector3.RIGHT,stride*.6))
	skeleton.set_bone_pose_position(0,Vector3(0,1.05+sin(clock*2)*(.025 if speed>.1 else .009),0))
	if attack_time>0:
		attack_time-=delta
		var swing=sin(attack_time*12)*1.5
		match category:
			"thrust","arrow","bolt":skeleton.set_bone_pose_rotation(3,Quaternion(Vector3.RIGHT,-1.4))
			"dual":
				skeleton.set_bone_pose_rotation(2,Quaternion(Vector3.FORWARD,-swing))
				skeleton.set_bone_pose_rotation(3,Quaternion(Vector3.FORWARD,swing))
			_:skeleton.set_bone_pose_rotation(3,Quaternion(Vector3.FORWARD,swing))
func animate_attack(effect:String) -> void:
	category=effect;attack_time=.5
