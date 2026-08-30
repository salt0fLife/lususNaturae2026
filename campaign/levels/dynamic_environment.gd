@tool
extends Node3D
@export var set_preset = "day"

func _ready():
	Settings.connect("updated_graphics",_on_graphics_settings_changed)

func _on_graphics_settings_changed() -> void:
	change_to_preset(get_current_preset(Global.world_time),true)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		change_to_preset(set_preset)
		return
	
	#var time = PlayerInformation.world_time
	var time = Global.world_time
	change_to_preset(get_current_preset(time))
	
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

func get_current_preset(time : float) -> StringName:
	if time > 0.5:
		return"night"
	else:
		return"day"

const graphics_settings ={
	Settings.FAST : presets,
	Settings.FANCY : presets,
	Settings.FABULOUS : presets,
}

const presets = {
	"night" : [
		#clouds
		{
			"ambientColorDefault" : Color("000101"),
			"sunColorMult" : Color("141416"),#("030303"),
			#"cloudsCutoff" : -0.014,
			"cloudShadowStrength" : 0.9,
		},
		#environment sky
		{
			#"rayleigh_coefficient" : 2.0,
			#"rayleigh_color" : Color.BLACK,
			#"mie_color" : Color("2c3343"),
			#"mie_eccentricity" : 0.8,
			"shader_parameter/physical_effect": 1.0,
			"shader_parameter/rayleigh_color" : Color("7490c4"),
			"shader_parameter/mie" : 0.1444,
			"shader_parameter/mie_eccentricity" : 0.532,
			"shader_parameter/mie_color" : Color("b0bacf"),
			"shader_parameter/ground_color" : Color("6573d5"),#Color("47190c"),
			"shader_parameter/exposure" : 2.273,
			"shader_parameter/top_color" : Color("3c4649"),
			"shader_parameter/bottom_color" : Color("2f382b"),#Color("090909"),
			"shader_parameter/sun_scatter" : Color("181113"),
			"shader_parameter/astro_scale" : 5.2,
			"shader_parameter/stars_intensity" : 1.8,
		},
		#sun
		{
			#"light_color" : Color("2c3847"),
			"light_color" : Color("d5e2e8"),#Color("98a9b2"),
			"light_energy" : 1.0,
			"shadow_blur" : 7.15,
		},
		#environment environment
		{
			"ambient_light_source" : 2,
			"ambient_light_color" : Color("181d15"),
			"ambient_light_energy" : 2.0,
			"glow_bloom" : 0.0,
			"glow_hdr_threshold" : 1.0,#0.5,
			"glow_intensity" : 0.8,
			"glow_strength" : 1.0
		},
		#day color influence
		0.0,
		#lens_flare attunation
		0.05,
	],
	"day_smoldering" : [
		#clouds
		{
			"ambientColorDefault" : Color("5f5243"),
			"sunColorMult" : Color("92675c"),
			#"cloudsCutoff" : 0.443,
			#"cloudsCutoff" : 0.101,
			"cloudShadowStrength" : 0.4,
		},
		#environment sky
		{
			#"rayleigh_coefficient" : 2.0,
			#"rayleigh_color" : Color("4d6799"),
			#"mie_color" : Color("b0bacf"),
			#"mie_eccentricity" : 0.8,
			"shader_parameter/physical_effect": 1.0,
			"shader_parameter/rayleigh_color" : Color("b3adc6"),
			"shader_parameter/mie" : 0.01,
			"shader_parameter/mie_eccentricity" : 0.8,
			"shader_parameter/mie_color" : Color("b0bacf"),
			"shader_parameter/ground_color" : Color("47190c"),
			"shader_parameter/exposure" : 1.0,
			"shader_parameter/top_color" : Color("deefed"), #hehe deefed
			"shader_parameter/bottom_color" : Color("eddbd8"),
			"shader_parameter/sun_scatter" : Color("ffddb5"),
			"shader_parameter/astro_scale" : 5.2,
			"shader_parameter/stars_intensity" : 0.0,
		},
		#sun
		{
			"light_color" : Color("f3dece"),
			"light_energy" : 1.5,
			"shadow_blur" : 1.0,
		},
		#environment environment
		{
			"ambient_light_source" : 2,
			"ambient_light_color" : Color("427397"),
			"ambient_light_energy" : 1.0,
			"glow_bloom" : 0.09,
			"glow_hdr_threshold" : 1.0,#0.54,
			"glow_intensity" : 0.8,
			"glow_strength" : 1.0
		},
		#day color influence
		1.0,
		#lens_flare attunation
		0.5,
	],
	"day" : [
		#clouds
		{
			"ambientColorDefault" : Color("5f5243"),
			"sunColorMult" : Color("92675c"),
			#"cloudsCutoff" : 0.443,
			#"cloudsCutoff" : 0.101,
			"cloudShadowStrength" : 0.4,
		},
		#environment sky
		{
			#"rayleigh_coefficient" : 2.0,
			#"rayleigh_color" : Color("4d6799"),
			#"mie_color" : Color("b0bacf"),
			#"mie_eccentricity" : 0.8,
			"shader_parameter/physical_effect": 1.0,
			"shader_parameter/rayleigh_color" : Color("8ad9f6"),
			"shader_parameter/mie" : 0.01,
			"shader_parameter/mie_eccentricity" : 0.8,
			"shader_parameter/mie_color" : Color("b0bacf"),
			"shader_parameter/ground_color" : Color("47190c"),
			"shader_parameter/exposure" : 1.5,
			"shader_parameter/top_color" : Color("6fa3e8"), #not deefed anymore :(
			"shader_parameter/bottom_color" : Color("1d9add"),
			"shader_parameter/sun_scatter" : Color("ffddb5"),
			"shader_parameter/astro_scale" : 5.2,
			"shader_parameter/stars_intensity" : 0.0,
		},
		#sun
		{
			"light_color" : Color("f3dece"),
			"light_energy" : 1.4,
			"shadow_blur" : 1.0,
		},
		#environment environment
		{
			"ambient_light_source" : 0,
			"ambient_light_color" : Color("427397"),
			"ambient_light_energy" : 1.0,
			"glow_bloom" : 0.03,
			"glow_hdr_threshold" : 1.0,#0.54,
			"glow_intensity" : 0.59,
			"glow_strength" : 1.23
		},
		#day color influence
		1.0,
		#lens_flare attunation
		0.25,
	]
	
}

func get_astro_texture():
	#if PlayerInformation.world_time > 0.5: #is night time
	if Global.world_time > 0.5: #is night time
		return load("res://assets/textures/sky/moon_phases/full.png")
	else: #is day
		return load("res://assets/textures/sky/moon_phases/sunShape.png")

var current_preset = ""
var blend_duration = 1.0
func change_to_preset(key : StringName,bypass_key_check:bool=false) -> void:
	if key == current_preset and !bypass_key_check:
		return
	current_preset = key
	if !presets.has(key):
		return
	
	$WorldEnvironment.environment.sky.sky_material.set("shader_parameter/astro_sampler", get_astro_texture())
	
	var preset# = presets[key]
	var quality = Settings.graphics["environment_quality"]
	if graphics_settings.has(quality):
		preset = graphics_settings[quality][key]
	else:
		preset = presets[key] #is the default
	
	
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
	$DirectionalLight3D2/fancy_lens_flare.attunation_mult = preset[5]

var last_day_color_influence = 0.0
func set_day_color_influence(val : float) -> void:
	last_day_color_influence = val
	RenderingServer.global_shader_parameter_set("day_color_influence", val)
