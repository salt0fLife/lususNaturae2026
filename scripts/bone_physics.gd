@tool
extends Node
@export var skeleton : Skeleton3D
@export var looseness : float = 0.5 #oposite force multiplier
@export var effected_bones :Array[StringName]
@export var update_effected_bones : bool = false
var bone_indexes : Array[int] = []
@export var root_motion_node : Node3D
@export var return_speed : float = 100.0
@export var damp : float = 10.0
var vel_rot : Vector3 = Vector3.ZERO
@export var enabled : bool = true

func _ready():
	pos_last_frame = root_motion_node.global_position
	update_bone_indexes()

func update_bone_indexes() -> void:
	bone_indexes = []
	for k in effected_bones:
		var i = skeleton.find_bone(k)
		if !bone_indexes.has(i):
			if i != -1:
				bone_indexes.append(i)

var pos_last_frame : Vector3
func _physics_process(delta):
	if update_effected_bones:
		update_bone_indexes()
		update_effected_bones = false
	if !enabled:
		return
	var motion = root_motion_node.global_position - pos_last_frame
	var relative_motion =  -root_motion_node.to_local(pos_last_frame)
	pos_last_frame = root_motion_node.global_position
	
	#if relative_motion != Vector3.ZERO:
		#print(relative_motion)
	
	#looseness
	for i in bone_indexes:
		var pose = skeleton.get_bone_pose_rotation(i)
		vel_rot.z += relative_motion.x * looseness
		vel_rot.x -= relative_motion.z * looseness
		pose.z += relative_motion.x * looseness
		pose.x -= relative_motion.z * looseness
		skeleton.set_bone_pose_rotation(i,pose)
	settle_bones(delta)
	
	#dampening
	vel_rot -= vel_rot*delta*damp
	
	#apply velocity
	for i in bone_indexes:
		var pose = skeleton.get_bone_pose_rotation(i).normalized()
		#var desired_pose = skeleton.get_bone_rest(i).basis.get_rotation_quaternion()
		#pose.x = clamp(pose.x + vel_rot.x *delta, -rotation_clamp,rotation_clamp)
		#pose.z = clamp(pose.z + vel_rot.z *delta, -rotation_clamp,rotation_clamp)
		#pose.y = clamp(pose.y + vel_rot.y *delta, -rotation_clamp,rotation_clamp)
		pose.x += vel_rot.x *delta
		pose.z += vel_rot.z *delta
		pose.y += vel_rot.y *delta
		skeleton.set_bone_pose_rotation(i,pose)

func settle_bones(delta:float):
	for i in bone_indexes:
		var pose = skeleton.get_bone_pose_rotation(i).normalized()
		var desired_pose = skeleton.get_bone_rest(i).basis.get_rotation_quaternion()
		var dif = desired_pose - pose
		vel_rot.x += dif.x*return_speed*delta
		vel_rot.z += dif.z*return_speed*delta
		vel_rot.y += dif.y*return_speed*delta
		#pose = lerp(pose,desired_pose,delta*return_speed)
		#skeleton.set_bone_pose_rotation(i,pose)
