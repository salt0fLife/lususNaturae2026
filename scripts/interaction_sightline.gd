extends Node3D

signal interacted


func _input(event):
	if Input.is_action_just_pressed("interact"):
		attempt_interact()

@onready var sight = $RayCast3D
func attempt_interact() -> void:
	if sight.is_colliding():
		var hit = sight.get_collider()
		if hit.is_in_group("interactable"):
			var info = hit.interact()
			emit_signal("interacted", info)

func get_tooltip() -> String:
	if sight.is_colliding():
		var hit = sight.get_collider()
		if hit == null:
			return ""
		if hit.is_in_group("interactable"):
			return hit.tool_tip
	return "" #nothin
