extends Node3D
@export var item_key : String
@export var custom_data : Dictionary = {}
@export var stuck: bool = false

func _ready():
	for x in get_children(false):
		x.hide()

func get_spawn_info() -> Array:
	var data = [item_key,custom_data]
	return [position,rotation,stuck,data]

