extends item
class_name item_food

var item_type = Items.type.FOOD
@export var food_type: Items.food_type
@export var food_value: int = 1

#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]

func get_data() -> Array:
	return [food_value,food_type]

func get_item() -> Array:
	return [display_name,item_style,sounds,item_type, get_data(), texture_path,model_path,animations, has_deformations,equipment_id]
