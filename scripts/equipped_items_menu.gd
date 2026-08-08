extends Control


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
		if !item_data.is_empty():
			text = item_data[Items.INDEX_NAME]
		b.text = text
		pass
		
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

func get_selection() -> int: #important that gives -1 if no selection
	var offset = PlayerInformation.inventory.size() - PlayerInformation.equipment_slot_count
	var sel_index = -1
	for i in range(0,buttons.size()):
		if buttons[i].is_hovered():
			sel_index = i + offset
	return sel_index

@onready var buttons = [ #need to be in order
	$HBoxContainer/backpack/backpack_slot,
	$HBoxContainer/quiver/quiver_slot,
]
