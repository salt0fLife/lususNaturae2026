extends RigidBody3D


@export var data : Array = []
var tool_tip : String= ""
var stuck : bool = false
var style : int = 0

func _ready():
	freeze = stuck
	update_collision_shape()
	update_graphics_from_data()
	PlayerInformation.connect("changed_using_senses", update_from_senses)
	update_from_senses()
	Global.connect("update_debug_render",set_debug_render)

func update_collision_shape() -> void:
	var bounds:Vector3 = Items.list[data[0]][Items.INDEX_COLLISION_SHAPE]#data[Items.INDEX_COLLISION_SHAPE]
	var shape = BoxShape3D.new()
	shape.size = bounds
	$CollisionShape3D2.shape = shape
	#$MeshInstance3D.scale = bounds
	$selected/MeshInstance3D.scale = bounds

func update_graphics_from_data() -> void:
	$selected/Label3D.text = str(data[0])
	tool_tip = "pickup "+str(data[0])
	#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
	var item_data = Items.list[data[0]]
	var model = load(item_data[Items.INDEX_MODEL]).instantiate()
	style = item_data[Items.INDEX_STYLE]
	var mat_1 = $senses_helper/MeshInstance3D2.get_active_material(0).duplicate()
	mat_1.albedo_color = Items.style_colors[style]
	$senses_helper/MeshInstance3D2.set_surface_override_material(0,mat_1)
	var tex = load(item_data[Items.INDEX_TEXTURE])
	$selected/Sprite3D.texture = tex
	#model.rotation.x = PI*0.5
	#model.rotation.z = PI*0.5
	#model.rotation.y = randf_range(-PI, PI)
	add_child(model)
	#if !data.has({}):
		#data.append({})

func interact():
	return [Global.interact_returns.PICKUP_ITEM,get_path()]

func update_from_senses() -> void:
	#$Label3D.visible = !PlayerInformation.using_senses
	$senses_helper.visible = PlayerInformation.using_senses

func update_focus(val:bool) -> void:
	#$MeshInstance3D.visible = val
	#$Sprite3D.visible = val
	#$Label3D.visible = val
	$selected.visible = val
	pass

func set_debug_render(val : bool ) -> void:
	if val:
		settup_debug_render()
	#$debug_render.visible = val
	$selected/debug_render.visible = val
	pass

func settup_debug_render() -> void:
	if data.is_empty():
		$selected/debug_render/debug_label.text = "[ empty ]"
		return
	$selected/debug_render/debug_label.text = data[0]
	var offset = 10.0
	for a in data[1].keys():
		var l = $selected/debug_render/debug_label.duplicate()
		l.text = a
		var l2 = l.duplicate()
		l2.text = str(data[1][a])
		l.offset.y = offset
		offset += 20.0
		l2.offset.y = offset
		offset += 20.0
		$selected/debug_render.add_child(l)
		$selected/debug_render.add_child(l2)
