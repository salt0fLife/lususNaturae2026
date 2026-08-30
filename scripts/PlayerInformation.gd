extends Node

##all the information portaning to the player directly
#ie transformation stage, location, player_statistics, map data, inventory, health, hunger, etc...

var position := Vector3.ZERO
var rotation := Vector2.ZERO
var velocity := Vector3.ZERO

var sprinting: bool = false
var crouching: bool = false

signal change_player
func change_player_scene(key : int) -> void:
	if !player_scenes.has(key):
		printerr("called change_player_scene with non valid key")
		return
	emit_signal("change_player", key)

const player_scenes = {
	01 : ["res://campaign/player/player_01.tscn"],
	99 : ["res://campaign/player/player_99.tscn"],
	00 : ["res://campaign/player/player_character_test_model.tscn"],
	-1 : ["res://campaign/player/player_combat_test.tscn"],
	-2 : ["res://campaign/player/emerge_from_ground_player.tscn"]
}

var upgrades = [
	
	
]


#gameplay
var health: float = 5.0
var max_health: float = 5.0
var food: int = 1
var max_food: int = 5
var min_sleep_food: int = 4
var sun_sickness: float = 0.0 #builds up when in sunlight goes down in shade


var wall_sliding_timer:float = 0.0
var max_dash:float = 3.0
var current_dash:float = 3.0

var using_senses : bool = false

signal changed_using_senses
func set_using_senses(val :bool) -> void:
	var change = (using_senses != val)
	using_senses = val
	if change:
		emit_signal("changed_using_senses")
	

signal ate_food
func eat_food(data : Array) -> void:
	food = clamp(food + data[0],0.0,max_food)

enum { #damage tags
	DAMAGE_DEV
	
}

signal took_damage
func take_damage(amount : int, tag : int) -> void:
	health -= amount
	emit_signal("took_damage")
	if health < 0.0:
		die()

signal perished
func die():
	print("perished")
	health = max_health
	sun_sickness = 0.0
	emit_signal("perished")

signal teleport
func tp(pos : Vector3, rot : Vector2 = rotation) -> void:  #works with or without player scene
	emit_signal("teleport", pos, rot)
	position = pos
	rotation = rot
	pass

#inventory stuff
var held_item_index: int = 0 #-1 is an empty hand (problem is picking up items, 
#i made it so you have to have empty hand, so now -1 is not allowed as it is not valid pickup spot)
signal update_inventory
signal update_held_item
const equipment_slot_count = 2 #number of slots at end that are for equipment instead of real item slot
var inventory: Array = [
	[],
	[],
	[],
	[],
	[],
	[], #backpack
	[], #quiver
]

func load_inventory(new_inventory : Array) -> void: #so i can do stuffs :D
	print("#LOADED INVENTORY#")
	var to_small = clampi((7- new_inventory.size()),0,1)
	inventory = new_inventory
	for i in to_small:
		inventory.append([])
	emit_signal("update_inventory")
	pass

func get_backpack_index() -> int:
	return inventory.size() - equipment_slot_count

func get_inventory_vacancy(_item) -> int: #data because it should eventually check for stacking
	for i in range(0,inventory.size() - equipment_slot_count):
		if inventory[i].is_empty():
			return i
	return -1

func change_held_item(index : int) -> void:
	if index >= inventory.size() or index < 0:
		index = -1
	if held_item_index != index:
		held_item_index = index
		emit_signal("update_held_item")

func set_inventory_slot(index : int, data : Array) -> void: #sets data value of slot
	print(inventory)
	inventory[index] = data
	emit_signal("update_inventory")
	if index == held_item_index:
		emit_signal("update_held_item")

func steal_inventory_slot(index : int) -> Array: #gives you the data and erases entry
	if index >= inventory.size() or index < 0:
		index = 0
	var data = inventory[index]
	inventory[index] = []
	emit_signal("update_inventory")
	return data

func swap_inventory_slot(index : int, new_data : Array) -> Array: #sets item and returns item it replaced
	if index >= inventory.size() or index < 0:
		index = 0
	var old_data = inventory[index]
	inventory[index] = new_data
	emit_signal("update_inventory")
	if index == held_item_index:
		emit_signal("update_held_item")
	return old_data

func get_held_item_data() -> Array:
	var key = ""
	if held_item_index == -1:
		return []
	var data = inventory[held_item_index]
	if data.is_empty():
		return []
	key = data[0]
	return Items.list[key]

func get_item_data(index : int) -> Array:
	var key = ""
	if index < 0: # == -1: #still works and covers for mishaps
		return []
	if index > inventory.size():
		printerr(str(index) + " is not a valid inventory index")
		return []
	var data = inventory[index]
	if data.is_empty():
		return []
	key = data[0]
	return Items.list[key]

signal dropped_item #item, position
signal attempt_to_drop_item #index

func drop_held_item() -> void:
	if held_item_index == -1:
		return
	#var data = steal_inventory_slot(held_item_index)
	var data = inventory[held_item_index]
	if data.is_empty():
		return
	#emit_signal("dropped_item", data, position)
	emit_signal("attempt_to_drop_item",held_item_index)
	#emit_signal("update_held_item")

func pickup_item(data : Array) -> bool:
	if inventory[held_item_index].is_empty():
		set_inventory_slot(held_item_index,data)
		print("picked up item " + str(data[0]))
		return true
	else:
		print("cannot pickup hands are full")
		return false

func is_hand_empty() -> bool: #can optimize later if feel like it
	return get_held_item_data().is_empty()

signal used_item
signal slept

func get_held_item_sound(sound_key : String) -> String:
	var data = get_held_item_data()
	if data == []:
		return ""
	 #["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
	var sk = data[2]
	if !Items.sounds.has(sk):
		printerr("use of invalid sound key " + str(sk))
		return ""
	
	var sounds = Items.sounds[sk]
	if !sounds.has(sound_key):
		printerr("item does not include sound " + str(sound_key))
		return ""
	return sounds[sound_key]

func get_item_sound(index : int, sound_key : String) -> String:
	var data = []#get_item_data(index)
	#if equipped:
		#data = get_equipped_item_data(index)
	#else:
	data = get_item_data(index)
	if data == []:
		return ""
	 #["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
	var sk = data[Items.INDEX_SOUNDS]
	if !Items.sounds.has(sk):
		printerr("use of invalid sound key " + str(sk))
		return ""
	
	var sounds = Items.sounds[sk]
	if !sounds.has(sound_key):
		printerr("item does not include sound " + str(sound_key))
		return ""
	return sounds[sound_key]

func player_sleep() -> bool: #weather or not you can sleep
	if !can_sleep():
		return false
	Global.play_cutscene("dream_1")
	#day_timer = day_length*0.501
	print("player_slept")
	PlayerInformation.health = clamp(round(PlayerInformation.health-0.49) + 1.0, 0.0, PlayerInformation.max_health)
	PlayerInformation.food -= 2
	#in_game_days += 1
	emit_signal("slept")
	#_on_checkpoint_reached()
	return true

func can_sleep() -> bool:
	if min_sleep_food > food:
		print("you are too hungry to sleep")
		return false
	return true
