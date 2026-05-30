extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInformation.connect("update_inventory", _update_inventory_graphics)
	_update_inventory_graphics()
	connect("resized",_update_inventory_graphics)


func _on_slot_selected(index):
	print("slot selected")
	print(index)


func get_menu_selection():
	var val = $RadialMenu.selected
	if val == -1:
		return PlayerInformation.held_item_index
	else:
		return val

func _update_inventory_graphics():
	for i in $items_graphics.get_children(false):
		i.queue_free()
	
	
	var nos = PlayerInformation.inventory.size()
	$RadialMenu.number_of_slots = nos
	var center = size*0.5
	var cell_size = (PI*2.0 * ((1.0/nos)))
	
	for i in range(0,nos):
		var t = Label.new()
		t.text = str(PlayerInformation.inventory[i]) + " (" + str(i+1)+")"
		
		var centered_angle = PI*2.0 * -((1.0/nos)*i)-cell_size*0.5# + (PI*2.0 * ((1.0/number_of_slots)*1)*0.5)
		var middle_ray = Vector2(1.0,1.0)
		middle_ray.x *= cos(centered_angle)
		middle_ray.y *= sin(centered_angle)
		
		
		var middle_rad = (size.y*0.05 + size.y*0.25)*0.5
		
		t.position = middle_ray*middle_rad+center
		$items_graphics.add_child(t)
	pass
