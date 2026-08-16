extends item
class_name item_gun

var item_type = Items.type.GUN
@export var damage: int = 1
@export var attack_speed : float = 1.0
@export var damage_type : Global.damage_types
#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]

func get_data() -> Array:
	return [attack_speed, damage, damage_type]

func get_item() -> Array:
	return [display_name,item_style,sounds,item_type, get_data(), texture_path,model_path,animations, has_deformations,equipment_id]
