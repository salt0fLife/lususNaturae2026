extends CharacterBody3D
@onready var graphics = $graphics
@onready var cameraHandler = $graphics/cameraHandler
@onready var interaction_sightline = $graphics/cameraHandler/interaction_sightline
@onready var weapon_handler = $graphics/cameraHandler/weapon_handler
@onready var held_item_handler = $graphics/cameraHandler/hands/held_item_handler
@onready var action_player = $actionPlayer

@export var mouse_sensitivity:float = 2.5

@export var gravity:Vector3 = Vector3(0.0,-14.7,0.0)

#movement
@export var ground_acceleration:float = 10.0
@export var air_acceleration:float = 1.0
@export var air_acceleration_tilt_jump:float = 5.0
@export var ground_friction:float = 4.0

@export var walking_speed:float = 4.5
@export var sprinting_speed:float = 9.5
@export var tilt_jump_speed:float = 9.5
@export var jump_strength:float = 5.0
@export var max_friction_decceleration = 20.0

var sprinting:bool = false

var tilt_jumped:bool = false
var air_jumped:bool = false
#


func _ready():
	PlayerInformation.connect("teleport", tp)
	#PlayerInformation.connect("dropped_item", _on_dropped_item)
	PlayerInformation.connect("update_held_item", update_held_item_graphics)
	update_held_item_graphics()
	weapon_handler.connect("dealt_damage",_on_deal_damage)
	PlayerInformation.connect("used_held_item",use_held_item)
	PlayerInformation.connect("released_held_item",release_held_item)
	interaction_sightline.connect("interacted",_on_successful_interaction)

func update_held_item_graphics() -> void:
	for old in held_item_handler.get_children(false):
		old.queue_free()
	var id = PlayerInformation.get_held_item_data()
	if id.is_empty():
		return
	var m = load(id[Items.INDEX_MODEL]).instantiate()
	held_item_handler.add_child(m)

func use_held_item(special:bool = false) -> void:
	print("used item")
	var item_data = PlayerInformation.get_held_item_data()
	if item_data.is_empty():
		return
	var type = item_data[Items.INDEX_TYPE]
	match type:
		Items.type.SWORD:
			play_anim("swing_sword_L")
		Items.type.FOOD:
			PlayerInformation.eat_food(item_data[Items.INDEX_DATA])
			PlayerInformation.set_inventory_slot(PlayerInformation.held_item_index,[])

func release_held_item(special:bool = false) -> void:
	
	pass

func play_anim(key:StringName) -> void:
	if action_player.has_animation(key):
		if action_player.current_animation != key:
			action_player.play(key)
	else:
		action_player.play("RESET")
	
	pass

#end connections

func _input(event):
	if event is InputEventMouseMotion and !Global.in_game_mouse:
		var TempRotation = rotation.x - event.relative.y /1000 * mouse_sensitivity
		cameraHandler.rotation.x += TempRotation
		cameraHandler.rotation.x = clamp(cameraHandler.rotation.x, -1.5, 1.5) #formerly -1.25,1.5
		graphics.rotation.y -= event.relative.x /1000 * mouse_sensitivity
		if graphics.rotation.y > PI*64.0:
			graphics.rotation.y -= PI*64.0
		elif graphics.rotation.y < -PI*64.0:
			graphics.rotation.y += PI*64.0
	if Input.is_action_just_pressed("sprint"):
		sprinting = true
	if Input.is_action_just_released("sprint"):
		sprinting = false

var blood_loss_timer = 0.0
func _process(delta):
	update_tooltip()
	if PlayerInformation.blood > PlayerInformation.max_blood:
		blood_loss_timer += delta
		if blood_loss_timer > 1.0:
			blood_loss_timer -= 1.0
			PlayerInformation.set_blood(PlayerInformation.blood-1)

