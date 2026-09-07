@tool
extends Node3D
@export var drawing:bool = false
var align_rotation:bool = false
@export var visualize_multimesh_scattering : bool = false
@export var distance_between_multimeshes : float = 20.0 
@export var brush_size:float = 5.0
@export var brush_count:int = 1
var is_vis = false
@export var grass_mesh :Mesh
@export var update_all_meshes : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	multimesh_handler.connect("child_entered_tree",_on_multimesh_added)
	pass # Replace with function body.

func _on_multimesh_added(mm) -> void:
	if visualize_multimesh_scattering:
		var m = BoxMesh.new()
		var mi = MeshInstance3D.new()
		mi.mesh = m
		mm.add_child(mi)
	pass

@onready var multimesh_handler = $multimesh_handler
func _process(delta):
	if !Engine.is_editor_hint():
		return
	if update_all_meshes:
		update_meshes()
		update_all_meshes = false
	cursor.visible = drawing
	if visualize_multimesh_scattering:
		if !is_vis:
			visualize_mulimesh()
			is_vis = true
	elif is_vis:
		is_vis = false
		stop_v()
	if drawing:
		#if !multimesh_handler.get_child_count(false) > 0:
			#printerr("no valid multimesh targets")
			#drawing = false
			#return
		drawing_stuff()
	pass

func stop_v() -> void:
	for i in multimesh_handler.get_children(false):
		for x in i.get_children(false):
			x.queue_free()

func update_meshes() -> void:
	for i in multimesh_handler.get_children(false):
		i.multimesh.mesh = grass_mesh

func visualize_mulimesh() -> void:
	var m = BoxMesh.new()
	for i in multimesh_handler.get_children(false):
		var mi = MeshInstance3D.new()
		mi.mesh = m
		i.add_child(mi)
	pass

var camera = null
@onready var ray_cast = $RayCast3D
func set_mouse_3d_transform() -> void:
	#var pos = Vector3.ZERO
	if camera == null:
		#camera = get_viewport().get_camera_3d()
		camera = EditorInterface.get_editor_viewport_3d().get_camera_3d()
		cursor.position = Vector3.ZERO
		cursor.rotation = Vector3.ZERO
		#return Vector3.ZERO
		return
	ray_cast.transform = camera.transform
	ray_cast.force_raycast_update()
	$cursor/cursor_graphics.scale = Vector3(brush_size,brush_size,brush_size)
	if ray_cast.is_colliding():
		#pos = ray_cast.get_collision_point()
		cursor.position = ray_cast.get_collision_point()
		var rot2 = dir_to_rot(ray_cast.get_collision_normal())
		cursor.rotation = Vector3(rot2.x,rot2.y,0.0)
	#return pos

@onready var cursor = $cursor
func drawing_stuff() -> void:
	#cursor.transform = get_mouse_3d_transform()
	set_mouse_3d_transform()
	
	if !align_rotation: cursor.rotation = Vector3.ZERO
	if Input.is_action_just_pressed("ui_accept"):
		_on_brush_clicked(cursor.transform)
	pass

var undo:bool = false

func _on_brush_clicked(tran : Transform3D):
	var pos = tran.origin
	for x in range(0,brush_count):
		var offset = Vector2(randf_range(-1.0,1.0),randf_range(-1.0,1.0)).normalized()
		offset *= randf_range(0.0,1.0) * brush_size * 0.5
		var ray = PhysicsRayQueryParameters3D.create(pos+Vector3(offset.x,10.0,offset.y),pos+Vector3(offset.x,-10.0,offset.y))
		var result = get_world_3d().direct_space_state.intersect_ray(ray)
		var t = tran
		t.origin = result.position
		place_mesh(t)

func place_mesh(tran:Transform3D) -> void:
	var pos = tran.origin
	
	var multimesh = null
	var closest_dis = distance_between_multimeshes
	for m in multimesh_handler.get_children(false):
		var dis = (m.position - pos).length()
		if dis < closest_dis:
			closest_dis = dis
			multimesh = m
	if multimesh == null: #to far apart
		multimesh = MultiMeshInstance3D.new()
		multimesh_handler.add_child(multimesh)
		multimesh.set_owner(get_parent())
		multimesh.position = pos
		multimesh.set("visibility_range_end",50.0)
	
	#multimesh is now just the closest mesh to the point clicked
	tran *= multimesh.transform.inverse() #so its local to multimesh
	
	var mm = multimesh.multimesh
	if mm == null:
		mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = grass_mesh
		multimesh.multimesh = mm
	if mm.mesh == null:
		mm.mesh = grass_mesh
	var s_index : int = mm.instance_count * 8-1 #what index you start at
	#await edit.process_frame
	if s_index < 0:
		s_index = 0
	var old_buffer = mm.buffer
	mm.instance_count += 1
	mm.set_instance_transform(mm.instance_count-1,tran)
	for i in range(0,old_buffer.size()):
		mm.buffer[i] = old_buffer[i]
	#for i in range(0,8): ##it could have been beutiful :(
		#mm.buffer[s_index+i] = tran[i]
	#mm.buffer[s_index+0] = tran.origin.x
	#mm.buffer[s_index+1] = tran.origin.y
	#mm.buffer[s_index+2] = tran.origin.z
	#
	#mm.buffer[s_index+3] = tran.basis.x.x
	#mm.buffer[s_index+4] = tran.basis.x.y
	#mm.buffer[s_index+5] = tran.basis.x.z
	#
	#mm.buffer[s_index+6] = tran.basis.y.x
	#mm.buffer[s_index+7] = tran.basis.y.y
	#mm.buffer[s_index+8] = tran.basis.y.z
	#
	#mm.buffer[s_index+9] = tran.basis.z.x
	#mm.buffer[s_index+10] = tran.basis.z.y
	#mm.buffer[s_index+11] = tran.basis.z.z
	
	
	
	
	

func dir_to_rot(dir :Vector3) -> Vector2:
	var rot = Vector2.ZERO
	rot.y = atan2(dir.x, dir.z)
	rot.x = atan2(sqrt(dir.z*dir.z+dir.x*dir.x),dir.y)
	return rot
