@tool
extends Node3D
class_name ribbon_trail_3D

@export_category("point spawning")
var points_list: PackedVector3Array = []
var points_lifetimes: PackedFloat32Array = []
@export var material: Material
var senses_only: bool = true
@export var width: float = 0.25
@export var max_points: int = 25
@export var distance_between_points:float = 0.25

@export var natrual_point_decay: float = 5.0 #how many seconds before a point is natrually deleted

@export_category("points behavior")
@export var gravity: Vector3 = Vector3.ZERO

var mesh_instance = null
func draw_meshing_planes():
	mesh_instance.mesh = null
	if points_list.is_empty():
		return
	mesh_instance.global_position = Vector3.ZERO
	var arr_mesh = ArrayMesh.new()
	var vertices:PackedVector3Array = []
	var indices = PackedInt32Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	
	#var upper_offset := Vector3.UP
	
	
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
		var dif = p_2 - p_1
		var upper_offset = Vector3.UP
		
		var y_rot = atan2(dif.z,dif.x)
		var flat_dis = Vector2(dif.x,dif.z).length()
		var x_rot = atan2(dif.y,flat_dis)
		upper_offset = upper_offset.rotated(Vector3(1.0,0.0,0.0),x_rot)
		upper_offset = upper_offset.rotated(Vector3(0.0,1.0,0.0),y_rot)
		var vert_index = i*2+2 #2 verts per point 2 extra at start
		if i == 0:
			vertices.append(p_1+upper_offset*0.5)
			vertices.append(p_1-upper_offset*0.5)
			#normals.append(upper_offset)
			#normals.append(-upper_offset)
			normals.append(Vector3.UP)
			normals.append(Vector3.UP)
			uvs.append(Vector2(0.0,0.0))
			uvs.append(Vector2(0.0,0.0))
		vertices.append(p_2+upper_offset*0.5)
		vertices.append(p_2-upper_offset*0.5)
		#uvs
		#uvs.append(Vector2(0.0,0.0))
		#uvs.append(Vector2(0.0,0.0))
		uvs.append(Vector2(0.0,0.0))
		uvs.append(Vector2(0.0,0.0))
		#normals
		#normals.append(upper_offset)
		#normals.append(-upper_offset)
		#normals.append(upper_offset)
		#normals.append(-upper_offset)
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		#triangle 1
		indices.append(vert_index-2)
		indices.append(vert_index+1-2)
		indices.append(vert_index+2-2)
		#triangle 2
		indices.append(vert_index+2-2)
		indices.append(vert_index+1-2)
		indices.append(vert_index+3-2)
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

func _ready():
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	last_decaying_point_pos = global_position

func draw_meshing():
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		add_child(mesh_instance)
	mesh_instance.mesh = null
	if points_list.is_empty():
		return
	mesh_instance.global_position = Vector3.ZERO
	var arr_mesh = ArrayMesh.new()
	var vertices:PackedVector3Array = []
	var indices = PackedInt32Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	
	#var upper_offset := Vector3.UP
	
	var uv_offset = 0.0
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
		var dif = p_2 - p_1
		var upper_offset = Vector3(0.0,width,0.0)
		var side_offset = Vector3(0.0,0.0,width)
		
		var y_rot = atan2(dif.z,dif.x)
		var flat_dis = Vector2(dif.x,dif.z).length()
		var x_rot = atan2(dif.y,flat_dis)
		upper_offset = upper_offset.rotated(Vector3(1.0,0.0,0.0),x_rot)
		upper_offset = upper_offset.rotated(Vector3(0.0,1.0,0.0),y_rot)
		side_offset = side_offset.rotated(Vector3(0.0,1.0,0.0),x_rot)
		side_offset = side_offset.rotated(Vector3(0.0,1.0,0.0),-y_rot)
		
		var vert_index = i*4 #4 verts per point 4 extra at start
		#uv_offset+= Vector2(dif.length(),dif.length())
		uv_offset += dif.length()
		if i == 0:
			vertices.append(p_1+upper_offset*0.5)
			vertices.append(p_1-upper_offset*0.5)
			vertices.append(p_1+side_offset*0.5)
			vertices.append(p_1-side_offset*0.5)
			normals.append(Vector3.UP)
			normals.append(Vector3.UP)
			normals.append(Vector3.UP)
			normals.append(Vector3.UP)
			uvs.append(Vector2(uv_offset,1.0))
			uvs.append(Vector2(uv_offset,0.0))
			uvs.append(Vector2(uv_offset,1.0))
			uvs.append(Vector2(uv_offset,0.0))
			uv_offset += dif.length()
		vertices.append(p_2+upper_offset*0.5)
		vertices.append(p_2-upper_offset*0.5)
		vertices.append(p_2+side_offset*0.5)
		vertices.append(p_2-side_offset*0.5)
		#uvs
		uvs.append(Vector2(uv_offset,1.0))
		uvs.append(Vector2(uv_offset,0.0))
		uvs.append(Vector2(uv_offset,1.0))
		uvs.append(Vector2(uv_offset,0.0))
		#normals
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		#triangle 1
		indices.append(vert_index)
		indices.append(vert_index+1)
		indices.append(vert_index+4)
		#triangle 2
		indices.append(vert_index+4)
		indices.append(vert_index+1)
		indices.append(vert_index+5)
		#triangle 3
		indices.append(vert_index+2)
		indices.append(vert_index+3)
		indices.append(vert_index+6)
		#triangle 4
		indices.append(vert_index+6)
		indices.append(vert_index+3)
		indices.append(vert_index+7)
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
	
	draw_meshing()
	#test_draw()
	pass

func update_points(delta):
	for i in range(0,points_list.size()):
		points_list[i] += gravity * delta# + Global.world_wind * delta 
	pass
