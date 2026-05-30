@tool
extends Node3D

@export var resolution : int = 5
@export var length : float = 1.0
@export var width : float = 1.0
var points_list: PackedVector3Array = []
@export var material: StandardMaterial3D
@export var senses_only: bool

var active_resolution: int = 5
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	test_draw_lines()
	smoke_physics(delta)
	if active_resolution != resolution:
		active_resolution = resolution
		update_points_list()


@onready var graphics_handler = $graphics_handler
func test_draw():
	for old in graphics_handler.get_children(false):
		old.queue_free()
	for pos in points_list:
		var test_display = MeshInstance3D.new()
		test_display.mesh = SphereMesh.new()
		test_display.position = pos
		graphics_handler.add_child(test_display)

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

@export_category("smoke physics")
@export var gravity : Vector3 = Vector3.ZERO
@export var life_time : float = 5.0
var life_timer = 0.0

@export var sin_wave_strength : float = 0.0
@export var sin_wave_frequency : float = 1.0
var sine_wave_timer = 0.0

func smoke_physics(delta) -> void:
	for i in points_list.size():
		var pos = points_list[i]
		var sine_force = Vector3.ZERO
		sine_force.x = sin(pos.x*sin_wave_frequency + sine_wave_timer)
		sine_force.y = sin(pos.y*sin_wave_frequency + sine_wave_timer)
		sine_force.z = sin(pos.z*sin_wave_frequency + sine_wave_timer)
		points_list[i] = (pos + gravity*delta + sine_force*delta*sin_wave_strength)
	life_timer += delta
	if life_timer > life_time:
		points_list.remove_at(0)
		life_timer = 0.0
		points_list.append(global_position)
	sine_wave_timer += delta*sin_wave_frequency
	if sine_wave_timer > PI*64.0:
		sine_wave_timer -= PI*64.0
	
	
	pass

func update_points_list() -> void:
	points_list.clear()
	for i in range(0,resolution):
		var height = Vector3(0.0, (float(i) / resolution) * length, 0.0)
		points_list.append((global_position + height))
