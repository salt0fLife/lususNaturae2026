extends DirectionalLight3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time = PlayerInformation.world_time
	if time > 0.5: #is night
		rotation = Vector3(-PI*time*2.0+PI,-0.9,2.76)
		#light_color = Color("101015")
		#light_energy = 2.0
	else:
		rotation = Vector3(-PI*time*2.0,-0.9,2.76)
		#light_color = Color("e1d3c8")
		#light_energy = 4.0
