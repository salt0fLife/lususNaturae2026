extends CharacterBody3D
@onready var graphics = $graphics
@onready var camera_base = $camera_base
@onready var cameraHandler = $camera_base/camera_handler
@onready var view_handler = $graphics/cameraHandler #decides which direction your character is looking
@onready var interaction_sightline = $camera_base/camera_handler/camerasOffset/SpringArm3D/Node3D/interaction_sightline
@onready var weapon_handler = $graphics/cameraHandler/weapon_handler
@onready var held_item_handler = $graphics/character/Vidica_basic/metarig/Skeleton3D/BoneAttachment3D7/held_item_handler#$graphics/cameraHandler/hands/held_item_handler
@onready var action_player = $actionPlayer
@onready var anim = $graphics/character/Vidica_basic/AnimationPlayer
@onready var dir_anim = $graphics/character/Vidica_basic/AnimationTree
@onready var dir_anim_mw = $graphics/character/Vidica_basic/mw

@export var mouse_sensitivity:float = 2.5

@export var gravity:Vector3 = Vector3(0.0,-14.7,0.0)

#movement
@export var ground_acceleration:float = 10.0
@export var air_acceleration:float = 1.0
@export var air_acceleration_tilt_jump:float = 5.0
@export var ground_friction:float = 4.0

@export var crouching_speed:float = 1.0
@export var walking_speed:float = 1.125
@export var jogging_speed:float = 3.0
@export var sprinting_speed:float = 9.5
@export var dashing_speed:float = 9.5
@export var tilt_jump_speed:float = 9.5
@export var jump_strength:float = 5.0
@export var max_friction_decceleration = 20.0

var sprinting:bool = false
var crouching:bool = false
var walking:bool = false

var tilt_jumped:bool = false
var air_jumped:bool = false

#stepping
var _snapped_to_stairs_last_frame: bool = false
var MAX_STEP_HEIGHT: float = 0.55
var jumped_last_frame : bool = false
#

var team:StringName = "limbo"

func _ready():
	PlayerInformation.connect("teleport", tp)
	PlayerInformation.connect("attempt_to_drop_item", _on_item_drop_attempt)
	#PlayerInformation.connect("dropped_item", _on_dropped_item)
	PlayerInformation.connect("update_held_item", update_held_item_graphics)
	update_held_item_graphics()
	weapon_handler.connect("dealt_damage",_on_deal_damage)
	PlayerInformation.connect("used_held_item",use_held_item)
	PlayerInformation.connect("released_held_item",release_held_item)
	interaction_sightline.connect("interacted",_on_successful_interaction)
	
	
	#to update it
	PlayerInformation.set_blood(PlayerInformation.blood)
	PlayerInformation.set_health(PlayerInformation.health)

func update_held_item_graphics() -> void:
	for old in held_item_handler.get_children(false):
		old.queue_free()
	var id = PlayerInformation.get_held_item_data()
	if id.is_empty():
		return
	var m = load(id[Items.INDEX_MODEL]).instantiate()
	held_item_handler.add_child(m)

var combo_counter: int = 0
var aiming:bool = false #player aligns with camera for shooting or blocking
func use_held_item(special:bool = false) -> void:
	if special:
		aiming = true
		return
	#print("used item")
	var item_data = PlayerInformation.get_held_item_data()
	if item_data.is_empty():
		return
	var type = item_data[Items.INDEX_TYPE]
	match type:
		Items.type.SWORD:
			var input_dir = Input.get_vector("left", "right", "up", "down")
			if !airborn:
				var key = "atk_swr_f_g_01"
				match combo_counter:
					1:
						key = "atk_swr_f_g_02"
					2:
						key = "atk_swr_f_g_03"
					_:
						key = "atk_swr_f_g_01"
						combo_counter = 0
				#var key = "atk_swr_f_g_01"
				#if -input_dir.y >= abs(input_dir.x) or input_dir.length() < 0.1: #is forward
					#match combo_counter:
						#1:
							#key = "atk_swr_f_g_02"
						#2:
							#key = "atk_swr_f_g_03"
						#_:
							#key = "atk_swr_f_g_01"
							#combo_counter = 0
				#else: #is to the side or back
					#if abs(input_dir.y) > abs(input_dir.x): #backwards
						#key = "atk_swr_b_g_01"
					#elif input_dir.x > 0.0: #to the right
						#key = "atk_swr_r_g_01"
					#else: #to the left
						#key = "atk_swr_l_g_01"
				if play_anim(key):
					combo_counter += 1
		Items.type.FOOD:
			PlayerInformation.eat_food(item_data[Items.INDEX_DATA])
			PlayerInformation.set_inventory_slot(PlayerInformation.held_item_index,[])

