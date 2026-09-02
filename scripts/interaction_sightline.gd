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

var updating_focus = true
var last_col = null
func _process(delta):
	if updating_focus:
		if sight.is_colliding():
			var hit = sight.get_collider()
			if last_col != hit:
				if last_col != null and last_col.get_groups().has("track_focus"):
					last_col.update_focus(false)
				if hit.get_groups().has("track_focus"):
					hit.update_focus(true)
				last_col = hit
		elif last_col != null:
			if last_col.get_groups().has("track_focus"):
				last_col.update_focus(false)
			last_col = null
