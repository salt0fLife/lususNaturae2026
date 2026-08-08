@tool
extends Node3D

@export var apply : bool = false

@export_category("phase settings")
@export var max_rotation : Vector3 = Vector3.ZERO
@export var min_rotation : Vector3 = Vector3.ZERO
@export var max_scale : Vector3 = Vector3.ONE
@export var min_scale : Vector3 = Vector3.ONE


func _process(delta):
	if apply:
		apply = false
		randomize_phase()

func get_random_vec3(min : Vector3, max : Vector3) -> Vector3:
	var x = randf_range(min.x,max.x)
	var y = randf_range(min.y,max.y)
	var z = randf_range(min.z,max.z)
	return Vector3(x,y,z)

func randomize_phase() -> void:
	print("started randomizing phase")
	for n in get_children(false):
		n.rotation_degrees = get_random_vec3(min_rotation,max_rotation)
		n.scale = get_random_vec3(min_scale,max_scale)
	print("finished randomizing phase")
