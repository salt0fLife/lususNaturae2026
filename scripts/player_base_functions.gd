extends CharacterBody3D
class_name PlayerBase
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var maxSpeed = 5.0
@export var acceleration = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var MouseSensitivity = 2.5

func say_hellow_world() -> String:
	return "hellow world!"

func attempt_loose_item_pickup(path_to : String) -> void:
	var node = get_node_or_null(path_to)
	if node == null:
		return #cannot pickup is null
	if !PlayerInformation.is_hand_empty():
		print("cannot pickup, hand is full")
		return #hand is full cannot pickup
	var data = node.data
	PlayerInformation.set_inventory_slot(PlayerInformation.held_item_index,data)
	node.call_deferred("queue_free")
	print("picked up " + str(data[0]))

func use_held_item():
	var data = PlayerInformation.get_held_item_data()
	if data.is_empty():
		print("punched")
		return
	var type = data[3]
	match type:
		Items.FOOD:
			if PlayerInformation.food >= PlayerInformation.max_food:
				print("cant eat any more you are full")
				return
			print("ate " + str(data[0]))
			PlayerInformation.set_inventory_slot(PlayerInformation.held_item_index, [])
			PlayerInformation.eat_food(data[4])
