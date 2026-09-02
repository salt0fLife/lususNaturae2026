extends Control
var pretend_empty_index = -1

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

func _update_inventory_graphics_old():
	$RadialMenu.highlighted = PlayerInformation.held_item_index
	
	for i in $items_graphics.get_children(false):
		i.queue_free()
	
	var nos = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	$RadialMenu.number_of_slots = nos
	var center = size*0.5
	var cell_size = (PI*2.0 * ((1.0/nos)))
	
	for i in range(0,nos):
		var held_item_data = PlayerInformation.inventory[i]
		var item_style = Items.style.NORMAL
		var item_name = "empty"
		if !held_item_data.is_empty() and i != pretend_empty_index:
			var item_data = Items.list[held_item_data[0]]
			item_name = item_data[Items.INDEX_NAME]
			item_style = item_data[Items.INDEX_STYLE]
		var t = Label.new()
		t.text = str(item_name) + " (" + str(i+1)+")"
		t.set("theme_override_colors/font_color", Items.style_colors[item_style])
		#var t = item_card.new_card(held_item_data)
		
		var centered_angle = PI*2.0 * -((1.0/nos)*i)-cell_size*0.5# + (PI*2.0 * ((1.0/number_of_slots)*1)*0.5)
		var middle_ray = Vector2(1.0,1.0)
		middle_ray.x *= cos(centered_angle)
		middle_ray.y *= sin(centered_angle)
		var middle_rad = (size.y*0.05 + size.y*0.25)*0.5
		
		t.position = middle_ray*middle_rad+center
		$items_graphics.add_child(t)
	pass

func _update_inventory_graphics():
	$RadialMenu.highlighted = PlayerInformation.held_item_index
	
	for old in $items_graphics.get_children(false):
		old.queue_free()
	item_cards = {}
	
	var nos = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	$RadialMenu.number_of_slots = nos
	var center = size*0.5
	var cell_size = (PI*2.0 * ((1.0/nos)))
	
	for i in range(0,nos):
		var held_item_data = PlayerInformation.inventory[i]
		var item_style = Items.style.NORMAL
		var item_name = "empty"
		if !held_item_data.is_empty() and i != pretend_empty_index:
			var item_data = Items.list[held_item_data[0]]
			item_name = item_data[Items.INDEX_NAME]
			item_style = item_data[Items.INDEX_STYLE]
			
			var t = item_card.new_card(held_item_data)
			t.scale = Vector2(0.6,0.6)
			var centered_angle = PI*2.0 * -((1.0/nos)*i)-cell_size*0.5# + (PI*2.0 * ((1.0/number_of_slots)*1)*0.5)
			var middle_ray = Vector2(1.0,1.0)
			middle_ray.x *= cos(centered_angle)
			middle_ray.y *= sin(centered_angle)
			var middle_rad = (size.y*0.05 + size.y*0.25)*0.5
			
			t.position = middle_ray*middle_rad+center
			t.rotation = centered_angle - PI*0.5 + PI
			$items_graphics.add_child(t)
			item_cards[i] = t
	last_frame_sel = -1 #so it rechecks
	pass

func get_slot_position(index : int) -> Vector2:
	var nos = $RadialMenu.number_of_slots
	var center = size*0.5
	var cell_size = (PI*2.0 * ((1.0/nos)))
	var i = index
	var centered_angle = PI*2.0 * -((1.0/nos)*i)-cell_size*0.5# + (PI*2.0 * ((1.0/number_of_slots)*1)*0.5)
	var middle_ray = Vector2(1.0,1.0)
	middle_ray.x *= cos(centered_angle)
	middle_ray.y *= sin(centered_angle)
	var middle_rad = (size.y*0.05 + size.y*0.25)*0.5
	return middle_ray*middle_rad+center

func can_click():
	return $RadialMenu.can_click

func _on_slot_hover_start(index : int) -> void:
	var c = get_item_card(index)
	if c!= null:
		c.set_display_mode(true)

func _on_slot_hover_stop(index : int) -> void:
	var c = get_item_card(index)
	if c!= null:
		c.set_display_mode(false)

func get_item_card(index : int):
	if item_cards.has(index):
		return item_cards[index]
	else:
		return null

var item_cards:Dictionary = {
}

var last_frame_sel = -1
func _process(delta):
	if !visible:
		return
	var sel = $RadialMenu.selected
	if !$RadialMenu.can_click:
		sel = -1
	if sel != last_frame_sel:
		_on_slot_hover_stop(last_frame_sel)
		_on_slot_hover_start(sel)
		last_frame_sel = sel