func release_held_item(special:bool = false) -> void:
	if special:
		aiming = false
		return
	pass

@onready var jog_tree = $graphics/character/Vidica_basic/AnimationTree
func play_anim(key:StringName, interrupting:bool = false) -> bool:
	if action_player.is_playing() and !interrupting:
		return false#cant play a new animation until old action has finished
	if anim.current_animation == key:
		return false #already playing
	
	if action_player.has_animation(key):
		if action_player.current_animation != key:
			action_player.play(key)
	elif action_player.is_playing():
		print("reset action_player")
		action_player.play("RESET")
	
	if anim.has_animation(key):
		if !anim.current_animation == key:
			anim.play(key,0.1)
	return true #can play the anim
	
#end connections

var sprint_held_timer = 0.0
func _input(event):
	if event is InputEventMouseMotion and !Global.in_game_mouse:
		var TempRotation = rotation.x - event.relative.y /1000 * mouse_sensitivity
		cameraHandler.rotation.x += TempRotation
		cameraHandler.rotation.x = clamp(cameraHandler.rotation.x, -1.5, 1.5) #formerly -1.25,1.5
		#graphics.rotation.y -= event.relative.x /1000 * mouse_sensitivity
		#if graphics.rotation.y > PI*64.0:
			#graphics.rotation.y -= PI*64.0
		#elif graphics.rotation.y < -PI*64.0:
			#graphics.rotation.y += PI*64.0
		camera_base.rotation.y -= event.relative.x /1000 * mouse_sensitivity
		if camera_base.rotation.y > PI*64.0:
			camera_base.rotation.y -= PI*64.0
		elif camera_base.rotation.y < -PI*64.0:
			camera_base.rotation.y += PI*64.0
	if Input.is_action_just_pressed("sprint"):
		sprint_held_timer = 0.0
		sprinting = true
	if Input.is_action_just_released("sprint"):
		if sprint_held_timer < 0.1:
			initiate_dash()
		sprinting = false
	if Input.is_action_just_pressed("dash"):
		initiate_dash()
	if Input.is_action_just_pressed("crouch"):
		crouching = true
	if Input.is_action_just_released("crouch"):
		crouching = false
	if Input.is_action_just_pressed("walk"):
		walking = !walking #toggle
	

func initiate_dash():
	dashing_timer = 0.25
	set_state("dash_state")

var blood_loss_timer = 0.0
func _process(delta):
	if sprinting:
		sprint_held_timer += delta
	update_tooltip()
	if PlayerInformation.blood > PlayerInformation.max_blood:
		blood_loss_timer += delta * 2.5
		if blood_loss_timer > 1.0:
			blood_loss_timer -= 1.0
			PlayerInformation.set_blood(PlayerInformation.blood-1)

func get_movement_anim(key:StringName) -> StringName:
	var d = PlayerInformation.get_held_item_data()
	var t = -1
	if !d.is_empty():
		t = d[Items.INDEX_ANIMATIONS]
	match key:
		"walk":
			match t:
				Items.animation.SWORD_ANIM:return "walk_forward_mw"
				_:return "walk_forward_empty"
		"jog":
			match t:
				Items.animation.SWORD_ANIM:return "jog_forward_mw"
				_:return "jog_forward_empty"
		"idle":
			match t:
				Items.animation.SWORD_ANIM:return"idle_mw"
				_:return "idle_empty"
		"sprint":
			return "sprint_forward_empty"
		_:
			return "RESET"

const walking_actions:Array = [
	"attack_sword_01",
	"attack_sword_02",
	"attack_sword_03"
]

func set_dir_anim(val : bool) -> void:
	var d = PlayerInformation.get_held_item_data()
	var key = -1
	if !d.is_empty():
		key = d[Items.INDEX_ANIMATIONS]
	if !val: #disable all
		dir_anim_mw.active = false
		dir_anim.active = false
		return
	match key:
		Items.animation.SWORD_ANIM:
			dir_anim_mw.active = val
			dir_anim.active = !val
		_:
			dir_anim_mw.active = !val
			dir_anim.active = val
	pass

func set_dir_anim_target(val:Vector2) -> void:
	dir_anim.set("parameters/blend_position",val)
	dir_anim_mw.set("parameters/blend_position",val)

