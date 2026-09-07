class_name damage_indicator extends Label3D
var velocity:Vector3 = Vector3.ZERO

static func new_indicator(amount : int, type : int) -> damage_indicator:
	var di:damage_indicator = load("res://assets/effects/damage_indicator.tscn").instantiate()
	di.text = str(amount)
	di.set_type(type)
	var min = -0.01
	var max = 0.01
	var x:float = randf_range(min,max)
	var y:float = randf_range(min,max)
	var z:float = randf_range(min,max)
	di.velocity = Vector3(x,y,z)
	return di


func set_type(type:int)-> void:
	var c = item_card.colors[type] #just a temp thing
	modulate = c

var lifetime = 1.0
func _process(delta):
	lifetime -= delta
	if lifetime < delta:
		queue_free()
	else:
		position += velocity
		velocity -= velocity*delta
