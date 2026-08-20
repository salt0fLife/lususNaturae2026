@tool
class_name weapon_trail extends Node3D
@export_category("weapon_trail")
@export var weapon_tip_offset:float = 1.0
@export var material : Material
@export var max_points : int = 4
@export var follow_speed : float = 1.0
@export var taper_curve : Curve
@export var max_follow_distance : float = 2.0
@export var step_distance : float = 0.2 #distance between steps

var points_list_top: PackedVector3Array = []
var points_list_bot: PackedVector3Array = []
var taper: PackedFloat64Array = []

var wt_reference = null
var mesh_instance = null
func _ready():
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	update_weapon_tip_reference()
	pass

func update_weapon_tip_reference() -> void:
	if wt_reference == null:
		var wtr = Node3D.new()
		add_child(wtr)
		wtr.position.y = weapon_tip_offset
		wt_reference = wtr
	else:
		wt_reference.position.y = weapon_tip_offset

func _process(delta):
	#update_weapon_tip_reference()
	if points_list_top.is_empty():
		points_list_top.append(wt_reference.global_position)
		points_list_bot.append(global_position)
	var count = points_list_top.size()
	var dif_top = points_list_top[count-1] - wt_reference.global_position
	var dif_bot = points_list_bot[count-1] - global_position
	
	if dif_top.length() > step_distance or dif_bot.length() > step_distance:
		points_list_top.append(wt_reference.global_position)
		points_list_bot.append(global_position)
		count += 1
	
	
	taper.resize(count)
	
	var remove_number : int = 0
	
	for i in range(0,count):
		var rel_dif_top = (points_list_top[i] - wt_reference.global_position)
		var rel_dif_bot = (points_list_bot[i] - global_position)
		
		if rel_dif_bot.length() < 0.05 and rel_dif_top.length() < 0.05:
			remove_number += 1
		else:
			if rel_dif_top.length() > max_follow_distance:
				rel_dif_top = rel_dif_top.normalized() * max_follow_distance
				points_list_top[i] = wt_reference.global_position + rel_dif_top
			
			if rel_dif_bot.length() > max_follow_distance:
				rel_dif_bot = rel_dif_bot.normalized() * max_follow_distance
				points_list_bot[i] = global_position + rel_dif_bot
			
			taper[i] = rel_dif_top.length()/max_follow_distance
			
			if i != count-1:
				points_list_top[i] -= (points_list_top[i]-points_list_top[i+1]).normalized() * delta*follow_speed
				points_list_bot[i] -= (points_list_bot[i]-points_list_bot[i+1]).normalized() * delta*follow_speed
			else:
				points_list_top[i] -= (points_list_top[i]-wt_reference.global_position).normalized() * delta*follow_speed
				points_list_bot[i] -= (points_list_bot[i]-global_position).normalized() * delta*follow_speed
	if count == 1:
		remove_number = 1
	
	for x in range(0, remove_number):
		if x != 0:
			var i = count-1
			points_list_top.remove_at(i)
			points_list_bot.remove_at(i)
			taper.remove_at(i)
			count -= 1
	
	if count > max_points:
		for e in range(0,count-max_points):
			count -= 1
			points_list_top.remove_at(0)
			points_list_bot.remove_at(0)
			taper.remove_at(0)
	#draw_debug()
	draw_meshing_planes()
	pass

func draw_debug() -> void:
	for old in get_children(false):
		old.queue_free()
	for i in range(0,points_list_top.size()):
		var l = Label3D.new()
		l.text = str(taper[i])
		add_child(l)
		l.global_position = points_list_top[i]
		var l_2 = Label3D.new()
		l_2.text = "O"
		add_child(l_2)
		l_2.global_position = points_list_bot[i]
		pass
	
	pass

func draw_meshing_planes() -> void:
	mesh_instance.mesh = null
	mesh_instance.global_position = Vector3.ZERO
	mesh_instance.global_rotation = Vector3.ZERO
	if points_list_top.is_empty():
		return
	mesh_instance.global_position = Vector3.ZERO
	var arr_mesh = ArrayMesh.new()
	var vertices:PackedVector3Array = []
	var indices = PackedInt32Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	
	#var upper_offset := Vector3.UP
	
	var count = points_list_top.size()
	
	for i in range(0,count):
		var p_1_top = points_list_top[i]
		var p_2_top = Vector3.ZERO
		var p_1_bot = points_list_bot[i]
		p_1_bot = lerp(p_1_bot,p_1_top,taper[i])
		var p_2_bot = Vector3.ZERO
		if count-2 < i:
			p_2_top = wt_reference.global_position
			p_2_bot = global_position
		else:
			p_2_top = points_list_top[i+1]
			p_2_bot = lerp(points_list_bot[i+1],p_2_top,taper[i])
		#var p_2 = global_position
		#if i != 0:
			#p_2 = points_list[i-1]
		var vert_index = i*2+2 #2 verts per point 2 extra at start
		if i == 0:
			vertices.append(p_1_top)
			vertices.append(p_1_bot)
			#normals.append(upper_offset)
			#normals.append(-upper_offset)
			normals.append(Vector3.UP)
			normals.append(Vector3.UP)
			uvs.append(Vector2(0.0,0.0))
			uvs.append(Vector2(0.0,0.0))
		vertices.append(p_2_top)
		vertices.append(p_2_bot)
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

