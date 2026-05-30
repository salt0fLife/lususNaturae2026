extends PlayerBase


@onready var graphics = $graphics
@onready var hipPivot = $graphics/hipPivot
@onready var interaction_sightline = $graphics/cameraHandler/interaction_sightline
@onready var cameraHandler = $graphics/cameraHandler

func _ready():
	interaction_sightline.connect("interacted", _on_successful_interaction)
	pass

var sprinting:bool = false
var crouching:bool = false
var sliding:bool = false
var sliding_min_speed:float = 5.0

func _input(event):
	if event is InputEventMouseMotion and !Global.in_game_mouse:
		var TempRotation = rotation.x - event.relative.y /1000 * MouseSensitivity
		cameraHandler.rotation.x += TempRotation
		cameraHandler.rotation.x = clamp(cameraHandler.rotation.x, -1.25, 1.5)
		graphics.rotation.y -= event.relative.x /1000 * MouseSensitivity
		hipPivot.rotation.y += event.relative.x /1000 * MouseSensitivity
		hipPivot.rotation.y = clamp(hipPivot.rotation.y, -0.75,0.75)
	
	if Input.is_action_just_pressed("sprint") and Input.is_action_pressed("up"):
		sprinting = true
	if Input.is_action_just_released("sprint") or Input.is_action_just_released("up"):
		sprinting = false
	if Input.is_action_just_pressed("crouch"):
		crouching = true
	if Input.is_action_just_released("crouch"):
		crouching = false

