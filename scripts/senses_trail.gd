@tool
extends Node3D


@onready var graphics_handler = $graphics_handler
var points_list: PackedVector3Array = []
@export var material: StandardMaterial3D
var senses_only: bool = true
@export var width: float = 0.25
@export var max_points: int = 25
@export var distance_between_points:float = 0.25


func test_draw_lines():
	for old in graphics_handler.get_children(false):
		old.queue_free()
	
	for i in points_list.size():
		var previous_pos = global_position
		if i != points_list.size()-1:
			previous_pos = points_list[i+1]
		var pos = points_list[i]
		
		var average_pos = (previous_pos + pos) * Vector3(0.5,0.5,0.5)
		var dif = previous_pos - pos
		var y_rot = atan2(dif.z,dif.x)
		var flat_dis = Vector2(dif.x,dif.z).length()
		var x_rot = atan2(flat_dis,dif.y)
		
		var test_display = MeshInstance3D.new()
		test_display.mesh = BoxMesh.new()
		test_display.set_surface_override_material(0,material)
		test_display.set_layer_mask_value(1,!senses_only)
		test_display.set_layer_mask_value(2,senses_only)
		
		test_display.position = average_pos
		test_display.rotation.y = -y_rot+PI*0.5
		test_display.rotation.x = x_rot+PI*0.5
		test_display.scale.z = dif.length()
		test_display.scale.x = width
		test_display.scale.y = width
		
		graphics_handler.add_child(test_display)


func test_draw_planes():
	for old in graphics_handler.get_children(false):
		old.queue_free()
	
	for i in points_list.size():
		var previous_pos = global_position
		if i != points_list.size()-1:
			previous_pos = points_list[i+1]
		var pos = points_list[i]
		
		var average_pos = (previous_pos + pos) * Vector3(0.5,0.5,0.5)
		var dif = previous_pos - pos
		var y_rot = atan2(dif.z,dif.x)
		var flat_dis = Vector2(dif.x,dif.z).length()
		var x_rot = atan2(flat_dis,dif.y)
		
		var test_display = MeshInstance3D.new()
		test_display.mesh = PlaneMesh.new()
		test_display.set_surface_override_material(0,material)
		test_display.set_layer_mask_value(1,!senses_only)
		test_display.set_layer_mask_value(2,senses_only)
		
		test_display.position = average_pos+Vector3(0.0,width,0.0)
		test_display.rotation.y = -y_rot+PI*0.5
		test_display.rotation.x = x_rot+PI*0.5
		test_display.rotation.z = PI*0.5
		test_display.scale.z = dif.length()*0.5
		test_display.scale.x = width
		test_display.scale.y = width
		
		graphics_handler.add_child(test_display)

func test_draw():
	for old in graphics_handler.get_children(false):
		old.queue_free()
	for pos in points_list:
		var test_display = MeshInstance3D.new()
		test_display.mesh = SphereMesh.new()
		test_display.position = pos
		graphics_handler.add_child(test_display)


func _process(delta):
	if points_list.is_empty():
		points_list.append(global_position)
	
	var last_point = points_list[points_list.size()-1]
	var dif = global_position - last_point
	if dif.length() > distance_between_points:
		points_list.append(global_position)
	
	if points_list.size() > max_points:
		points_list.remove_at(0)
	
	if Engine.is_editor_hint() or PlayerInformation.using_senses:
		test_draw_planes()
	#test_draw()
	pass