var airborn = false
func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (graphics.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if !is_on_floor():
		velocity += gravity*delta
		airborn = true
		#if Input.is_action_just_pressed("jump"):
			#if !air_jumped:
				#velocity = direction*tilt_jump_speed
				#velocity.y = jump_strength
				#tilt_jumped = true
				#air_jumped = true
	else:
		tilt_jumped = false
		air_jumped = false
		airborn = false
		if Input.is_action_just_pressed("jump"):
			if sprinting:
				#tilt_jumped = true
				velocity = direction*tilt_jump_speed
			velocity.y = jump_strength
			airborn = true
	
	
	if direction:
		var desired_speed:float = walking_speed
		if sprinting:
			desired_speed = sprinting_speed
		
		if is_on_floor():
			velocity = update_velocity_floor(delta, desired_speed, ground_acceleration,direction)
			if sprinting:
				graphics.running(delta,velocity)
			else:
				graphics.walking(delta,velocity)
		else:
			if !tilt_jumped:
				velocity = update_velocity_air(delta, desired_speed, air_acceleration,direction)
			else:
				velocity = update_velocity_tilt_jump(delta,tilt_jump_speed,air_acceleration_tilt_jump,direction)
	elif tilt_jumped:
		velocity = update_velocity_tilt_jump(delta,tilt_jump_speed,air_acceleration_tilt_jump,direction)
	else:
		if is_on_floor():
			var s_v = velocity*ground_acceleration*ground_friction
			s_v = s_v.normalized() * clamp(s_v.length(),0.0,max_friction_decceleration)
			velocity -= s_v * delta
	
	move_and_slide()
	update_player_information()

func update_player_information() -> void:
	PlayerInformation.position = position
	PlayerInformation.rotation = Vector2(cameraHandler.rotation.x, graphics.rotation.y)
	PlayerInformation.velocity = velocity
	#PlayerInformation.crouching = crouching
	PlayerInformation.sprinting = sprinting
	#PlayerInformation.max_dash = max_dash
	#PlayerInformation.current_dash = current_dash

func update_velocity_floor(delta, speed, acceleration,dir) -> Vector3:
	var nv = lerp(velocity,dir*speed,delta*acceleration)
	return Vector3(nv.x,velocity.y,nv.z) #temp

func update_velocity_air(delta, speed, acceleration,dir) -> Vector3:
	var nv = lerp(velocity,dir*speed,delta*acceleration)
	return Vector3(nv.x,velocity.y,nv.z) #temp
#func update_velocity_air(frame_time : float, speed : float, acceleration:float, wishdir : Vector3) -> Vector3:
	#var vel = velocity
	#var current_speed = Vector2(vel.x, vel.z).dot(Vector2(wishdir.x, wishdir.z))
	#
	#var add_speed = (speed - current_speed)
	#if add_speed < 0:
		#add_speed = 0
	#elif add_speed > acceleration * frame_time: #should be accaleration/4 but i made it more fun :D
		#add_speed = acceleration * frame_time
	#return vel + add_speed * wishdir

func update_velocity_tilt_jump(delta, speed, acceleration,dir) -> Vector3:
	var look_dir = get_look_dir()
	dir = (dir*0.25 + Vector3(look_dir.x,0.0,look_dir.z).normalized()*0.75) #yea this just sounded about right lmao
	var vel = lerp(velocity,dir*speed,delta*acceleration)
	vel.y = velocity.y
	vel -= gravity*delta*0.25
	return vel

func _on_successful_interaction(info : Array) -> void:
	var tag = info[0]
	var data = info[1]
	match tag:
		Global.interact_returns.PICKUP_ITEM:
			#attempt_loose_item_pickup(data)
			print("pickup item")
			pass
		Global.interact_returns.ENTER_DOOR:
			#enter_door(data)
			print("enter door")
			pass
		Global.interact_returns.SLEEP_IN_BED:
			sleep_in_bed(data)

func tp(pos : Vector3, rot : Vector2, vel := velocity) -> void:
	position = pos
	cameraHandler.rotation.x = rot.x
	graphics.rotation.y = rot.y
	velocity = vel
	pass

func sleep_in_bed(data):
	if PlayerInformation.can_sleep():
		PlayerInformation.player_sleep()
	else:
		Global.new_dialogue_box("to hungry to sleep", 2.0)
		#cant sleep :(
		pass

func enter_door(data):
	tp(data[1], data[2])
	Global.change_level_from_key(data[0])

func attempt_loose_item_pickup(path_to : String) -> void:
	var node = get_node_or_null(path_to)
	if node == null:
		return #cannot pickup is null
	if !PlayerInformation.is_hand_empty():
		var data = node.data #should be item but syntax highlighting :/
		var vacancy = PlayerInformation.get_inventory_vacancy(data)
		if vacancy == -1:
			print("cannot pickup, inventory is full")
			return #hand is full cannot pickup
		else:
			PlayerInformation.set_inventory_slot(vacancy,data)
			node.call_deferred("queue_free")
			print("stored " + str(data[0]) + " in nearest free slot")
			return #finished
	var data = node.data
	PlayerInformation.set_inventory_slot(PlayerInformation.held_item_index,data)
	node.call_deferred("queue_free")
	print("picked up " + str(data[0]))

func update_tooltip() -> void:
	var text = interaction_sightline.get_tooltip()
	Global.tooltip(text)
	pass

@onready var look_dir_reference = $graphics/cameraHandler/look_dir_reference
func get_look_dir() -> Vector3:
	return (look_dir_reference.global_position - cameraHandler.global_position)

#health and such

func take_damage(amount : int,type : int)  -> int:
	#Global.indicate_damage(amount,type,global_position)
	var dealt = amount #calc resists and such here
	var blood = PlayerInformation.blood
	if blood - dealt > 0:
		PlayerInformation.set_blood(PlayerInformation.blood - amount)
		return 0
	elif blood > 0:
		PlayerInformation.set_blood(0)
	elif PlayerInformation.health - dealt > 0:
		PlayerInformation.set_health(PlayerInformation.health - dealt)
	else:
		PlayerInformation.set_health(0)
		PlayerInformation.die()
	return 0

var blood_heal_multiplier:float = 0.25
func _on_deal_damage(amount: int, type:int) -> void:
	var mult = blood_heal_multiplier
	if type == Global.damage_types.BLEED:
		mult = 1.0 # tehehee
	var b = PlayerInformation.blood
	b += int(float(amount)*mult)
	b = clamp(b,0,PlayerInformation.max_blood*2)
	PlayerInformation.set_blood(b)


