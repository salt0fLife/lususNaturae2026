extends item
class_name item_bag

var item_type = Items.type.BAG
@export var max_capacity: int = 10

#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]

func get_data() -> Array:
	return [max_capacity]

func get_item() -> Array:
	return [display_name,item_style,sounds,item_type, get_data(), texture_path,model_path,animations, has_deformations,equipment_id,collision_shape]
