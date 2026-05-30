extends Node3D

# 1 is seen by both, all terrain entity models,etc. 2 is only seen with inhanced senses, 
# 3 is seen with human senses (ie sound and feel), 4 is only seen by eyes (ie any lights in the scene)

func _ready():
	update_senses()
	PlayerInformation.connect("changed_using_senses", update_senses)

func _input(event):
	if Input.is_action_just_pressed("toggle_senses"):
		PlayerInformation.set_using_senses(!PlayerInformation.using_senses)

func update_senses() -> void:
	#var t = get_tree().create_tween()
	#t.tween_property($blackout, "color", Color.BLACK, 0.1)
	#await t.finished
	$blackout.set("color", Color.BLACK)
	if PlayerInformation.using_senses:
		$smell_camera.make_current()
		print("using senses")
	else:
		$sight_camera.make_current()
		print("using eyes")
	var t2 = get_tree().create_tween()
	t2.tween_property($blackout, "color", Color.WHITE, 0.4)

func set_fov(val : float) -> void:
	$sight_camera.fov = val
	$smell_camera.fov = val
