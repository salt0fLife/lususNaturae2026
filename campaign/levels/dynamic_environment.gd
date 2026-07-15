extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time = PlayerInformation.world_time
	if time > 0.5:
		change_to_preset("night")
	else:
		change_to_preset("day")
	return
	
	#var tod = "midday"
	#if time > 0.5:
		#tod = "night"
		#if time > (0.9):
			#tod = "dawn"
		#elif time < (0.6):
			#tod = "dusk"
	#elif time > (0.5-0.125):
		#tod = "evening"
	#elif time < 0.125:
		#tod = "morning"
	#change_to_preset(tod)

const presets = {
	"night" : [
		#clouds
		{
			"ambientColorDefault" : Color.BLACK,
			"sunColorMult" : Color("030303"),
		},
		#environment sky
		{
			"rayleigh_coefficient" : 2.0,
			"rayleigh_color" : Color.BLACK,
			"mie_color" : Color("2c3343"),
			"mie_eccentricity" : 0.8,
		},
		#sun
		{
			"light_color" : Color("c2cfde"),
			"light_energy" : 1.0,
		}
	],
	"day" : [
		#clouds
		{
			"ambientColorDefault" : Color("5f5243"),
			"sunColorMult" : Color("92675c"),
		},
		#environment sky
		{
			"rayleigh_coefficient" : 2.0,
			"rayleigh_color" : Color("4d6799"),
			"mie_color" : Color("b0bacf"),
			"mie_eccentricity" : 0.8,
		},
		#sun
		{
			"light_color" : Color("f3dece"),
			"light_energy" : 4.0,
		}
	]
	
	
}

var current_preset = ""
var blend_duration = 2.0
func change_to_preset(key : StringName) -> void:
	if key == current_preset:
		return
	if !presets.has(key):
		return
	var preset = presets[key]
	
	for c_s in preset[0].keys(): #cloud settings
		#$CloudsSystem.set(c_s,preset[0][c_s])
		var t = get_tree().create_tween()
		t.tween_property($CloudsSystem,c_s,preset[0][c_s],blend_duration)
		
	for e_s in preset[1].keys(): #environment sky settings
		#$WorldEnvironment.environment.sky.sky_material.set(e_s,preset[1][e_s])
		var t = get_tree().create_tween()
		t.tween_property($WorldEnvironment.environment.sky.sky_material, e_s, preset[1][e_s], blend_duration)
	for s_s in preset[2].keys(): #sun settings
		#$DirectionalLight3D2.set(s_s,preset[2][s_s])
		var t = get_tree().create_tween()
		t.tween_property($DirectionalLight3D2,s_s,preset[2][s_s],blend_duration)
		pass
	
	
	pass
