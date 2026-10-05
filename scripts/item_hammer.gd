extends item
class_name item_hammer

var item_type = Items.type.HAMMER
@export var damage: int = 1
@export var attack_speed : float = 1.0
@export var damage_type : Global.damage_types
@export var vfx_method_name : String
#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]

func get_data() -> Array:
	return [attack_speed, damage, damage_type, vfx_method_name]

func get_item() -> Array:
	return [display_name,item_style,sounds,item_type, get_data(), texture_path,model_path,animations, has_deformations,equipment_id,collision_shape]
