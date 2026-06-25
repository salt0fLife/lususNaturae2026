extends CharacterBody3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var state = "idle"

@onready var graphics = $graphics

@export var walking_speed = 1.5

func _physics_process(delta):
	# Add the gravity.
	if has_method(state):
		call(state, delta)
	else:
		printerr("invalid state of " + state)
		state = "idle"
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


func idle(delta):
	var target = PlayerInformation.position
	var dif = target - global_position
	if dif.length() < 11.0:
		state = "running_down"
	play_anim("idle_4L")
	pass

func running_down(delta):
	var target = PlayerInformation.position
	var dif = target - global_position
	velocity = lerp(velocity, dif.normalized() * walking_speed, delta * 4.0)
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dif.x,dif.z) - PI, delta*4.0)
	if dif.length() < 2.0:
		state = "retreat"
	#play_anim("walk_forward_2L")
	play_anim("walkF")
	

func retreat(delta):
	var target = PlayerInformation.position
	var dif = target - global_position
	velocity = lerp(velocity, -dif.normalized() * walking_speed, delta * 4.0)
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(velocity.x,velocity.z) - PI, delta*4.0)
	if dif.length() > 8.0:
		state = "circling"
	#play_anim("run_forward_4l")
	play_anim("walkF")

func circling(delta):
	var target = PlayerInformation.position
	var dif = target - global_position
	var dir = dif.normalized()
	dir = dir.rotated(Vector3.UP,PI*0.4) #angled in
	velocity = lerp(velocity, dir * walking_speed, delta * 4.0)
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dif.x,dif.z) - PI, delta*4.0)
	if dif.length() < 6.0:
		state = "running_down"
	if dif.length() > 10.0:
		state = "running_down"
	#play_anim("walk_forward_4L")
	play_anim("walkL")

func get_data() -> Array:
	return ["royal_guard", [position, velocity, graphics.rotation.y, state, "animation", 0.0]]

func set_data(data : Array):
	position = data[0]
	velocity = data[1]
	graphics.rotation.y = data[2]
	state = data[3]

func die():
	call_deferred("queue_free")

func play_anim(key : StringName) -> void:
	if $graphics/player_01_wip_rig_test/AnimationPlayer.current_animation == key:
		return
	$graphics/player_01_wip_rig_test/AnimationPlayer.play(key, 0.2)
	
	#if $graphics/wendigo_blockout/AnimationPlayer.current_animation == key:
		#return
	#$graphics/wendigo_blockout/AnimationPlayer.play(key, 0.2)
	#pass

var health = 100
func take_damage(amount, type):
	
	
	pass
