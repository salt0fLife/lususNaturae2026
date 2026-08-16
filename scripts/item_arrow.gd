extends item
class_name item_arrow

var item_type = Items.type.ARROW
@export var damage_amount : int
@export var damage_type : Global.damage_types
@export var drag: float = 0.01
@export var gravity:float = 0.5

#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]

func get_data() -> Array:
	return [damage_amount,damage_type,drag,gravity]

func get_item() -> Array:
	return [display_name,item_style,sounds,item_type, get_data(), texture_path,model_path,animations, has_deformations,equipment_id]
