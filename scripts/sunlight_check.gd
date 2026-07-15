extends Node3D
var check_distance = 100.0

func in_sunlight_pecentage():
	var time = PlayerInformation.world_time
	if time > 0.5: #is night
		return 0.0
	var multiplier = (sin(time*2.0*PI)+1.0)*0.5
	var sun_rotation = Vector3(-PI*time*2.0,-0.9,2.76)
	var val = 0.0
	var child_count = get_child_count(false)
	for r in get_children(false):
		r.target_position = Vector3(0.0,0.0,check_distance)
		r.rotation = sun_rotation
		if !r.is_colliding(): #is in sun
			val += 1.0/child_count
	return val*multiplier

func get_sun_rotation() -> Vector3:
	var time = PlayerInformation.world_time
	if time > 0.5:
		return Vector3.ZERO;
	return Vector3(-PI*time*2.0,-0.9,2.76)
