extends CharacterBody3D

#nodepaths
@onready var cameraHandler = $graphics/cameraHandler
@onready var graphics = $graphics
@onready var interaction_sightline = $graphics/cameraHandler/interaction_sightline
@onready var camera = $graphics/cameraHandler/senses_camera
@onready var anim = $graphics/cameraHandler/fp_hands_wip/AnimationPlayer
@onready var held_item_handler = $graphics/cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/held_item_handler/node3d
@onready var prop_1_handler = $graphics/cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/BoneAttachment3D/prop_1_handler
@onready var item_sounds = $graphics/item_sounds
@onready var skeleton = $graphics/cameraHandler/fp_hands_wip/metarig_001/Skeleton3D
@onready var weapon_node = $graphics/cameraHandler/senses_camera/weapon_node

#attributes
@export_group("attributes")
@export var sprint_speed: float = 10.0
@export var walk_speed: float = 5.0
@export var crouch_speed: float = 3.0
@export var acceleration: float = 10.0
@export var air_acceleration: float = 1.0
@export var jump_strength: float = 4.5
@export var floor_friction: float = 8.0
@export var max_floor_slow_per_second: float = 45.0
@export var max_crouch_slow_per_second: float = 10.0
var sprinting_timer: float = 0.0 #how long you have been sprinting

#misc
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 1.5

##movement
#state stuff
var sprinting:bool = true
var crouching:bool = false
var aiming_down_sights:bool = false
#dash
@export_group("dash")
@export var max_dash:float = 3.0
var current_dash:float = 3.0
@export var dash_regen_speed:float = 0.25
var dash_vel: Vector3 = Vector3.ZERO
var dash_timer: float = 0.0 #goes from 1.0 -> 0.0 during dash
@export var dash_distance:float = 50.0 #nice 20.0
@export var dash_speed:float = 5.0
@export var dash_end_friction : float = 0.03 #nice 0.02
var velocity_at_dash_start : Vector3 = Vector3.ZERO

#lunge
var min_lunge_speed: float = 15.0

@export_group("air_jump")
#air jump
@export var max_air_jumps: int = 1
var air_jumps: int = 1

#wall run
@export_group("wall run")
@export var max_wall_run_duration: float = 5.0
var wall_run_timer : float = 0.0
@export var min_wallrun_speed : float = 5.0
var wall_run_cooldown : float = 0.0
var last_wall_run_normal = Vector3.ZERO
var last_wall_groups = []

##graphics
var desired_CH_height: float = 1.5
var desired_CH_rotation_z: float = 0.0
var combat_stance = 0.0

func _ready():
	interaction_sightline.connect("interacted", _on_successful_interaction)
	PlayerInformation.connect("teleport", tp)
	anim.connect("animation_finished", _on_anim_finished)
	PlayerInformation.connect("dropped_item", _on_dropped_item)
	PlayerInformation.connect("update_held_item", update_held_item_graphics)
	PlayerInformation.connect("attempt_to_drop_item", _on_item_drop_attempt)
	update_held_item_graphics()

func _input(event):
	if event is InputEventMouseMotion and !Global.in_game_mouse:
		var TempRotation = rotation.x - event.relative.y /1000 * mouse_sensitivity
		cameraHandler.rotation.x += TempRotation
		cameraHandler.rotation.x = clamp(cameraHandler.rotation.x, -1.5, 1.5) #formerly -1.25,1.5
		graphics.rotation.y -= event.relative.x /1000 * mouse_sensitivity
	if Input.is_action_just_pressed("sprint"):
		sprinting = !sprinting
	#if Input.is_action_just_pressed("sprint") and Input.is_action_pressed("up"):
		#sprinting = true
	#if Input.is_action_just_released("sprint"):
		#if sprinting_timer < 0.25:
			#dash()
		#sprinting = false
	#if Input.is_action_just_released("up"):
		#sprinting = false
	#if Input.is_action_just_pressed("up") and Input.is_action_pressed("sprint"):
		#sprinting = true
	if Input.is_action_just_pressed("crouch"):
		crouching = true
	if Input.is_action_just_released("crouch"):
		crouching = false
	if Input.is_action_just_pressed("dash"):
		dash()
	if Input.is_action_just_pressed("lunge"):
		lunge()

