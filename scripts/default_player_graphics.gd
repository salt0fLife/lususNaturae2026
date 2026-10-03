extends Node3D
@onready var camera = $cameraHandler/senses_camera
@onready var cameraHandler = $cameraHandler
@onready var hands = $cameraHandler/hands
@onready var floor_check = $floor_check

var camera_rot_vel : Vector3 = Vector3.ZERO
var hands_rot_vel : Vector3 = Vector3.ZERO
var hands_pos_vel : Vector3 = Vector3.ZERO
var hands_rot_big_motion_vel : Vector3 = Vector3.ZERO
@export var hands_return_power = 20.0
@export var hands_return_damp = 1.0
@export var hands_rot_return_power = 20.0
@export var hands_rot_return_damp = 1.0
@export var hands_rot_big_motion_power = 5.0
@export var hands_rot_big_motion_damp = 1.0
@export var hands_rot_lag_power = 1.0

@export var running_speed_mult = 1.0
@export var running_camera_drop = 0.01;

@onready var last_frame_camera_rot = Vector2(rotation.y, cameraHandler.rotation.x)
@onready var anim = $cameraHandler/fp_hands_wip/AnimationPlayer
var first_active_frame = false



var val = 0.0
var step = 0.0
func running(delta, velocity) -> void:
	var running_speed = Vector2(velocity.x,velocity.z).length()/7.0
	velocity = velocity*global_basis
	var dir = Vector2(velocity.x,velocity.z).normalized()
	var theta = atan2(dir.x,dir.y) + PI
	#legs.rotation.y = lerp_angle(legs.rotation.y, theta,delta * 16.0)
	#legs.rotation.y = clamp(legs.rotation.y, -PI*0.4,PI*0.4)
	
	camera_rot_vel.z -= dir.x*delta*0.05
	camera_rot_vel.x += dir.y*delta*0.05
	
	val += delta * 1.5 * running_speed_mult * running_speed
	var strength = 1.0
	if val > 1.0:
		val -= 1.0
		step = 0.0
	if val*2.0 > step:
		step += 1.0
		var c = floor_check.get_collider()
		if c!= null:
			step_sound(c.get_groups())
	
	camera.position.x += delta * sin(val*PI*2.0) * strength * 0.7
	camera.position.y += delta * sin((val*PI*4.0)+PI*0.5) * strength * 0.7
	camera.position.y -= running_camera_drop*delta
	camera.position.z -= running_camera_drop*delta
	hands.position.x += delta * sin(val*PI*2.0) * strength*0.5
	hands.position.y += delta * sin((val*PI*4.0)+PI*0.5) * strength * 0.5*0.5
	camera.rotation.y -= delta * sin(val*PI*2.0) * strength * PI*0.005
	camera.rotation.x -= delta * sin((val*PI*4.0)+PI*0.5) * strength * 0.5* PI*0.05

@export var walking_speed_mult = 1.0
func walking(delta, velocity) -> void:
	var walking_speed = Vector2(velocity.x,velocity.z).length()/4.0
	velocity = velocity*global_basis
	var dir = Vector2(velocity.x,velocity.z).normalized()
	var theta = atan2(dir.x,dir.y) + PI
	
	
	
	val += delta * 1.0 * walking_speed_mult *walking_speed
	var strength = 0.25
	if val > 1.0:
		val -= 1.0
		step = 0.5
	if val*2.0 > step:
		step += 1.0
		var c = floor_check.get_collider()
		if c!= null:
			step_sound(c.get_groups())
	#camera.position.x = lerp(camera.position.x, sin(val*PI), delta*8.0)
	hands.position.x += delta * sin(val*PI*2.0) * strength
	hands.position.y += delta * sin((val*PI*4.0)+PI*0.5) * strength
	camera.rotation.y -= delta * sin(val*PI*2.0) * strength * PI*0.01
	pass

