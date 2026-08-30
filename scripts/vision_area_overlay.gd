extends Node3D

@onready var vision_area_sense = $vision_area_sense
# Called when the node enters the scene tree for the first time.
func _ready():
	vision_area_sense.connect("body_entered", _on_vision_area.bind(true))
	vision_area_sense.connect("body_exited", _on_vision_area.bind(false))


func _on_vision_area(body, entering:bool) -> void:
	var groups = body.get_groups()
	var s_info = Global.get_surface_info(groups)
	if s_info.has(Global.SCREEN_FILTER):
		print("set water screen filter to " + str(entering))
		var val = 0.0
		if entering:
			val = 1.0
		Global.set_post_pact("underwater", val)
