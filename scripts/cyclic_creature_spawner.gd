extends Node3D




func _process(delta):
	var time = Global.world_time
	if time < 0.5:
		spawn_sky_fish(delta)

func rand_vec3(min:float,max:float) -> Vector3:
	var x:float = randf_range(min,max)
	var y:float = randf_range(min,max)
	var z:float = randf_range(min,max)
	return Vector3(x,y,z)

var sky_fish_spawn_timer: float = 0.0
func spawn_sky_fish(delta):
	sky_fish_spawn_timer += delta
	if sky_fish_spawn_timer > 0.5:
		sky_fish_spawn_timer = 0.0
		
		#spawn fish
		var pos = PlayerInformation.position * Vector3(1.0,0.0,1.0)
		pos -= Global.NORTH_DIR*300.0
		pos += rand_vec3(-200.0,200.0)
		#pos.y += 200.0
		pos.y = abs(pos.y) #never negative
		Global.spawn_entity("young_skyfish",pos)
		#functionality test first
		#var skyfish = load("res://campaign/entities/young_skyfish.tscn").instantiate()
		#skyfish.position = pos
		#add_child(skyfish)
		pass
