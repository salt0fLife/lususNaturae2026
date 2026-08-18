extends RigidBody3D


@export var data : Array = []
var tool_tip : String= ""
var stuck : bool = false
var style : int = 0

func _ready():
	freeze = stuck
	update_graphics_from_data()
	PlayerInformation.connect("changed_using_senses", update_from_senses)
	update_from_senses()

func update_graphics_from_data() -> void:
	$Label3D.text = str(data[0])
	tool_tip = "pickup "+str(data[0])
	#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
	var item_data = Items.list[data[0]]
	var model = load(item_data[Items.INDEX_MODEL]).instantiate()
	style = item_data[Items.INDEX_STYLE]
	var mat_1 = $senses_helper/MeshInstance3D2.get_active_material(0).duplicate()
	mat_1.albedo_color = Items.style_colors[style]
	$senses_helper/MeshInstance3D2.set_surface_override_material(0,mat_1)
	#model.rotation.x = PI*0.5
	#model.rotation.z = PI*0.5
	#model.rotation.y = randf_range(-PI, PI)
	add_child(model)
	#if !data.has({}):
		#data.append({})

func interact():
	return [Global.interact_returns.PICKUP_ITEM,get_path()]

func update_from_senses() -> void:
	$Label3D.visible = !PlayerInformation.using_senses
	$senses_helper.visible = PlayerInformation.using_senses
