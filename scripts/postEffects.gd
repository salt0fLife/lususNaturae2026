extends TextureRect
var smooth_reset = false

var active_changes = {
}
const base_overiding_keys = { #was going to have this kind of set the basis for everything around it
	"underwater" : {
	},
	"sun_sickness" : {}
}

func _ready():
	Global.connect("change_level",set_to_default)
	PlayerInformation.connect("perished", set_to_default)
	Global.connect("play_cutscene_signal",set_to_default)
	Global.connect("set_post_param_signal", _on_global_set_post_param)
	Global.connect("set_post_pact_signal",_on_global_set_pact)

func _on_global_set_post_param(key, value) -> void:
	if base_overiding_keys.has(key):
		if active_changes.has(key):
			match typeof(value):
				TYPE_BOOL: active_changes[key] = value
				TYPE_COLOR: active_changes[key] = (active_changes[key] + value)*0.5
				TYPE_INT: active_changes[key] = int(float(active_changes[key] + value)*0.5)
				TYPE_FLOAT: active_changes[key] = (active_changes[key] + value)*0.5
				_: active_changes[key] = value
			value = active_changes[key]
		else:
			active_changes[key] = value
	return #not actually setting a thing more like setting basis for thing
	if key == "DEFAULT":
		clear_changes()
		set_to_default()
		return
	if key == "smooth_reset":
		smooth_reset = value
		return
	material.set(key, value)

var pacts = {
	"sun_sickness" : 0.0,
	"underwater" : 0.0
}

var set_underwater = false
func _process(delta):
	
	pass

func _on_global_set_pact(key:StringName, value:float) -> void:
	pacts[key] = value
	update_pacts()
	pass

func update_pacts() -> void:
	for k in pacts.keys():
		match k:
			"underwater" : 
				material.set("shader_parameter/flash", pacts[k]*0.3)
				material.set("shader_parameter/wave", pacts[k]*0.235)
				pass
	
	pass

func clear_changes() -> void:
	active_changes = {}
	for p in pacts.keys():
		pacts[p] = 0.0

#var ss = 0.0
#func _process(delta):
	##if ss != PlayerInformation.sun_sickness:
		##ss= PlayerInformation.sun_sickness
		##material.set("shader_parameter/heart_pounding",ss)
		##material.set("shader_parameter/wave",ss*0.2)
		##material.set("shader_parameter/burning",ss == 1.0)
	##if !smooth_reset:
		##return
	##var val = material.get("shader_parameter/wave") - delta
	##if val < 0.0:
		##val = 0.0
		##smooth_reset = false
	##material.set("shader_parameter/wave", val)
	##material.set("shader_parameter/flash", val)
	#pass

func set_to_default():
	material.set("shader_parameter/heart_pounding",0.0)
	material.set("shader_parameter/burning", false)
	material.set("shader_parameter/wave",false)
	material.set("shader_parameter/flash",0.0)
	pass
