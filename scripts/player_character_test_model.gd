extends CharacterBody3D


const SPEED = 1.3
const JUMP_VELOCITY = 4.5
@export var mouse_sensitivity : float = 2.0
@onready var cameraHandler = $body/camera_handler
@onready var graphics = $graphics
@onready var body = $body

##gameplay
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var sprinting:bool = false
var crouching:bool = false

##display
var graphics_desired_rot:float = 0.0

func _input(event):
	if event is InputEventMouseMotion and !Global.in_game_mouse:
		var TempRotation = rotation.x - event.relative.y /1000 * mouse_sensitivity
		cameraHandler.rotation.x += TempRotation
		cameraHandler.rotation.x = clamp(cameraHandler.rotation.x, -1.25, 1.5)
		body.rotation.y -= event.relative.x /1000 * mouse_sensitivity
	
	if Input.is_action_just_pressed("sprint") and Input.is_action_pressed("up"):
		sprinting = true
	if Input.is_action_just_released("sprint") or Input.is_action_just_released("up"):
		sprinting = false
	if Input.is_action_just_pressed("crouch"):
		crouching = true
	if Input.is_action_just_released("crouch"):
		crouching = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		graphics_desired_rot = body.rotation.y
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

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

var max_torso_twist = PI*0.4

func _process(delta):
	$graphics/player_01_wip_rig_test/AnimationPlayer.play("walkF")
	head_bob(delta,0.05,1.6667*PI*1.5)
	
	var g_rot_dif = (graphics.rotation.y - body.rotation.y)
	if abs(g_rot_dif) > max_torso_twist:
		graphics_desired_rot = body.rotation.y
	graphics.rotation.y = lerp_angle(graphics.rotation.y, graphics_desired_rot, delta*4.0)
	graphics.rotation.y = clamp(graphics.rotation.y, body.rotation.y - max_torso_twist, body.rotation.y + max_torso_twist)
	
	
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
	

func tp(pos : Vector3, rot : Vector2, vel := velocity) -> void:
	position = pos
	cameraHandler.rotation.x = rot.x
	graphics.rotation.y = rot.y
	velocity = vel
	pass

@onready var camera = $body/camera_handler/Camera3D
var head_bob_timer : float = 0.0
func head_bob(delta : float,amplitude : float,frequency : float) -> void:
	head_bob_timer += delta * frequency
	if head_bob_timer > PI*4.0:
		head_bob_timer -= PI*4.0
	
	camera.position.y = sin(head_bob_timer)*amplitude
	camera.position.x = sin(head_bob_timer*0.5+PI*0.5)*amplitude




