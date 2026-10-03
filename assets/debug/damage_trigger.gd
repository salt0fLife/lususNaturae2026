extends Area3D
@export var damage_amount : int = 10
@export var damage_type : Global.damage_types

func _ready():
	Global.connect("update_debug_render",update_debug_render)
	update_debug_render(Global.debug_render)

func update_debug_render(val : bool) -> void:
	$MeshInstance3D.visible = val



func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage_amount,damage_type)
	else:
		printerr("hurtbox node missing take_damage method : " + str(body))
