extends item
class_name item_sword

var item_type = Items.type.SWORD
@export var damage: int = 1

#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]

func get_data() -> Array:
	return []

func get_item() -> Array:
	return [display_name,item_style,sounds,item_type, get_data(), texture_path,model_path,animations]
