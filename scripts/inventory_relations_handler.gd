extends Node


@onready var inventory_menu = $inventory_menu
@onready var item_menu = $item_menu
@onready var equipped_items_menu = $equipped_items_menu

var inventory_open = false
var grabbed_item_index = -1
var grabbed_item = false
var grabbed_storage_item = false
var grabbed_storage_item_index = 0 #grabbed_item_index would be backpack, this would be slot in backpack
var click_downtime:int = 0

func _input(event):
	if Input.is_action_just_pressed("inventory"):
		set_inventory_open(true)
	if Input.is_action_just_released("inventory"):
		set_inventory_open(false)
	if Input.is_action_just_pressed("inventory_slot_1"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(0, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(0)
	if Input.is_action_just_pressed("inventory_slot_2"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(1, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(1)
	if Input.is_action_just_pressed("inventory_slot_3"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(2, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(2)
	if Input.is_action_just_pressed("inventory_slot_4"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(3, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(3)
	if Input.is_action_just_pressed("inventory_slot_5"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(4, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(4)
	if Input.is_action_just_pressed("use_item") and inventory_open and click_downtime == 0:
		click_downtime = 4 #4 frames of no clicking allowed
		#var eq_sel = equipped_items_menu.get_selection()
		var using_eq = false
		var sel_indx = -1
		if inventory_menu.can_click():
			sel_indx = inventory_menu.get_menu_selection()
		else:
			var gi = PlayerInformation.get_item_data(grabbed_item_index)
			var eq_filter = -1 #-1 is wildcard (empty can always click slots)
			if !gi.is_empty() and grabbed_item:
				eq_filter = gi[Items.INDEX_EQUIPMENT_ID]
			sel_indx = equipped_items_menu.get_selection(eq_filter)
			using_eq = true
		
		
		
		if sel_indx != -1: #if valid button was hit
			if !items_interacting:
				#var sel_indx = inventory_menu.get_menu_selection()
				if !grabbed_item:
					var item_data = PlayerInformation.get_item_data(sel_indx)
					if !item_data.is_empty(): #clicked on full slot with nothing in hand
						inventory_menu.pretend_empty_index = sel_indx
						equipped_items_menu.pretend_empty_index = sel_indx
						inventory_menu._update_inventory_graphics() #called only here because not actually chaning inventory
						equipped_items_menu._update_inventory_graphics()
						grabbed_item_index = sel_indx
						grabbed_item = true
						play_item_sound(sel_indx, "grab_start")
					else:
						#just clicked on empty slot with nothing in hand
						pass
				else: #just clicked on slot with something in hand
					if !grabbed_storage_item:
						_on_item_interaction(grabbed_item_index,sel_indx)
					else: #grabbed stored_item, not traditionaly accessable
						_on_item_interaction_half_stored(sel_indx,grabbed_item_index,grabbed_storage_item_index,true)
						pass
			else: #interaction already ongoing
				_on_item_menu_selected(interacting_1,interacting_2)
		else:
			var gi = PlayerInformation.get_item_data(grabbed_item_index)
			var eq_filter = -1 #-1 is wildcard (empty can always click slots)
			if !gi.is_empty() and grabbed_item:
				eq_filter = gi[Items.INDEX_EQUIPMENT_ID]
			var storage_sel = equipped_items_menu.get_item_storage_selection(eq_filter)
			if storage_sel.x != -1:
				var sel_item = PlayerInformation.inventory[storage_sel.x][1]["inventory"][storage_sel.y]
				print(storage_sel)
				if grabbed_item and !grabbed_storage_item:
					if sel_item.is_empty(): #clicked on empty slot with something in hand
						inventory_menu.pretend_empty_index = -1
						equipped_items_menu.pretend_empty_index = -1
						grabbed_item = false
						grabbed_storage_item = false
						var temp = PlayerInformation.steal_inventory_slot(grabbed_item_index)
						PlayerInformation.inventory[storage_sel.x][1]["inventory"][storage_sel.y] = temp
						PlayerInformation.emit_signal("update_inventory")
						if grabbed_item_index == PlayerInformation.held_item_index:
							PlayerInformation.emit_signal("update_held_item")
					else: #clicked on something while holding something
						_on_item_interaction_half_stored(grabbed_item_index,storage_sel.x,storage_sel.y,false)
						#inventory_menu.pretend_empty_index = -1
						#equipped_items_menu.pretend_empty_index = -1
						#grabbed_item = false
						#grabbed_storage_item = false
						#var temp = PlayerInformation.inventory[storage_sel.x][1]["inventory"][storage_sel.y]#PlayerInformation.steal_inventory_slot(grabbed_item_index)
						#PlayerInformation.inventory[storage_sel.x][1]["inventory"][storage_sel.y] = PlayerInformation.steal_inventory_slot(grabbed_item_index)
						#PlayerInformation.inventory[grabbed_item_index] = temp
						#PlayerInformation.emit_signal("update_inventory")
				elif grabbed_storage_item:
					#clicked on storage_item while holding storage_item
					print("not yet ready for storage on storage interactions")
					pass
				else:
					if !sel_item.is_empty(): #clicked on something while not holding anything
						print("this will be a pain :(")
						grabbed_item = true
						grabbed_item_index = storage_sel.x
						grabbed_storage_item = true
						grabbed_storage_item_index = storage_sel.y
						pass
					#else : clicked on nothing with nothing

func play_item_sound(index :int, sound_key : StringName) -> void:
	var sound = PlayerInformation.get_item_sound(index, sound_key)
	if sound == "":
		print("unimplemented sound key of " + str(sound_key))
		return
	$item_sounds.stream = load(sound)
	$item_sounds.play()

func set_inventory_open(val : bool) -> void:
	inventory_open = val
	inventory_menu.visible = val
	equipped_items_menu.visible = val
	if val:
		Global.in_game_mouse = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		inventory_menu._update_inventory_graphics() #just incase pretend_empty_index changed
		equipped_items_menu._update_inventory_graphics()
	else:
		grabbed_item = false
		grabbed_storage_item = false
		items_interacting = false
		item_menu.visible = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		select_inventory_slot(inventory_menu.get_menu_selection())
		Global.in_game_mouse = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func select_inventory_slot(i : int) -> void:
	if i >= PlayerInformation.inventory.size():
		print("invalid inventory slot selection")
		return
	PlayerInformation.change_held_item(i)

func _process(delta):
	if !inventory_open:
		return
	$inventory_menu/RadialMenu.freeze_selected = items_interacting
	if click_downtime > 0:
		click_downtime -= 1
		if click_downtime < 0:
			click_downtime = 0 #just in case
	if grabbed_item:
		$grabbed_item_name.visible = !item_menu.visible
		var item_data = PlayerInformation.get_item_data(grabbed_item_index)
		if item_data.is_empty():
			grabbed_item = false
			grabbed_storage_item = false
			inventory_menu.pretend_empty_index = -1
			equipped_items_menu.pretend_empty_index = -1
		var t = "holding_item"
		$grabbed_item_name.text = t
		$grabbed_item_name.position = DisplayServer.mouse_get_position()
	else:
		$grabbed_item_name.visible = false

var items_interacting = false
var interactions_list
var interacting_1 = 0
var interacting_2 = 0
func _on_item_interaction(index_1 : int, index_2) -> void: #-> when you click on index_2 with index_1 grabbed
	
	
	if index_1 == index_2:
		grabbed_item = false
		grabbed_storage_item = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		inventory_menu._update_inventory_graphics()
		equipped_items_menu._update_inventory_graphics()
		play_item_sound(grabbed_item_index, "grab_end")
		#return item no longer grabbed
		return
	var interaction_type = -1
	var item_data_1 = PlayerInformation.inventory[index_1]
	var item_data_2 = PlayerInformation.inventory[index_2]
	if item_data_1.is_empty():
		#this should never be empty
		return
	if item_data_2.is_empty(): #clicked on empty slot
		grabbed_item = false
		grabbed_storage_item = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		play_item_sound(grabbed_item_index, "grab_end")
		#just swap item positions
		var temp_data = PlayerInformation.swap_inventory_slot(index_2, PlayerInformation.inventory[index_1])
		PlayerInformation.set_inventory_slot(index_1,temp_data)
		return
	#clicked on item with item grabbed
	var key_1 = item_data_1[0]
	var key_2 = item_data_2[0]
	if !Items.interactions[key_1].has(key_2): #the items do not have any interactions
		grabbed_item = false
		grabbed_storage_item = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		#just swap item positions
		var temp_data = PlayerInformation.swap_inventory_slot(index_2, PlayerInformation.inventory[index_1])
		PlayerInformation.set_inventory_slot(index_1,temp_data)
		return
	#the items have interactions
	#ok now we get serious
	#bringing out the menu
	interacting_1 = index_1
	interacting_2 = index_2
	items_interacting = true
	interactions_list = Items.interactions[key_1][key_2]
	$item_menu/item_options_selection.number_of_slots = interactions_list.size()
	item_menu.visible = true
	item_menu.position = inventory_menu.get_slot_position(index_2)
	print(interactions_list)
	pass

func _on_item_menu_selected(index_1 : int, index_2) -> void:
	var index = $item_menu/item_options_selection.selected
	if index == -1:
		#center selected, swap items
		grabbed_item = false
		grabbed_storage_item = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		#just swap item positions
		var temp_data = PlayerInformation.swap_inventory_slot(index_2, PlayerInformation.inventory[index_1])
		PlayerInformation.set_inventory_slot(index_1,temp_data)
		#end interaction
		items_interacting = false
		item_menu.visible = false
		return
	#one of the options was selected
	grabbed_item = false
	grabbed_storage_item = false
	inventory_menu.pretend_empty_index = -1
	equipped_items_menu.pretend_empty_index = -1
	inventory_menu._update_inventory_graphics()
	equipped_items_menu._update_inventory_graphics()
	print("interaction index " +str(index) + " pressed")
	print(interactions_list[index])
	
	
	#end interaction
	items_interacting = false
	item_menu.visible = false
	
	pass

func _on_item_interaction_half_stored(index_1 : int, index_2: int, index_2_sub_index : int, holding_2 : bool = false) -> void:
	if index_1 == index_2:
		grabbed_item = false
		grabbed_storage_item = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		inventory_menu._update_inventory_graphics()
		equipped_items_menu._update_inventory_graphics()
		play_item_sound(grabbed_item_index, "grab_end")
		#return item no longer grabbed
		return
	var interaction_type = -1
	var item_data_1 = PlayerInformation.inventory[index_1]
	var item_data_2 = PlayerInformation.inventory[index_2][1]["inventory"][index_2_sub_index]
	if item_data_2.is_empty(): #asymmetrical function so uhh you should assume both sides good
		grabbed_item = false
		grabbed_storage_item = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		play_item_sound(grabbed_item_index, "grab_end")
		#just swap item positions
		var temp_data = PlayerInformation.swap_inventory_slot(index_1, PlayerInformation.inventory[index_2][1]["inventory"][index_2_sub_index])
		PlayerInformation.inventory[index_2][1]["inventory"][index_2_sub_index] = temp_data
		PlayerInformation.emit_signal("update_inventory")
		if index_1 == PlayerInformation.held_item_index:
			PlayerInformation.emit_signal("update_held_item")
		return
	if item_data_1.is_empty(): #clicked on empty slot
		grabbed_item = false
		grabbed_storage_item = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		play_item_sound(grabbed_item_index, "grab_end")
		#just swap item positions
		var temp_data = PlayerInformation.swap_inventory_slot(index_1, PlayerInformation.inventory[index_2][1]["inventory"][index_2_sub_index])
		PlayerInformation.inventory[index_2][1]["inventory"][index_2_sub_index] = temp_data
		PlayerInformation.emit_signal("update_inventory")
		if index_1 == PlayerInformation.held_item_index:
			PlayerInformation.emit_signal("update_held_item")
		return
	#clicked on item with item grabbed
	var key_1 = item_data_1[0]
	var key_2 = item_data_2[0]
	if !Items.interactions[key_1].has(key_2): #the items do not have any interactions
		grabbed_item = false
		grabbed_storage_item = false
		inventory_menu.pretend_empty_index = -1
		equipped_items_menu.pretend_empty_index = -1
		#just swap item positions
		var temp_data = PlayerInformation.swap_inventory_slot(index_1, PlayerInformation.inventory[index_2][1]["inventory"][index_2_sub_index])
		PlayerInformation.inventory[index_2][1]["inventory"][index_2_sub_index] = temp_data
		PlayerInformation.emit_signal("update_inventory")
		if index_1 == PlayerInformation.held_item_index:
			PlayerInformation.emit_signal("update_held_item")
		return
	#the items have interactions
	#ok now we get serious
	#bringing out the menu
	printerr("sub_inventory interactions not implemented")
	return
	
	#interacting_1 = index_1
	#interacting_2 = index_2
	#items_interacting = true
	#interactions_list = Items.interactions[key_1][key_2]
	#$item_menu/item_options_selection.number_of_slots = interactions_list.size()
	#item_menu.visible = true
	#item_menu.position = inventory_menu.get_slot_position(index_2)
	#print(interactions_list)
	#pass

func _on_item_menu_selected_half_stored(index_1 : int, index_2 : int, index_2_sub_index : int) -> void:
	
	pass