var walljumps: int = 0
func jump():
	if performing_action:
		performing_action = false
		print("movement ended action")
		return
	if is_on_floor():
		velocity.y += JUMP_VELOCITY
	elif is_on_wall():
		if walljumps == 0:
			velocity.y = 0
		walljumps += 1
		var n = get_wall_normal()
		velocity += n * JUMP_VELOCITY
		velocity.y += JUMP_VELOCITY

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		if is_on_wall() and crouching:
			velocity.y -= velocity.y * delta * 2.0
	elif crouching and (velocity.length()+velocity.dot(get_floor_normal())*sliding_min_speed*0.5 > sliding_min_speed):
		walljumps = 0
		sliding = true
		var norm = get_floor_normal()
		velocity.x += norm.x*delta*25.0
		velocity.z += norm.z*delta*25.0
		velocity -= velocity * delta*(norm.y*norm.y)*0.5
	else:
		walljumps = 0
		sliding = false
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (graphics.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if performing_action and direction:
		performing_action = false
		print("movement ended action")
	
	if is_on_floor():
		if direction:
			if !sliding:
				if crouching:
					velocity.x = lerp(velocity.x , direction.x * SPEED*0.5, delta*8.0)
					velocity.z = lerp(velocity.z , direction.z * SPEED*0.5, delta*8.0)
				else:
					velocity.x = lerp(velocity.x , direction.x * SPEED, delta*8.0)
					velocity.z = lerp(velocity.z , direction.z * SPEED, delta*8.0)
				hipPivot.rotation.y = lerp(hipPivot.rotation.y,0.0,8.0*delta)
				play_leg_animation("walk")
			else:
				velocity = update_velocity_air(direction*0.5, velocity, delta)
		else:
			if !sliding:
				velocity.x = lerp(velocity.x , 0.0, delta*8.0)
				velocity.z = lerp(velocity.z , 0.0, delta*8.0)
			var c_a = $legAnimationPlayer.current_animation
			if c_a != "recenter_from_right" and c_a != "recenter_from_left":
				if hipPivot.rotation.y == -0.75:
					hipPivot.rotation.y = 0.0
					play_leg_animation("recenter_from_right", 0.0)
				elif hipPivot.rotation.y == 0.75:
					hipPivot.rotation.y = 0.0
					play_leg_animation("recenter_from_left", 0.0)
				elif $legAnimationPlayer.current_animation != "recenter_from_left" and $legAnimationPlayer.current_animation != "recenter_from_right":
					play_leg_animation("idle")
			else:
				play_leg_animation("idle")
	elif direction:
		hipPivot.rotation.y = lerp(hipPivot.rotation.y,0.0,20.0*delta)
		velocity = update_velocity_air(direction, velocity, delta)
	move_and_slide()
	update_player_information()

func update_player_information() -> void:
	PlayerInformation.position = position
	PlayerInformation.rotation = Vector2(cameraHandler.rotation.x, graphics.rotation.y)
	PlayerInformation.velocity = velocity
	PlayerInformation.crouching = crouching
	PlayerInformation.sprinting = sprinting

func update_velocity_air(wishdir : Vector3, vel : Vector3, frame_time : float) -> Vector3:
	#apply friction
	vel.x -= vel.x/4 * frame_time
	vel.y -= vel.y/4 * frame_time
	vel.z -= vel.z/4 * frame_time
	
	#var current_speed = vel.dot(wishdir)
	
	#var current_speed = abs(sqrt(((vel.x * vel.x) + (vel.z * vel.z))))
	var current_speed = Vector2(vel.x, vel.z).dot(Vector2(wishdir.x, wishdir.z))
	
	var add_speed = (maxSpeed - current_speed)
	if add_speed < 0:
		add_speed = 0
	elif add_speed > acceleration * frame_time: #should be accaleration/4 but i made it more fun :D
		add_speed = acceleration * frame_time
	return vel + add_speed * wishdir

func play_leg_animation(key : String, smoothing := 0.15) -> void:
	if $legAnimationPlayer.current_animation != key:
		$legAnimationPlayer.play(key,smoothing)

func _on_successful_interaction(info : Array) -> void:
	var tag = info[0]
	var data = info[1]
	match tag:
		Global.interact_returns.PICKUP_ITEM:
			attempt_loose_item_pickup(data)

func tp(pos : Vector3, rot : Vector2, vel := velocity) -> void:
	position = pos
	cameraHandler.rotation.x = rot.x
	graphics.rotation.y = rot.y
	velocity = vel
	pass

func can_fall_asleep(): #not hungry and in sleep area
	if PlayerInformation.food < PlayerInformation.min_sleep_food:
		print("to hungry to sleep")
		return false
	var hits = $special_area_sense.get_overlapping_areas()
	for i in hits:
		if i.is_in_group("sleep_area"):
			print("can sleep here")
			return true
	print("cannot sleep here")
	return false

signal fall_asleep
var performing_action = false
var action = ""

func perform_action(tag : String) -> void:
	print("performing action " + str(tag))
	action = tag
	performing_action = true
	match tag:
		"rest":
			has_checked_sleep = false
			sleep_timer = time_to_sleep
		"sleep":
			sleep_timer = 0.5
	pass

var time_to_sleep = 0.5
var sleep_timer = 0.0
var has_checked_sleep = false

var limb_matching = "default" #having holding gun point where your looking etc

var graphics_dir = Vector2.ZERO
func _process(delta):
	#var input_dir = Input.get_vector("left", "right", "down", "up")
	#graphics_dir = lerp(graphics_dir, input_dir, delta*4.0)
	#$graphics/AnimationTree.set("parameters/blend_position", graphics_dir)
	#
	if position.y < -50.0:
		PlayerInformation.die()
	
	var camera_pos = 1.5
	if crouching and is_on_floor():
		camera_pos = 1.125
	
	cameraHandler.position.y = lerp(cameraHandler.position.y, camera_pos, delta*8.0)
	
	if is_on_floor() and !sliding:
		head_bob(delta,0.05,1.6667*PI*1.5)
	else:
		head_bob(delta,0.0,1.6667*PI*1.5)
	
	match limb_matching: #code based animation stuff
		_: #default
			
			pass
	
	if performing_action:
		match action:
			"rest":
				sleep_timer -= delta
				if sleep_timer < 0.0 and !has_checked_sleep:
					has_checked_sleep = true
					if can_fall_asleep():
						perform_action("sleep")
			"sleep":
				sleep_timer -= delta
				if sleep_timer < 0.0:
					emit_signal("fall_asleep")
					performing_action = false
			"sit":
				pass
			_:
				performing_action = false


@onready var anim = $legAnimationPlayer
func play_animation(key : String) -> void: 
	match key: #limb matching stuff
		_:
			limb_matching = "default"
	
	match key: #plays animation or transition animation, makes look good
		_:
			#defaults to a pose
			pass
	pass


@onready var camera = $graphics/cameraHandler/Camera3D
var head_bob_timer : float = 0.0
func head_bob(delta : float,amplitude : float,frequency : float) -> void:
	head_bob_timer += delta * frequency
	if head_bob_timer > PI*4.0:
		head_bob_timer -= PI*4.0
	
	camera.position.y = sin(head_bob_timer)*amplitude
	camera.position.x = sin(head_bob_timer*0.5+PI*0.5)*amplitude
	#camera.position.z = sin(head_bob_timer*0.5+PI*0.5)*amplitude*0.5

func _on_used_item(data : Array) -> void:
	
	pass