@onready var audio_player = $step_sounds
func step_sound(groups = []) -> void:
	for g in groups:
		if Global.surface_lookup.has(g):
			var info = Global.surface_lookup[g]
			var sound = Global.surface_step_sounds[info[Global.STEP_SOUNDS]].pick_random()
			audio_player.stream = load(sound)
			audio_player.play()
			return
	#did not find so use default
	var sound = Global.surface_step_sounds[Global.surface_lookup["default"][Global.STEP_SOUNDS]].pick_random()
	audio_player.stream = load(sound)
	audio_player.play()
	pass

func _process(delta):
	camera.position = lerp(camera.position, Vector3.ZERO, delta*4.0)
	
	
	#if wall_run_active:
		#wall_run_active = false
	#elif $wall_run_sounds.playing:
		#$wall_run_sounds.stop()
	
	camera_rot_vel += -(camera.rotation) *delta #-camera_bone.rotation)* delta
	camera_rot_vel -= camera_rot_vel * delta * 10.0
	camera.rotation += camera_rot_vel
	
	var camera_rot = Vector2(rotation.y, cameraHandler.rotation.x)
	
	var dif = (camera_rot - last_frame_camera_rot)*hands_rot_lag_power
	
	if first_active_frame:
		dif = Vector2.ZERO
		first_active_frame = false
	else:
		speed_appeal(delta)
	
	hands.rotation.y += dif.x*0.2*0.25 #looks better for some reason
	hands.rotation.x -= dif.y*0.2
	hands.position.x += dif.x*0.1
	hands.position.y += dif.y*0.1
	
	last_frame_camera_rot = camera_rot
	
	hands.position.x = clamp(hands.position.x, -0.1,0.1)
	hands.position.y = clamp(hands.position.y, -0.1,0.1)
	
	hands_pos_vel += (Vector3(0.0,-0.05,0.14)-hands.position)*delta*hands_return_power
	hands_pos_vel -= hands_pos_vel*delta*hands_return_damp
	hands.position += hands_pos_vel * delta
	
	hands_rot_vel -= hands.rotation*delta *hands_rot_return_power
	hands_rot_vel -= hands_rot_vel*delta*hands_rot_return_damp
	hands.rotation += hands_rot_vel * delta
	
	#hands_rot_big_motion_vel -= hands.rotation*delta * hands_rot_big_motion_power
	#hands_rot_big_motion_vel -= hands_rot_big_motion_vel*delta*hands_rot_big_motion_damp
	#hands.rotation += hands_rot_big_motion_vel
	
	
	hands.rotation.x = clamp(hands.rotation.x,-PI*0.1,PI*0.1)
	hands.rotation.y = clamp(hands.rotation.y,-PI*0.1,PI*0.1)
	
	#hands.position = lerp(hands.position, Vector3(0.0,0.0,0.14), delta*16.0)
	#hands.rotation.x = clamp(lerp_angle(hands.rotation.x, 0.0, delta*16.0),-PI*0.1,PI*0.1)
	#hands.rotation.y = clamp(lerp_angle(hands.rotation.y, 0.0, delta*16.0),-PI*0.1,PI*0.1)
	
	#camera.rotation = camera_bone.rotation
	
	#match anim.current_animation:
		#"wall_run_left_empty":
			#wall_checking_left = true
		#"wall_run_right_empty":
			#wall_checking_right = true
		#"idle_empty":
			#wall_checking_left = true
			#wall_checking_right = true
		#"idle_holding_bread-metarig_001":
			#wall_checking_left = true
	
	
	
	#if wall_checking_left:
		#wall_check_left(delta)
		#wall_checking_left = false
	#else:
		#ik_left.stop()
	#if wall_checking_right:
		#wall_check_right(delta)
		#wall_checking_right = false
	#else:
		#ik_right.stop()
	


func speed_appeal(delta : float) -> void:
	var vel = $"..".velocity
	var speed = vel.length()
	var base_fov = Settings.graphics["FOV"]
	var max_fov_change = 50.0
	speed = clamp(speed,7.5,150.0)
	var appeal = speed / 150.0
	camera.set_fov(base_fov + max_fov_change * appeal)
