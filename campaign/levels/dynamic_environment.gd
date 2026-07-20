@tool
extends Node3D
@export var set_preset = "day"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		change_to_preset(set_preset)
		return
	
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
			"cloudsCutoff" : -0.014,
			"cloudShadowStrength" : 0.9,
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
			"light_color" : Color("2c3847"),
			"light_energy" : 1.0,
			"shadow_blur" : 7.15,
		},
		#environment environment
		{
			"ambient_light_source" : 2,
			"ambient_light_color" : Color("181d15"),
			"ambient_light_energy" : 2.0,
			"glow_bloom" : 0.0,
			"glow_hdr_threshold" : 0.5,
		},
		#day color influence
		0.0
	],
	"day" : [
		#clouds
		{
			"ambientColorDefault" : Color("5f5243"),
			"sunColorMult" : Color("92675c"),
			#"cloudsCutoff" : 0.443,
			"cloudsCutoff" : 0.101,
			"cloudShadowStrength" : 0.4,
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
			"light_energy" : 1.5,
			"shadow_blur" : 1.0,
		},
		#environment environment
		{
			"ambient_light_source" : 0,
			"ambient_light_color" : Color.BLACK,
			"ambient_light_energy" : 1.0,
			"glow_bloom" : 0.09,
			"glow_hdr_threshold" : 0.54,
		},
		#day color influence
		1.0
	]
	
	
}

var current_preset = ""
var blend_duration = 1.0
func change_to_preset(key : StringName) -> void:
	if key == current_preset:
		return
	current_preset = key
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
	for ee_s in preset[3].keys():
		var val = preset[3][ee_s]
		if typeof(val) == TYPE_INT: #for multiple choice
			$WorldEnvironment.environment.set(ee_s,val)
		else:
			var t = get_tree().create_tween()
			t.tween_property($WorldEnvironment.environment,ee_s,val,blend_duration)
	
	var d_c_t = get_tree().create_tween()
	d_c_t.tween_method(set_day_color_influence, last_day_color_influence,preset[4],blend_duration)

var last_day_color_influence = 0.0
func set_day_color_influence(val : float) -> void:
	last_day_color_influence = val
	RenderingServer.global_shader_parameter_set("day_color_influence", val)
