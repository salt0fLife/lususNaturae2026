extends Control

var pretend_empty_index = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInformation.connect("update_inventory", _update_inventory_graphics)
	_update_inventory_graphics()

func _update_inventory_graphics():
	var offset = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	for i in range(0,buttons.size()):
		var b = buttons[i]
		var item_data = PlayerInformation.get_item_data(i+offset)
		var text = "empty"
		if !item_data.is_empty() and !i+offset == pretend_empty_index:
			text = item_data[Items.INDEX_NAME]
		b.text = text
	update_slots()
	#var backpack_data = PlayerInformation.get_item_data(0)
	#var quiver_data = PlayerInformation.get_item_data(1)
	#if backpack_data.is_empty():
		#$HBoxContainer/backpack/backpack_slot.text = "empty"
	#else:
		#$HBoxContainer/backpack/backpack_slot.text = str(backpack_data[0][Items.INDEX_NAME])
	#if quiver_data.is_empty():
		#$HBoxContainer/quiver/quiver_slot.text = "empty"
	#else:
		#$HBoxContainer/quiver/quiver_slot.text = str(backpack_data[1][Items.INDEX_NAME])
	pass

@onready var backpack_storage_slots = $HBoxContainer/backpack/backpack_storage_slots
func update_slots():
	for old in backpack_storage_slots.get_children(false):
		old.queue_free()
	var backpack_index:int = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	var backpack_item: Array = PlayerInformation.inventory[backpack_index]
	if !backpack_item.is_empty() and !backpack_index == pretend_empty_index:
		var backpack_attributes:Dictionary = backpack_item[1]
		if backpack_attributes.has("inventory"):
			for i in range(0, backpack_attributes["inventory"].size()):
				var in_item = backpack_attributes["inventory"][i]
				var text = "empty"
				if !in_item.is_empty():
					text = in_item[0]
				var b = Button.new()
				b.text = text
				backpack_storage_slots.add_child(b)
				pass
			pass
		pass

func get_selection() -> int: #important that gives -1 if no selection
	var offset = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	var sel_index = -1
	for i in range(0,buttons.size()):
		if buttons[i].is_hovered():
			sel_index = i + offset
	return sel_index

func get_item_storage_selection() -> Vector2i: #x == inventory_index of storage_item, y == item_index of said storage
	var sel = Vector2i(-1,0)
	var inv_indx = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	var slot_i = 0
	for b in backpack_storage_slots.get_children(false):
		if b.is_hovered():
			return Vector2i(inv_indx,slot_i)
		slot_i += 1
	return sel

@onready var buttons = [ #need to be in order
	$HBoxContainer/backpack/backpack_slot,
	$HBoxContainer/quiver/quiver_slot,
]
