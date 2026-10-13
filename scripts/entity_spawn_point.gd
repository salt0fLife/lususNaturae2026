extends Node3D

@export var entity_key : StringName
@export var custom_data : Array = []

func _ready():
	for x in get_children(false):
		x.hide()

func get_spawn_info() -> Array:
	var data = [position,Vector2(rotation.x,rotation.y),custom_data]
	return [entity_key,data,position]
