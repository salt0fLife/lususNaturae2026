extends Node3D

var camera = null

func _process(delta):
	if camera == null:
		camera = get_viewport().get_camera_3d()
	else:
		position = camera.global_position
