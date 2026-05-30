extends Node

##all the information portaning to the player directly
#ie transformation stage, location, player_statistics, map data, inventory, health, hunger, etc...

var position := Vector3.ZERO
var rotation := Vector2.ZERO
var velocity := Vector3.ZERO

var sprinting: bool = false
var crouching: bool = false

const player_scenes = {
	01 : ["res://campaign/player/player_01.tscn"],
	99 : ["res://campaign/player/player_99.tscn"],
	00 : ["res://campaign/player/player_character_test_model.tscn"],
	-1 : ["res://campaign/player/player_combat_test.tscn"],
}


#gameplay
var health: float = 1.0
var max_health: float = 5.0
var food: int = 1
var max_food: int = 5
var min_sleep_food: int = 4

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
func take_damage(amount : float, tag : int) -> void:
	health -= amount
	emit_signal("took_damage")
	if health < 0.0:
		die()

signal perished
func die():
	print("perished")
	health = max_health
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
var inventory: Array = [
	[],
	[],
	[],
	["moldy_bread"],
	["moldy_bread"]
]

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

signal dropped_item

func drop_held_item() -> void:
	if held_item_index == -1:
		return
	var data = steal_inventory_slot(held_item_index)
	if data.is_empty():
		return
	emit_signal("dropped_item", data, position)
	emit_signal("update_held_item")

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
		print("use of invalid sound key " + str(sk))
		print(Items.sounds)
		return ""
	
	var sounds = Items.sounds[sk]
	if !sounds.has(sound_key):
		return ""
	return sounds[sound_key]