var airborn = false
var dashing_timer:float = 0.0
var dashing = false
var state = "default_state"
func _physics_process(delta):
	if action_player.is_playing():
		#dir_anim.active = false
		set_dir_anim(false)
		if walking_actions.has(action_player.current_animation):
			var direction = (graphics.transform.basis * Vector3(0.0, 0, -1.0)).normalized()
			move_and_collide(direction*jogging_speed*delta,false)
			update_player_information()
			return
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (camera_base.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	view_handler.rotation.x = lerp_angle(view_handler.rotation.x,cameraHandler.rotation.x,delta*16.0)
	
	
	if !is_on_floor():
		velocity += gravity*delta
		airborn = true
	else:
		tilt_jumped = false
		air_jumped = false
		if airborn:
			graphics.step_sound(graphics.get_floor_groups(),2)
			airborn = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_strength
			graphics.step_sound(graphics.get_floor_groups(),2)
			graphics.camera_handler_vel.y -= jump_strength
			set_state("falling_state")
			if randf_range(0.0,1.0) > 0.2:
				play_anim("jog_jump_empty_02")
			else:
				play_anim("jog_jump_empty_01")
			if sprinting:
				#tilt_jumped = true
				velocity = direction*tilt_jump_speed
				velocity.y = jump_strength * 1.1
				play_anim("sprint_jump_empty")
			airborn = true
	
	if has_method(state):
		call(state,delta)
	else:
		set_state("idle_state")

func set_state(val : StringName) -> void:
	set_dir_anim(false) #just for niceties
	state = val

##start states

func jogging_state(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (camera_base.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if aiming:
		var g_rot = camera_base.rotation.y
		graphics.rotation.y = lerp_angle(graphics.rotation.y, g_rot,delta*16.0)
		if direction:
			#dir_anim.active = true
			set_dir_anim(true)
			var prev = dir_anim["parameters/blend_position"]
			var nv = lerp(prev,Vector2(input_dir.x,-input_dir.y),delta*16.0);
			#dir_anim.set("parameters/blend_position",nv)
			set_dir_anim_target(nv)
		else:
			#dir_anim.active = false
			set_dir_anim(false)
	elif direction:
		var g_rot = Global.dir_to_rot(direction).y + PI
		graphics.rotation.y = lerp_angle(graphics.rotation.y, g_rot,delta*16.0)
		#dir_anim.active = false
		set_dir_anim(false)
	
	if direction:
		#graphics.rotation.y = lerp_angle(graphics.rotation.y,camera_base.rotation.y,delta*16.0)
		
		var desired_speed:float = jogging_speed
		if sprinting:
			desired_speed = sprinting_speed
		elif crouching:
			desired_speed = crouching_speed
		elif walking:
			desired_speed = walking_speed
		
		if !airborn:
			velocity = update_velocity_floor(delta, desired_speed, ground_acceleration,direction)
			if sprinting:
				play_anim(get_movement_anim("sprint"))
				graphics.running(delta,velocity)
			elif crouching:
				play_anim(get_movement_anim("crouch"))
			elif walking:
				play_anim(get_movement_anim("walk"))
				graphics.walking(delta,velocity)
			else:
				play_anim(get_movement_anim("jog"))
				graphics.walking(delta*1.5,velocity)
		else:
			if !tilt_jumped:
				velocity = update_velocity_air(delta, desired_speed, air_acceleration,direction)
			else:
				velocity = update_velocity_tilt_jump(delta,tilt_jump_speed,air_acceleration_tilt_jump,direction)
	elif tilt_jumped:
		velocity = update_velocity_tilt_jump(delta,tilt_jump_speed,air_acceleration_tilt_jump,direction)
	else:
		set_state("idle")
	#move_and_slide()
	end_physics_process(delta)

func idle_state(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (camera_base.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		set_state("jogging_state")
	play_anim(get_movement_anim("idle"))
	if is_on_floor():
		var s_v = velocity*ground_acceleration*ground_friction
		s_v = s_v.normalized() * clamp(s_v.length(),0.0,max_friction_decceleration)
		velocity -= s_v * delta
	end_physics_process(delta)

func dash_state(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (camera_base.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if dashing_timer > 0.0:
		##do the dashing stuff
		velocity = direction * dashing_speed
		var g_rot = Global.dir_to_rot(direction).y + PI
		graphics.rotation.y = lerp_angle(graphics.rotation.y, g_rot,delta*16.0)
		##
		if !dashing:
			dashing = true
			set_dashing(true)
			#start dash
		dashing_timer -= delta
		if dashing_timer < 0.0:
			dashing = false
			set_dashing(false)
			#end dash
			dashing_timer = 0.0
		end_physics_process(delta)
	else:
		set_state("exit_dash_state")

func falling_state(delta):
	var g_rot = Global.dir_to_rot(velocity).y + PI
	graphics.rotation.y = lerp_angle(graphics.rotation.y, g_rot,delta*16.0)
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (camera_base.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !tilt_jumped:
			velocity = update_velocity_air(delta, jogging_speed, air_acceleration,direction)
		else:
			velocity = update_velocity_tilt_jump(delta,tilt_jump_speed,air_acceleration_tilt_jump,direction)
	end_physics_process(delta)
	if !airborn:
		if direction:
			set_state("jogging_state")
		else:
			set_state("idle_state")


##end states

func end_physics_process(delta):
	cameraHandler.position -= velocity*delta*0.05
	if not snap_up_to_stairs_check(delta):
		move_and_slide()
		snap_down_to_stairs_check()
	update_player_information()

func set_dashing(val:bool) -> void:
	$graphics/character.visible = !val
	$graphics/dashing_wraith.visible = val
	if val:
		#started dash
		pass
	else:
		#dash ended
		pass

func run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if !result:
		result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func is_surface_to_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func snap_down_to_stairs_check() -> void:
	if !is_on_floor() and !velocity.y > 0.0:
		if run_body_test_motion(transform,Vector3(0.0,-MAX_STEP_HEIGHT,0.0)):
			#print("snapped down to stairs")
			var ocp = cameraHandler.global_position
			move_and_collide(Vector3(0.0,-MAX_STEP_HEIGHT,0.0))
			cameraHandler.global_position.y = ocp.y
	#var did_snap := false
	#var floor_below : bool = $stepDownCheckRaycast.is_colliding() and not is_surface_to_steep($stepDownCheckRaycast.get_collision_normal())
	#var was_on_floor_last_frame = Engine.get_physics_frames() - last_frame_was_on_floor == 1
	#if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:# and !jumped_last_frame:
		#var body_test_result = PhysicsTestMotionResult3D.new()
		#if run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			#var translate_y = body_test_result.get_travel().y
			#self.position.y += translate_y
			#apply_floor_snap()
			#did_snap = true
	#_snapped_to_stairs_last_frame = did_snap

func snap_up_to_stairs_check(delta) -> bool:
	#if jumped_last_frame: return false
	if airborn: return false #just for jumping while climbing
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	###
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		###
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT: return false
		$stairsAheadRaycast.global_position = down_check_result.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
		$stairsAheadRaycast.force_raycast_update()
		if $stairsAheadRaycast.is_colliding() and not is_surface_to_steep($stairsAheadRaycast.get_collision_normal()):
			var travel = down_check_result.get_travel()
			var ocp = cameraHandler.global_position
			self.global_position = step_pos_with_clearance.origin + travel#down_check_result.get_travel()
			#print("snapped up to stairs")
			#camera.position -= travel
			cameraHandler.global_position.y = ocp.y
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

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
			attempt_loose_item_pickup(data)
			#print("pickup item")
		Global.interact_returns.ENTER_DOOR:
			enter_door(data)
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

func _on_item_drop_attempt(index : int) -> void:
	var data = PlayerInformation.steal_inventory_slot(index)
	#PlayerInformation.emit_signal("dropped_item", data, look_dir_reference.global_position)
	#(data, pos, rotation, stuck, velL , velR) -> void:
	Global.drop_item(data,held_item_handler.global_position,held_item_handler.global_rotation,false,velocity)
	PlayerInformation.emit_signal("update_held_item")

func update_tooltip() -> void:
	var text = interaction_sightline.get_tooltip()
	Global.tooltip(text)
	pass

@onready var look_dir_reference = $graphics/cameraHandler/look_dir_reference
func get_look_dir() -> Vector3:
	return (look_dir_reference.global_position - cameraHandler.global_position)

#health and such

func take_damage(amount : int,type : int)  -> int:
	if dashing: #invulnerable during dash
		return 0
	#Global.indicate_damage(amount,type,global_position)
	var dealt = amount #calc resists and such here
	var blood = PlayerInformation.blood
	if blood - dealt > 0:
		PlayerInformation.set_blood(PlayerInformation.blood - amount)
		return 0
	elif blood > 0:
		if PlayerInformation.health + blood - amount > 0:
			amount -= blood
			PlayerInformation.set_blood(0)
			PlayerInformation.set_health(PlayerInformation.health - dealt)
		else:
			PlayerInformation.set_blood(0)
			PlayerInformation.set_health(0)
			PlayerInformation.die()
		#PlayerInformation.set_blood(0)
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