func lunge() -> void:
	var lunge_speed = velocity.length()
	if min_lunge_speed > lunge_speed:
		lunge_speed = min_lunge_speed
	
	var look_dir = get_look_dir()
	velocity = look_dir*lunge_speed

@onready var look_dir_reference = $graphics/cameraHandler/look_dir_reference
func get_look_dir() -> Vector3:
	return (look_dir_reference.global_position - cameraHandler.global_position)

func dash() -> void:
	if !current_dash >= 1.0:
		print("not enough dash charges")
		return
	if dash_timer > 0.0:
		print("dash spam")
		#velocity -= velocity * 0.5
		return
	current_dash -= 1.0
	dash_timer = 1.0
	velocity_at_dash_start = velocity
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var input_vertical = 0.0
	if Input.is_action_pressed("jump"):
		input_vertical += 1.0
	if Input.is_action_pressed("crouch"):
		input_vertical -= 1.0
	var direction = (graphics.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	#if !is_on_floor():
		#direction = (cameraHandler.global_transform.basis * Vector3(input_dir.x, input_vertical, input_dir.y)).normalized()
	
	if !direction:
		direction = Vector3(0.0,-1.0,0.0)
	dash_vel = direction
	print(direction)
	graphics.air_dash(direction)

func air_jump() -> void:
	if !air_jumps > 0:
		print("cant airjump more than " + str(max_air_jumps) + " times")
		return
	if !current_dash >= 1.0:
		print("not enough dash charges")
		return
	current_dash -= 1.0
	air_jumps -= 1
	velocity.y = jump_strength
	graphics.air_dash(Vector3.UP)
	#if !current_dash >= 1.0:
		#print("not enough dash charges")
		#return
	#current_dash -= 1.0
	##dash_timer = 1.0
	##dash_vel = Vector3.UP
	#velocity.y = jump_strength
	#graphics.air_dash(Vector3.UP)

func update_tooltip() -> void:
	var text = interaction_sightline.get_tooltip()
	Global.tooltip(text)
	pass

@export_group("sun_sickness")
@export var sun_sickness_change_speed:float = 1.0;
var sun_tick_damage_timer = 0.0
func update_sun_sickness(delta) -> void:
	if PlayerInformation.world_time < 0.5:
		graphics.shiver(delta)
	
	var sun_p = $sunlight_check.in_sunlight_pecentage()
	$Label.text = "sunlight : " + str(sun_p)
	var sickness = PlayerInformation.sun_sickness
	
	sickness += delta*sun_p*sun_sickness_change_speed
	if sun_p == 0.0:
		sickness -= delta*0.4*sun_sickness_change_speed
	sickness = clamp(sickness,0.0,1.0)
	PlayerInformation.sun_sickness = sickness
	if sickness == 1.0:
		sun_tick_damage_timer += delta
		if sun_tick_damage_timer > 0.25:
			sun_tick_damage_timer -= 0.25
			PlayerInformation.take_damage(1,Global.damage_types.FIRE)
		pass
	
	#var m = $graphics/cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/bodyMin_005.get_active_material(0)
	#m.set("shader_parameter/day_color_power",sun_p)
	
	
	$Label.text += ", sun_sickness : " + str(sickness)
	
	$sunlight_indicator.rotation = $sunlight_check.get_sun_rotation()#+Vector3(PI*0.5,0.0,0.0)
	$sunlight_indicator.visible = sun_p > 0.0
	$sunlight_indicator/MeshInstance3D.mesh.material.set("shader_parameter/albedo",Color("e6c0a9")*sun_p)
	if sun_p > 0.0:
		if !$sunlight_indicator/AudioStreamPlayer.playing:
			$sunlight_indicator/AudioStreamPlayer.play()
		$sunlight_indicator/AudioStreamPlayer.volume_db = lerp($sunlight_indicator/AudioStreamPlayer.volume_db, remap(sun_p,0.0,1.0,-40.0,0.0),delta*4.0)
	else:
		$sunlight_indicator/AudioStreamPlayer.volume_db = lerp($sunlight_indicator/AudioStreamPlayer.volume_db, -80.0 ,delta*8.0)

func _process(delta):
	if drawing_bow:
		bow_draw_timer += delta
	update_sun_sickness(delta)
	update_tooltip()
	if combat_stance > 0.0:
		combat_stance -= delta
		if combat_stance < 0.0:
			combat_stance = 0.0
	if crouching:
		cameraHandler.position.y = lerp(cameraHandler.position.y, 1.12,delta*12.0)
	else:
		cameraHandler.position.y = lerp(cameraHandler.position.y, 1.65,delta*12.0)
	#if movement_scaling_anims.keys().has(anim.current_animation):
		#var speed = Vector2(velocity.x,velocity.z).length()
		#anim.speed_scale = (speed/movement_scaling_anims[anim.current_animation])*0.25 + 0.75
	#else:
		#anim.speed_scale = 1.0
	
	##timers and such
	if sprinting:# and Input.get_vector("left", "right", "up", "down"):
		sprinting_timer += delta
		#cameraHandler.position.y = lerp(cameraHandler.position.y, 1.4,delta*2.0)
	else:
		sprinting_timer = 0.0
		#cameraHandler.position.y = lerp(cameraHandler.position.y, 1.5,delta*4.0)
	
	if wall_run_cooldown > 0.0:
		wall_run_cooldown -= delta
		if wall_run_cooldown < 0.0:
			wall_run_cooldown = 0.0
	
	if current_dash < max_dash:
		current_dash += delta*dash_regen_speed
		if current_dash > max_dash:
			current_dash = max_dash
	if dash_timer > 0.0:
		dash_timer -= delta * dash_speed
		if dash_timer > 0.5:
			#var mult = -sin(dash_timer*PI+PI*0.75) #1 -> -1
			#velocity += dash_vel * mult * dash_distance * dash_speed * delta
			velocity += dash_vel * dash_distance * dash_speed * delta
		else:
			velocity -= velocity*delta*dash_speed * dash_distance * dash_end_friction
			velocity -= (velocity-velocity_at_dash_start) * delta* dash_speed * dash_end_friction
		
		
		##graphics changes
		cameraHandler.position.y = lerp(cameraHandler.position.y, desired_CH_height, delta*8.0)
		cameraHandler.rotation.z = lerp(cameraHandler.rotation.z, desired_CH_rotation_z, delta*8.0)

func get_movement_anim(movement : String) -> String:
	var held_item_data = PlayerInformation.get_held_item_data()
	match movement:
		"idle":
			if held_item_data == []:
				if combat_stance > 0.0:
					return "idle_empty_shown"
				else:
					return "idle_empty_shown"
			else:
				match held_item_data[Items.INDEX_ANIMATIONS]:
					Items.animation.BREAD_ANIM:
						return "idle_holding_bread-metarig_001"
					Items.animation.SWORD_ANIM:
						return "idle_holding_sword"
					Items.animation.GUN_ANIM:
						return "idle_holding_gun"
					Items.animation.HAMMER_ANIM:
						return "idle_holding_hammer"
					Items.animation.BOW_ANIM:
						if drawing_bow:
							return "idle_holding_bow_drawn"
						elif bow_loaded:
							return "idle_holding_bow_loaded"
						else: return "idle_holding_bow_empty"
					_:
						return "idle_holding_bread-metarig_001"
		"sprinting":
			if held_item_data == []:
				#return "idle_empty_shown"
				return "run_empty-metarig_001"
			else:
				match held_item_data[Items.INDEX_ANIMATIONS]:
					Items.animation.BREAD_ANIM:
						return "run_holding_bread"
					Items.animation.SWORD_ANIM:
						return "run_holding_sword_fancifully"
						#return "idle_holding_sword"
					Items.animation.GUN_ANIM:
						return "run_holding_gun"
					Items.animation.HAMMER_ANIM:
						return "run_holding_hammer"
					Items.animation.BOW_ANIM:
						if drawing_bow:
							return "idle_holding_bow_drawn"
						elif bow_loaded:
							return "idle_holding_bow_loaded"
						else: return "idle_holding_bow_empty"
					_:
						return "run_holding_sword"
		"jump":
			return "jump_empty"
		"wall_run":
			var a_w_n = last_wall_run_normal * graphics.transform.basis
			if a_w_n.x > 0.0:
				return "wall_run_left_empty"
			else:
				return "wall_run_right_empty"
		"falling":
			if held_item_data == []:
				return "falling_empty"
			else:
				match held_item_data[Items.INDEX_ANIMATIONS]:
					Items.animation.SWORD_ANIM:
						return "idle_holding_sword"
					Items.animation.GUN_ANIM:
						return "idle_holding_gun"
					Items.animation.HAMMER_ANIM:
						return "idle_holding_hammer"
					Items.animation.BOW_ANIM:
						if drawing_bow:
							return "idle_holding_bow_drawn"
						elif bow_loaded:
							return "idle_holding_bow_loaded"
						else: return "idle_holding_bow_empty"
					_:
						return "falling_holding_bread"
		"vault":
			if held_item_data == []:
				return "vault_empty"
			else:
				match held_item_data[Items.INDEX_ANIMATIONS]:
					Items.animation.BREAD_ANIM:
						return "vault_holding_bread"
					_:
						return "vault_empty"
		"walk":
			if held_item_data == []:
				return "idle_empty_shown"
			else:
				match held_item_data[Items.INDEX_ANIMATIONS]:
					Items.animation.BREAD_ANIM:
						return "idle_holding_bread-metarig_001"
					Items.animation.SWORD_ANIM:
						return "idle_holding_sword"
					_:
						return "idle_holding_bread-metarig_001"
		_:
			return "idle_empty"

var action_animations = [
	"eat_bread",
	"drop_bread",
	"jump_empty",
	"vault_empty",
	"vault_holding_bread",
	"draw_bread_fancifully",
	"draw_bread",
	"draw_sword_fancifully",
	"swing_sword_2",
	"swing_sword_1",
	"punch_empty_1",
	"punch_empty_2",
	"drop_bread",
	"draw_gun",
	"shoot_gun",
	"draw_hammer",
	"swing_hammer",
	"draw_bow",
	"shoot_bow_end_full",
	"shoot_bow_start",
	"load_bow",
]

var movement_scaling_anims = {
	"run_empty" : 7.5,
}

func play_anim(key: String, interrupting: bool = false, blend_time: float = 0.2, speed : float = 1.0):
	if anim.current_animation == key:
		anim.speed_scale = speed
		return
	if action_animations.has(key): #action animations always interrupt action animations
		anim.play(key,blend_time, speed)
		#print("playing anim " + key)
		return
	if action_animations.has(anim.current_animation) and !interrupting:
		return
	anim.play(key,blend_time,speed)
	#print("playing anim " + key)
	pass

var last_wall_normal = Vector3.ZERO
@export var wall_jump_max_latency = 0.1
var wall_jump_latency_timer = 0.0

@export var sprint_animation_speed_mult = 1.0 #for syncing animation to game_feel
func can_wall_jump() -> bool:
	if is_on_wall() or wall_jump_latency_timer > 0.0:
		return true
	return false

var airborn = false
var coyote_time:float = 0
@export var max_coyote_time :float = 0.1
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if !airborn:
			if coyote_time > max_coyote_time:
				airborn = true
				#become airborn
			else:
				coyote_time += delta
		#combat_stance = 3.5
		if combat_stance == 0.0:
			combat_stance = 1.0
		if !dash_timer > 0.0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= velocity.y * (1.0 - abs(dash_vel.y)) * delta
	else:
		coyote_time = 0.0
		if airborn:
			airborn = false
			#landed
			graphics.land()
		air_jumps = max_air_jumps
		wall_run_timer = 0.0

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if !airborn:#is_on_floor():
			velocity.y = jump_strength
			graphics.jump()
			airborn = true
			#play_anim(get_movement_anim("jump"))
		elif can_wall_jump():
			var normal = last_wall_normal
			if Input.is_action_pressed("up") and can_vault() and ! vaulting:
				vaulting = true
				graphics.vault()
				play_anim(get_movement_anim("vault"))
			else: #wall_jump
			#lunge()
				velocity.y = jump_strength
				velocity += get_look_dir()*clamp(velocity.length(), 0.0, jump_strength*0.25)
				velocity += normal * jump_strength
				graphics.wall_jump(normal,last_wall_groups)
				
				wall_run_timer *= 0.75
				wall_run_cooldown = 0.2
		else:
			air_jump()
	
	# Handle vault
	if Input.is_action_pressed("up") and !is_on_floor() and Input.is_action_pressed("jump"):
		if can_vault() and !vaulting:
			vaulting = true
			graphics.vault()
			play_anim(get_movement_anim("vault"))
	
	if Input.is_action_just_pressed("down"):
		vaulting = false
	
	if vaulting:
		var dif = (desired_vault_pos - global_position)
		var dir = dif.normalized()
		velocity = dir * 5.0
		if dif.length() < 0.1:
			vaulting = false
	
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (graphics.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and !dash_timer > 0.0 and !vaulting:
		if !airborn:#is_on_floor():
			if crouching or aiming_down_sights:
				play_anim(get_movement_anim("idle"))
				velocity.x += ((crouch_speed * direction.x) - velocity.x) * delta * acceleration
				velocity.z += ((crouch_speed * direction.z) - velocity.z) * delta * acceleration
			elif sprinting:
				graphics.running(delta, velocity)
				var speed = Vector2(velocity.x,velocity.z).length()
				var a_speed = clamp((speed/sprint_speed),0.9,10.0)*sprint_animation_speed_mult*graphics.running_speed_mult
				#play_anim(get_movement_anim("sprinting"),false, 0.5, a_speed)
				if input_dir.y < 0.0:
					#holding forward
					play_anim(get_movement_anim("sprinting"),false, 0.5, a_speed)
				else:
					play_anim(get_movement_anim("idle"))
				if !speed > sprint_speed:
					#play_anim(get_movement_anim("walk"))
					velocity.x += ((sprint_speed * direction.x) - velocity.x) * delta * acceleration
					velocity.z += ((sprint_speed * direction.z) - velocity.z) * delta * acceleration
				else:
					#play_anim(get_movement_anim("sprinting"))
					var add_vel = (speed*direction - velocity) * acceleration
					var add_vel_length = add_vel.length()
					var add_vel_dir = add_vel.normalized()
					if add_vel_length > max_floor_slow_per_second:
						add_vel_length = max_floor_slow_per_second
					velocity.x += add_vel_length * add_vel_dir.x * delta
					velocity.z += add_vel_length * add_vel_dir.z * delta
					velocity -= velocity*delta*2.0 #a little friction -> changed to a lot of friction (old = *0.05)
					#velocity.x += (speed*direction.x - velocity.x) * delta * acceleration
					#velocity.z += (speed*direction.z - velocity.z) * delta * acceleration
			else:
				graphics.walking(delta, velocity)
				play_anim(get_movement_anim("idle"))
				velocity.x += ((walk_speed * direction.x) - velocity.x) * delta * acceleration
				velocity.z += ((walk_speed * direction.z) - velocity.z) * delta * acceleration
		elif sprinting and is_on_wall() and !wall_run_cooldown > 0.0:
			#wallrunning
			wall_run_timer += delta
			var wr_power = clamp((1.0 - (wall_run_timer/max_wall_run_duration)), 0.0 , 1.0)
			var h_speed = Vector2(velocity.x,velocity.z).length()
			if h_speed < min_wallrun_speed:
				wr_power -= (1.0 - (h_speed / min_wallrun_speed))
			velocity.y += gravity * delta * wr_power
			velocity.y = lerp(velocity.y, 0.0, delta * wr_power*2.0)
			var w_n = get_wall_normal()
			last_wall_run_normal = w_n
			play_anim(get_movement_anim("wall_run"))
			graphics.wall_running(w_n, delta, wr_power, get_slide_collision(0).get_collider(0).get_groups())
			velocity -= w_n * delta * velocity.length() * 25.0 * wr_power * Vector3(1.0,0.0,1.0) #stick to wall
			velocity = update_velocity_air(direction,velocity,delta)
			#velocity.y += (clamp(get_look_dir().y, -0.5, 0.5) * wr_power) *delta *acceleration
		else:
			velocity = update_velocity_air(direction, velocity, delta)
			play_anim(get_movement_anim("falling"))
			graphics.airborn(velocity, delta)
	elif is_on_floor() and !dash_timer > 0.0:
		play_anim(get_movement_anim("idle"))
		graphics.idle(delta)
		if true:#!sprinting or velocity.length() < 1.0:
			var speed_to_lose = Vector2(velocity.x,velocity.z).length() * floor_friction
			var friction_dir = velocity.normalized()
			if speed_to_lose > max_floor_slow_per_second:
				speed_to_lose = max_floor_slow_per_second
			if crouching and speed_to_lose > max_crouch_slow_per_second:
				speed_to_lose = max_crouch_slow_per_second
			velocity.x -= speed_to_lose*friction_dir.x*delta
			velocity.z -= speed_to_lose*friction_dir.z*delta
		else:
			velocity -= velocity.normalized() * delta 
		#velocity.x -= velocity.x * delta * floor_friction
		#velocity.z -= velocity.z * delta * floor_friction
	elif !dash_timer > 0.0:
		play_anim(get_movement_anim("falling"))
		graphics.airborn(velocity, delta)
	
	if !dash_timer > 0.0:
		velocity = velocity.normalized() * clamp(velocity.length(), 0.0, 50.0)
	
	
	move_and_slide()
	update_player_information()
	if is_on_wall():
		wall_jump_latency_timer = wall_jump_max_latency
		last_wall_normal = get_wall_normal()
		last_wall_groups = get_slide_collision(0).get_collider(0).get_groups()
	else:
		wall_jump_latency_timer -= delta

func update_velocity_air(wishdir : Vector3, vel : Vector3, frame_time : float) -> Vector3:
	#apply friction
	#vel.x -= vel.x/4 * frame_time
	#vel.y -= vel.y/4 * frame_time
	#vel.z -= vel.z/4 * frame_time
	
	#var current_speed = vel.dot(wishdir)
	
	#var current_speed = abs(sqrt(((vel.x * vel.x) + (vel.z * vel.z))))
	var current_speed = Vector2(vel.x, vel.z).dot(Vector2(wishdir.x, wishdir.z))
	
	var add_speed = (sprint_speed - current_speed)
	if add_speed < 0:
		add_speed = 0
	elif add_speed > air_acceleration * frame_time: #should be accaleration/4 but i made it more fun :D
		add_speed = air_acceleration * frame_time
	return vel + add_speed * wishdir

func tp(pos : Vector3, rot : Vector2, vel := velocity) -> void:
	position = pos
	cameraHandler.rotation.x = rot.x
	graphics.rotation.y = rot.y
	velocity = vel
	pass

func _on_successful_interaction(info : Array) -> void:
	var tag = info[0]
	var data = info[1]
	match tag:
		Global.interact_returns.PICKUP_ITEM:
			attempt_loose_item_pickup(data)
		Global.interact_returns.ENTER_DOOR:
			enter_door(data)
		Global.interact_returns.SLEEP_IN_BED:
			sleep_in_bed(data)

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

#weapon and item based info
var bow_loaded : bool = false #if your bow has an arrow knocked (for animations mainly)
var loaded_arrow_key : StringName = "basic_arrow"
var bow_draw_timer : float = 0.0 #how long your bow has been drawn
var drawing_bow : bool = false #if your drawing it back
var held_item_attributes: Dictionary = {}

func use_held_item(special = false):
	var data = PlayerInformation.get_held_item_data()
	if data.is_empty():
		print("punched")
		combat_stance = 3.5
		if special:
			play_anim("punch_empty_2")
		else:
			play_anim("punch_empty_1")
		return
	var type = data[3]
	match type:
		Items.type.FOOD:
			if !special:
				if PlayerInformation.food >= PlayerInformation.max_food:
					print("cant eat any more you are full")
					return
				anim.play("eat_bread")
			else:
				play_anim("punch_empty_2")
		Items.type.SWORD:
			var sword_data = data[Items.INDEX_DATA]
			var attack_speed = sword_data[0]
			var damage_amount = sword_data[1]
			var damage_type = sword_data[2]
			var vfx_method_name = sword_data[3]
			print("swung sword")
			play_held_item_sound("swing", attack_speed)
			weapon_node.slash_close(damage_amount,damage_type,vfx_method_name,special,attack_speed)
			#velocity += get_look_dir()
			if !dash_timer > 0.0 and is_on_floor():
				dash_timer = 0.75
				velocity_at_dash_start = velocity
				dash_vel = get_look_dir()
			if special:
				play_anim("swing_sword_2", true, 0.0, attack_speed)
			else:
				play_anim("swing_sword_1", true, 0.0, attack_speed)
		Items.type.GUN:
			play_held_item_sound("shoot")
			play_anim("shoot_gun",true,0.0)
			graphics.shoot()
			shoot_held_item()
		Items.type.HAMMER:
			play_anim("swing_hammer",true,0.0)
			print("swung hammer")
		Items.type.BOW:
			start_using_bow(special)

func release_held_item(special = false):
	var data = PlayerInformation.get_held_item_data()
	if data.is_empty():
		print("punched")
		combat_stance = 3.5
		if special:
			play_anim("punch_empty_2")
		else:
			play_anim("punch_empty_1")
		return
	var type = data[3]
	match type:
		Items.type.SWORD:
			if special:
				print("stopped blocking")
		Items.type.GUN:
			if special:
				print("stopped aiming_down_sights")
		Items.type.BOW:
			if !special:
				if drawing_bow:
					shoot_bow()

func start_using_bow(special : bool) -> void:
	if !special:
		if bow_loaded:
			play_anim("shoot_bow_start",true,0.0)
			aiming_down_sights = true #disables movement stuff, slows, and zooms slightly
			drawing_bow = true
			bow_draw_timer = 0.0
		else:
			load_bow()

func load_bow() -> void:
	var quiver_item = PlayerInformation.inventory[PlayerInformation.get_backpack_index()+1]
	if !quiver_item.is_empty():
		var arrow_item = []
		for i in range(0,quiver_item[1]["inventory"].size()):
			var a = quiver_item[1]["inventory"][i]
			if !a.is_empty():
				arrow_item = Items.list[a[0]]
				quiver_item[1]["inventory"][i] = []
				loaded_arrow_key = a[0]
				break
		if arrow_item.is_empty():
			print("quiver empty checking inventory")
			for i in range(0,PlayerInformation.inventory.size()):
				var a = PlayerInformation.get_item_data(i)
				if !a.is_empty():
					if a[Items.INDEX_EQUIPMENT_ID] == Items.equipment_id.ARROW:
						arrow_item = a
						loaded_arrow_key = PlayerInformation.inventory[i][0]
						PlayerInformation.inventory[i] = []
						break
			if arrow_item.is_empty():
				print("no ammo found in inventory")
				return
		var arrow_graphics = load(arrow_item[Items.INDEX_MODEL]).instantiate()#load("res://assets/items/arrows/arrow_ph.glb").instantiate()
		#^^^ get frow quiver aka held_item_attributes["inventory"]
		prop_1_handler.add_child(arrow_graphics)
		prop_item_models.append(arrow_graphics)
		play_anim("load_bow", true, 0.0)
		bow_loaded = true
	pass

func shoot_bow():
	if bow_draw_timer < 0.1:
		print("bow spam, canceling shot")
		aiming_down_sights = false
		drawing_bow = false
		play_anim("idle_holding_bow_loaded", true)
		return
	
	var bow_info = PlayerInformation.get_held_item_data()
	var bow_data = bow_info[Items.INDEX_DATA]
	var min_draw_time = bow_data[0]
	
	clear_item_props()
	
	
	print("shot bow")
	aiming_down_sights = false
	drawing_bow = false
	bow_loaded = false
	if bow_draw_timer > min_draw_time:
		print("perfect draw shooting accurately")
		play_anim("shoot_bow_end_full")
		var dir = get_look_dir()
		var pos = look_dir_reference.global_position
		Global.spawn_entity("basic_arrow",pos,dir*bow_data[3],[loaded_arrow_key,self])
	else:
		print("inadequate draw, misfire")
		play_anim("shoot_bow_end_full")
		var dir = get_look_dir()
		var pos = look_dir_reference.global_position
		Global.spawn_entity("basic_arrow",pos,dir*bow_data[3]*0.1,[loaded_arrow_key,self])

func shoot_held_item() -> void:
	var data = PlayerInformation.get_held_item_data()[Items.INDEX_DATA]
	var damage_type = data[2]
	var damage_amount = data[1]
	weapon_node.shoot_bullet_hitscan(damage_amount,damage_type)

func update_player_information() -> void:
	PlayerInformation.position = position
	PlayerInformation.rotation = Vector2(cameraHandler.rotation.x, graphics.rotation.y)
	PlayerInformation.velocity = velocity
	PlayerInformation.crouching = crouching
	PlayerInformation.sprinting = sprinting
	PlayerInformation.max_dash = max_dash
	PlayerInformation.current_dash = current_dash

var desired_vault_pos: Vector3 = Vector3.ZERO
var vaulting: bool = false

func can_vault() -> bool:
	if $graphics/vault_check/RayCast3D.is_colliding():
		desired_vault_pos = $graphics/vault_check/RayCast3D.get_collision_point()
		return true
	return false

func _on_anim_finished(key) -> void:
	match key:
		"eat_bread":
			consume_held_item()
		"swing_sword_1":
			swing_held_item()
		"swing_sword_2":
			swing_held_item()
		"load_bow":
			if Input.is_action_pressed("use_item"):
				print("bow loaded continuing shot")
				use_held_item()
	if action_animations.has(key):
		#anim.play(get_movement_anim("idle"))
		pass
	else:
		anim.play(key)
	pass

##functions to be called in animations
func consume_held_item() -> void:
	var data = PlayerInformation.get_held_item_data()
	print("ate " + str(data[0]))
	#var sound = PlayerInformation.get_held_item_sound("eat")
	#print("played sound * " + sound + " *")
	play_held_item_sound("bite")
	PlayerInformation.set_inventory_slot(PlayerInformation.held_item_index, [])
	PlayerInformation.eat_food(data[4])

func swing_held_item() -> void:
	var data = PlayerInformation.get_held_item_data()
	var type_data = data[Items.INDEX_DATA]
	print(type_data[1])
	
	pass

func _on_dropped_item(_data, _pos) -> void:
	#anim.play("drop_bread")
	print("dropped_item")
	pass

func _on_item_drop_attempt(index : int) -> void:
	var data = PlayerInformation.steal_inventory_slot(index)
	#PlayerInformation.emit_signal("dropped_item", data, look_dir_reference.global_position)
	#(data, pos, rotation, stuck, velL , velR) -> void:
	Global.drop_item(data,held_item_handler.global_position,held_item_handler.global_rotation,false,velocity)
	PlayerInformation.emit_signal("update_held_item")
	play_anim("drop_bread", true, 0.0)

var held_item_models = []
var prop_item_models = []
func update_held_item_graphics() -> void:
	aiming_down_sights = false
	bow_loaded = false
	for old in held_item_models:#.get_children(false):
		old.queue_free()
	for old_p in prop_item_models:
		old_p.queue_free()
	held_item_models = []
	prop_item_models = []
	var item_data = PlayerInformation.get_held_item_data()
	if item_data == []:
		play_anim(get_movement_anim("idle"),true)
		#interupts drop animation :/
		return
	held_item_attributes = PlayerInformation.inventory[PlayerInformation.held_item_index][1]
	print(held_item_attributes)
	#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
	var path = item_data[Items.INDEX_MODEL]
	var g = load(path).instantiate()
	if item_data[Items.INDEX_HAS_DEFORMATIONS]:
		skeleton.add_child(g)
	else:
		held_item_handler.add_child(g)
	held_item_models += [g]
	play_held_item_sound("pickup")
	#var sound = PlayerInformation.get_held_item_sound("pickup")
	#if sound == "":
		#print("item had no pickup sound :/")
	#else:
		##print("playing sound  * " + sound + " *")
		#item_sounds.stream = load(sound)
		#item_sounds.play()
	
	var anim = item_data[Items.INDEX_ANIMATIONS]
	match anim: #for drawing animation
		Items.animation.BREAD_ANIM:
			play_anim("draw_bread_fancifully", true, 0.0)
		Items.animation.SWORD_ANIM:
			play_anim("draw_sword_fancifully", true, 0.0)
		Items.animation.GUN_ANIM:
			play_anim("draw_gun",true,0.0)
		Items.animation.HAMMER_ANIM:
			play_anim("draw_hammer",true,0.0)
		Items.animation.BOW_ANIM:
			play_anim("draw_bow",true,0.0)
		_:
			play_anim("draw_bread", true, 0.0)

func clear_item_props() -> void:
	for old_p in prop_item_models:
		old_p.queue_free()
	prop_item_models = []

func play_held_item_sound(key : String, speed: float = 1.0) -> void:
	var s = PlayerInformation.get_held_item_sound(key)
	if s == "":
		return
	item_sounds.pitch_scale = speed
	item_sounds.stream = load(s)
	item_sounds.play()
	
func perform_action(key : String) -> void:
	play_anim(key, true, 0.2, 1.0)
	pass

func _on_projectile_hit_enemy(p_dam_amount:float,p_dam_type:int,entity_node):
	print("recieved projectile hit info")
	pass

