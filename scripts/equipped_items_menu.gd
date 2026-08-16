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
@onready var quiver_storage_slots = $HBoxContainer/quiver/quiver_storage_slots
func update_slots():
	for old in backpack_storage_slots.get_children(false):
		old.queue_free()
	for olda in quiver_storage_slots.get_children(false):
		olda.queue_free()
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
	var quiver_item: Array = PlayerInformation.inventory[backpack_index+1]
	if !quiver_item.is_empty() and !backpack_index+1 == pretend_empty_index:
		var quiver_attributes:Dictionary = quiver_item[1]
		if quiver_attributes.has("inventory"):
			var has_new_b = false
			for i in range(0, quiver_attributes["inventory"].size()):
				var in_item = quiver_attributes["inventory"][i]
				var b = Button.new()
				b.text = "add"
				if !in_item.is_empty():
					b.text = in_item[0]
				elif !has_new_b:
					b.text = "add new"
					has_new_b = true
				else:
					b.visible = false
				quiver_storage_slots.add_child(b)

func get_selection(sel_filter:int = -1) -> int: #important that gives -1 if no selection
	var offset = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	#var sel_index = -1
	for i in range(0,buttons.size()):
		if buttons[i].is_hovered():
			if equip_required_type[i] == sel_filter or sel_filter == -1:
				return i + offset
			else:
				return -1
	return -1

func get_item_storage_selection(sel_filter:int = -1) -> Vector2i: #x == inventory_index of storage_item, y == item_index of said storage
	var sel = Vector2i(-1,0)
	var inv_indx = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	var slot_i = 0
	for b in backpack_storage_slots.get_children(false):
		if b.is_hovered():
			return Vector2i(inv_indx,slot_i)
		slot_i += 1
	slot_i = 0
	inv_indx += 1
	if sel_filter == Items.equipment_id.ARROW or sel_filter == -1:
		for q in quiver_storage_slots.get_children(false):
			if q.is_hovered():
				return Vector2i(inv_indx,slot_i)
			slot_i += 1
	return sel

@onready var buttons = [ #need to be in order
	$HBoxContainer/backpack/backpack_slot,
	$HBoxContainer/quiver/quiver_slot,
]

const equip_required_type = [
	Items.equipment_id.BACKPACK,
	Items.equipment_id.QUIVER,
]
