@tool
extends Control
class_name RadialMenu
@export var col_1 := Color.BLACK
@export var col_2 := Color.BLACK
@export var col_3 := Color.BLACK
@export var col_highlighted := Color.BLACK
@export var col_can_click := Color.BLACK

@export var line_width := 4

@export var number_of_slots := 2
@export var display_size := 1.0


signal slot_selected(index : int)

func _ready():
	#get_viewport().connect("size_changed",_on_screen_resized)
	connect("resized",_on_screen_resized)
	_on_screen_resized()


var dim : Vector2 = Vector2.ZERO
var center : Vector2 = Vector2.ZERO
var outer_rad : float = 0.0
var inner_rad : float = 0.0

var selected = -2
var can_click = false
@export var highlighted = -1

func _draw():
	draw_circle(center, outer_rad, col_1)
	draw_arc(center, inner_rad, 0, TAU, 128, col_2, line_width, true)
	draw_line(center+Vector2(inner_rad,0.0), center+Vector2(outer_rad,0.0),col_2, line_width)
	
	if selected == -1:
		draw_circle(center, inner_rad-line_width*0.5, col_3)
	
	
	for i in range(0,number_of_slots):
		var angle = PI*2.0 * ((1.0/number_of_slots)*i)
		var cell_size = (PI*2.0 * ((1.0/number_of_slots)))
		
		var ray = Vector2(1.0,1.0)
		ray.x *= cos(angle)
		ray.y *= sin(angle)
		
		var centered_angle = PI*2.0 * ((1.0/number_of_slots)*i)+cell_size*0.5# + (PI*2.0 * ((1.0/number_of_slots)*1)*0.5)
		var middle_ray = Vector2(1.0,1.0)
		middle_ray.x *= cos(centered_angle)
		middle_ray.y *= sin(centered_angle)
		
		var middle_rad = (inner_rad + outer_rad)*0.5
		
		if i == selected:
			var points_per_arc = 8
			var points_inner = PackedVector2Array()
			var points_outer = PackedVector2Array()
			
			for x in range(0,points_per_arc+1):
				var a_c = angle+((x*cell_size)/points_per_arc)
				points_inner.append((inner_rad+line_width*0.5) * Vector2.from_angle(TAU-a_c)+center)
				points_outer.append(outer_rad*1.05 * Vector2.from_angle(TAU-a_c)+center)
			points_outer.reverse()
			
			var col = col_3
			if can_click:
				col = col_can_click
			draw_polygon(points_inner + points_outer, PackedColorArray([col]))
		elif i == highlighted:
			var points_per_arc = 8
			var points_inner = PackedVector2Array()
			var points_outer = PackedVector2Array()
			
			for x in range(0,points_per_arc+1):
				var a_c = angle+((x*cell_size)/points_per_arc)
				points_inner.append((inner_rad+line_width*0.5) * Vector2.from_angle(TAU-a_c)+center)
				points_outer.append(outer_rad * Vector2.from_angle(TAU-a_c)+center)
			points_outer.reverse()
			
			draw_polygon(points_inner + points_outer, PackedColorArray([col_highlighted]))
		
		draw_line(center+(ray*inner_rad), center+(ray*outer_rad),col_2, line_width, true)
		
		
		#draw_texture(tex,middle_ray*middle_rad+center-(tex_info[1]*0.5))

var freeze_selected = false
func _process(_delta):
	if freeze_selected:
		queue_redraw()
		return
	var mouse_pos = get_local_mouse_position() - center
	var mouse_rad = mouse_pos.length()
	
	if mouse_rad < inner_rad:
		selected = -1
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selected = ceil((mouse_rads / TAU) * number_of_slots - 1)
		can_click = mouse_rad < outer_rad
	queue_redraw()

func _on_screen_resized():
	#dim = get_viewport_rect().size
	dim = size
	center = dim*0.5
	outer_rad = dim.y*0.25
	inner_rad = dim.y*0.05
