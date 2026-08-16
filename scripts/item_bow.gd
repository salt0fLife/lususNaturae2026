extends item
class_name item_bow

var item_type = Items.type.BOW
@export var quiver_size: int = 10
@export var max_launch_speed: float = 10.0 #max arrow speed launched (limits good arrows in bad bows)
@export var launch_speed_mult: float = 1.0 #multiplies arrows base_speed
@export var min_charge_time: float = 0.5 #mininum amount of time to be drawn before its accurate

#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]

func get_data() -> Array:
	return [min_charge_time, quiver_size,max_launch_speed,launch_speed_mult]

func get_item() -> Array:
	return [display_name,item_style,sounds,item_type, get_data(), texture_path,model_path,animations, has_deformations,equipment_id]
