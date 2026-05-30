extends StaticBody3D


var data = []

func _ready():
	update_graphics_from_data()
	PlayerInformation.connect("changed_using_senses", update_from_senses)
	update_from_senses()

func update_graphics_from_data() -> void:
	$Label3D.text = str(data[0])
	#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
	var item_data = Items.list[data[0]]
	var model = load(item_data[Items.INDEX_MODEL]).instantiate()
	model.rotation.x = PI*0.5
	model.rotation.z = PI*0.5
	model.rotation.y = randf_range(-PI, PI)
	add_child(model)

func interact():
	return [Global.interact_returns.PICKUP_ITEM,get_path()]

func update_from_senses() -> void:
	$senses_helper.visible = PlayerInformation.using_senses
