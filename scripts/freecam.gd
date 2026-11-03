extends Node3D
var velocity:Vector3 = Vector3.ZERO

@export var movement_speed = 5.0
@export var sprint_speed = 10.0
@export var damp = 0.9
@export var mouse_sensitivity = 2.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var cameraHandler = $cameraBase
@onready var camera_base = $cameraBase

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var vertical_input = 0.0
	if Input.is_action_pressed("jump"):
		vertical_input += 1.0
	if Input.is_action_pressed("crouch"):
		vertical_input -= 1.0
	var direction = (camera_base.transform.basis * Vector3(input_dir.x, vertical_input, input_dir.y)).normalized()
	var desired_speed = movement_speed
	if Input.is_action_pressed("sprint"):
		desired_speed = sprint_speed
	velocity += direction * desired_speed * delta
	velocity -= velocity * damp * delta
	position += velocity
	update_player_information()

func _input(event):
	if event is InputEventMouseMotion and !Global.in_game_mouse:
		var TempRotation = rotation.x - event.relative.y /1000 * mouse_sensitivity
		cameraHandler.rotation.x += TempRotation
		cameraHandler.rotation.x = clamp(cameraHandler.rotation.x, -1.5, 1.5) #formerly -1.25,1.5
		camera_base.rotation.y -= event.relative.x /1000 * mouse_sensitivity
		if camera_base.rotation.y > PI*64.0:
			camera_base.rotation.y -= PI*64.0
		elif camera_base.rotation.y < -PI*64.0:
			camera_base.rotation.y += PI*64.0

func tp(pos : Vector3, rot : Vector2, vel:=velocity) -> void:
	position = pos
	cameraHandler.rotation.x = rot.x
	camera_base.rotation.y = rot.y
	velocity = vel

func update_player_information() -> void:
	PlayerInformation.position = position
	PlayerInformation.rotation = Vector2(cameraHandler.rotation.x, camera_base.rotation.y)
	PlayerInformation.velocity = velocity
