extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_graphics()
	connect("resized",_update_graphics)

const displayed_text = [
	"rest",
	"sit"
	
]

func get_menu_selection():
	return $radial_menu.selected

func _update_graphics():
	for i in $labels.get_children(false):
		i.queue_free()
	
	var nos = 2
	var center = size*0.5
	var cell_size = (PI*2.0 * ((1.0/nos)))
	
	for i in range(0,nos):
		var t = Label.new()
		t.text = displayed_text[i]
		
		var centered_angle = PI*2.0 * -((1.0/nos)*i)-cell_size*0.5# + (PI*2.0 * ((1.0/number_of_slots)*1)*0.5)
		var middle_ray = Vector2(1.0,1.0)
		middle_ray.x *= cos(centered_angle)
		middle_ray.y *= sin(centered_angle)
		
		
		var middle_rad = (size.y*0.05 + size.y*0.25)*0.5
		
		t.position = middle_ray*middle_rad+center
		$labels.add_child(t)
	pass
