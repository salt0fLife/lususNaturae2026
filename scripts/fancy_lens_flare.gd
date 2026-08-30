extends Node3D

@export_category("fancy_lens_flare")

@export var attunation_mult: float = 1.0
@onready var control = $control
var camera = null
var screen_size: Vector2 = Vector2.ZERO
var world_attunation:float = 1.0
@export var use_position_as_offset = false
func _process(delta):
	if camera == null:
		camera = get_viewport().get_camera_3d()
		return #so even if still null nothing breaks it just keeps trying
	var dif = (camera.global_position-global_position)
	if use_position_as_offset:
		dif = -global_position
	var relative_ray = dif.normalized() * camera.global_basis
	#relative_ray.rotated(Vector3.UP,PI*0.5)
	var flat_transform = Vector2(relative_ray.x,-relative_ray.y)
	var attunation = clamp(relative_ray.z,0.0,1.0) * world_attunation * attunation_mult
	
	if check_for_occlusion(camera.global_position):
		world_attunation = lerp(world_attunation,0.0,delta*64.0)
	else:
		world_attunation = lerp(world_attunation,1.0,delta*64.0)
	var i = 0
	var offset = 0.3
	if relative_ray.z < 0.0:
		flat_transform.x = screen_size.x * 2.0
	for c in control.get_children(false):
		c.position = flat_transform * screen_size.x * offset +screen_size*0.5
		var rel_dir = (c.position - screen_size*0.5)
		c.rotation = atan2(rel_dir.y,rel_dir.x) + PI*0.5
		offset += 0.1
		#c.color.a = attunation
		var s = (1.0-attunation)*0.5 + 1.0
		c.scale = Vector2(s,s)
		c.get_child(0).modulate = colors[i]
		c.get_child(0).modulate.a = attunation
		i+=1
	#var camera_dir = Vector3.UP.rotated(Vector3(1.0,0.0,0.0),PlayerInformation.rotation.x)
	#camera_dir = camera_dir.rotated(Vector3(0.0,1.0,0.0),PlayerInformation.rotation.y)
	#var dif = PlayerInformation.position + Vector3(0.0,1.25,0.0)
	#
	#var i:int = 0
	#for c in texture_handler.get_children(false):
		#c.color = colors[i]
		#i += 1

@onready var sightline = $RayCast3D
func check_for_occlusion(pos : Vector3) -> bool:
	#sightline.global_rotation = Vector3.ZERO
	sightline.rotation = Vector3.ZERO
	sightline.position = pos
	var dif = (global_position - pos)
	if use_position_as_offset:
		dif = global_position
	sightline.target_position = dif
	return sightline.is_colliding()

func _ready():
	control.connect("resized",_on_screen_resized)
	_on_screen_resized()

func _on_screen_resized():
	#dim = get_viewport_rect().size
	screen_size = control.size

var points:Array[Vector2i] = [Vector2i.ZERO,Vector2i(100,100)]
@export var colors:Array[Color] = [Color.AQUA,Color.AQUAMARINE,Color.FUCHSIA,Color.ORCHID,Color.LIGHT_GREEN,Color.AQUAMARINE,Color.FUCHSIA,Color.MEDIUM_ORCHID]

#func _draw():
	#for i in range(0,points.size()):
		#var p = points[i]
		#var c = colors[i]
		#pass
	#draw_circle(center, outer_rad, col_1)
	#draw_arc(center, inner_rad, 0, TAU, 128, col_2, line_width, true)
	#draw_line(center+Vector2(inner_rad,0.0), center+Vector2(outer_rad,0.0),col_2, line_width)

