@tool
extends Node3D


@export_category("point spawning")
@onready var graphics_handler = $graphics_handler
var points_list: PackedVector3Array = []
var points_lifetimes: PackedFloat32Array = []
@export var material: StandardMaterial3D
var senses_only: bool = true
@export var width: float = 0.25
@export var max_points: int = 25
@export var distance_between_points:float = 0.25

@export var natrual_point_decay: float = 5.0 #how many seconds before a point is natrually deleted

@export_category("points behavior")
@export var gravity: Vector3 = Vector3.ZERO

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

@onready var mesh_instance = $MeshInstance3D
func draw_meshing():
	mesh_instance.mesh = null
	if points_list.is_empty():
		return
	mesh_instance.global_position = Vector3.ZERO
	var arr_mesh = ArrayMesh.new()
	var vertices:PackedVector3Array = []
	var indices = PackedInt32Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	
	var upper_offset := Vector3.UP
	
	for i in range(0,points_list.size()):
		var p_1 = points_list[i]
		var p_2 = Vector3.ZERO
		if points_list.size()-2 < i:
			p_2 = global_position
		else:
			p_2 = points_list[i+1]
		#var p_2 = global_position
		#if i != 0:
			#p_2 = points_list[i-1]
		var vert_index = i*4 #4 verts per point
		vertices.append(p_1+upper_offset*0.5)
		vertices.append(p_1-upper_offset*0.5)
		vertices.append(p_2+upper_offset*0.5)
		vertices.append(p_2-upper_offset*0.5)
		#uvs
		uvs.append(Vector2(0.0,0.0))
		uvs.append(Vector2(0.0,0.0))
		uvs.append(Vector2(0.0,0.0))
		uvs.append(Vector2(0.0,0.0))
		#normals
		normals.append(upper_offset)
		normals.append(-upper_offset)
		normals.append(upper_offset)
		normals.append(-upper_offset)
		#triangle 1
		indices.append(vert_index)
		indices.append(vert_index+1)
		indices.append(vert_index+2)
		#triangle 2
		indices.append(vert_index+2)
		indices.append(vert_index+1)
		indices.append(vert_index+3)
		pass
	
	
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_INDEX] = indices
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	var m = ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	#m.material_override = material
	m.surface_set_material(0,material)
	mesh_instance.mesh = m
	
	pass

var natrual_decay_timer = 0.0
var last_decaying_point_pos = Vector3.ZERO

func _process(delta):
	natrual_decay_timer += delta
	if natrual_decay_timer > natrual_point_decay and !points_list.is_empty():
		points_list.remove_at(0)
		natrual_decay_timer = 0.0
		if !points_list.is_empty():
			last_decaying_point_pos = points_list[0]
	elif points_list.size() > 1:
		var percentage = natrual_decay_timer/natrual_point_decay
		points_list[0] = lerp(last_decaying_point_pos,points_list[1],percentage)
	
	if points_list.is_empty():
		points_list.append(global_position)
	
	var last_point = points_list[points_list.size()-1]
	var dif = global_position - last_point
	if dif.length() > distance_between_points:
		points_list.append(global_position)
	
	if points_list.size() > max_points:
		points_list.remove_at(0)
		if !points_list.is_empty():
			last_decaying_point_pos = points_list[0]
	
	update_points(delta)
	
	if Engine.is_editor_hint() or PlayerInformation.using_senses:
		#test_draw_planes()
		draw_meshing()
	#test_draw()
	pass

func update_points(delta):
	for i in range(0,points_list.size()):
		points_list[i] += gravity * delta# + Global.world_wind * delta 
	pass
