extends TextureRect


func set_effect(key : StringName, val) -> void:
	material.set(("shader_parameter/"+key), val)

var ss = 0.0
func _process(delta):
	if ss != PlayerInformation.sun_sickness:
		ss= PlayerInformation.sun_sickness
		set_effect("sun_sickness",ss)
