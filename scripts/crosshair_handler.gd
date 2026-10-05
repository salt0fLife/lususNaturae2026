extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInformation.connect("update_held_item", update_crosshair_type)
	update_crosshair_type()
	pass # Replace with function body.

@onready var display = $TextureRect
func update_crosshair_type() -> void: 
	var item_data = PlayerInformation.get_held_item_data()
	display.visible = false
	if item_data.is_empty():
		return
	match item_data[Items.INDEX_TYPE]:
		Items.type.SWORD:
			display.visible = true
