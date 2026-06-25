extends Node3D

@onready var audio_player = $AudioStreamPlayer
@onready var voice_audio_player = $AudioStreamPlayer2
func vault() -> void:
	audio_player.stream = load("res://assets/sounds/footsteps/snow/snow5.wav")
	audio_player.play()
	camera_rot_vel -= Vector3(1.0,0.0,0.0)*0.05

func wall_jump(normal : Vector3) -> void:
	normal = normal * transform.basis
	camera_rot_vel -= Vector3(normal.y,0.0,normal.x) * 0.02
	audio_player.stream = load("res://assets/sounds/player_movement/wall_jump.ogg")
	audio_player.play()

func jump() -> void:
	camera_rot_vel += Vector3(0.02,0.0,0.0)
	voice_audio_player.stream = load("res://assets/sounds/player_movement/player_jump.ogg")
	voice_audio_player.play()
	if floor_check.is_colliding():
		var hit = floor_check.get_collider()
		var groups = hit.get_groups()
		step_sound(groups)

func air_dash(direction : Vector3) -> void:
	direction = direction * transform.basis
	camera_rot_vel -= Vector3(direction.y + direction.z, direction.x*0.5, direction.x) * 0.02
	audio_player.stream = load("res://assets/sounds/player_movement/air_dash.ogg")
	audio_player.play()

var camera_rot_vel : Vector3 = Vector3.ZERO
@onready var camera = $cameraHandler/senses_camera
@onready var cameraHandler = $cameraHandler
@onready var hands = $cameraHandler/fp_hands_wip
@onready var camera_bone = $cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/camera_bone_attachment

@onready var last_frame_camera_rot = Vector2(rotation.y, cameraHandler.rotation.x)
@onready var anim = $cameraHandler/fp_hands_wip/AnimationPlayer
func _process(delta):
	camera.position = lerp(camera.position, Vector3.ZERO, delta*4.0)
	
	
	if wall_run_active:
		wall_run_active = false
	elif $wall_run_sounds.playing:
		$wall_run_sounds.stop()
	
	camera_rot_vel += -(camera.rotation) *delta #-camera_bone.rotation)* delta
	camera_rot_vel -= camera_rot_vel * delta * 10.0
	camera.rotation += camera_rot_vel
	speed_appeal(delta)
	
	var camera_rot = Vector2(rotation.y, cameraHandler.rotation.x)
	
	var dif = camera_rot - last_frame_camera_rot
	hands.rotation.y += dif.x*0.2
	hands.rotation.x -= dif.y*0.2
	hands.position.x += dif.x*0.25
	hands.position.y += dif.y*0.1
	
	last_frame_camera_rot = camera_rot
	
	hands.position.x = clamp(hands.position.x, -0.5,0.5)
	hands.position.y = clamp(hands.position.y, -0.1,0.1)
	hands.position = lerp(hands.position, Vector3(0.0,0.0,0.14), delta*16.0)
	hands.rotation.x = clamp(lerp_angle(hands.rotation.x, 0.0, delta*16.0),-PI*0.1,PI*0.1)
	hands.rotation.y = clamp(lerp_angle(hands.rotation.y, 0.0, delta*16.0),-PI*0.1,PI*0.1)
	
	#camera.rotation = camera_bone.rotation
	
	match anim.current_animation:
		"wall_run_left_empty":
			wall_checking_left = true
		"wall_run_right_empty":
			wall_checking_right = true
		"idle_empty":
			wall_checking_left = true
			wall_checking_right = true
		"idle_holding_bread-metarig_001":
			wall_checking_left = true
	
	
	
	if wall_checking_left:
		wall_check_left(delta)
		wall_checking_left = false
	else:
		ik_left.stop()
	if wall_checking_right:
		wall_check_right(delta)
		wall_checking_right = false
	else:
		ik_right.stop()
	

var wall_run_active = false
func wall_running(normal : Vector3, delta : float, power : float, groups : Array) -> void: # called every frame when running
	wall_run_active = true
	if !$wall_run_sounds.playing:
		var t = (1.0 - power) * 5.0 - 0.017 #because yeah sure
		$wall_run_sounds.play(t)
		print("wallrunning time " + str(t) + " : wallrunning power " + str(power))
	val += delta * power
	if val > 1.0:
		val -= 1.0
		step = 0.0
	if val*3.0 > step:
		step += 1.0
		step_sound(groups)
	normal = normal * transform.basis
	camera_rot_vel -= (Vector3(normal.y,0.0,normal.x) * 0.15 * delta * (power*2.0 - 1.0))
	camera_rot_vel -= Vector3(normal.y,0.0,normal.x) * 0.15 * delta * power
	pass

func speed_appeal(delta : float) -> void:
	var vel = $"..".velocity
	var speed = vel.length()
	var base_fov = Settings.graphics["FOV"]
	var max_fov_change = 50.0
	speed = clamp(speed,7.5,150.0)
	var appeal = speed / 150.0
	camera.set_fov(base_fov + max_fov_change * appeal)

var wall_checking_left = true
var wall_checking_right = false

@onready var wc_left = $cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/left_wall_check
@onready var ha_left = $cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/left_hand_ik
@onready var ik_left = $cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/hand_ik_left
func wall_check_left(delta):
	if wc_left.is_colliding():
		ik_left.start()
		var n = wc_left.get_collision_normal()
		ha_left.global_position = lerp(ha_left.global_position, wc_left.get_collision_point() + n*0.05, delta*16.0)
		var a = (n * transform.basis).dot(Vector3(0.0,0.0,1.0))
		ha_left.rotation.z = a*PI*0.25
	else:
		ik_left.stop()

@onready var wc_right = $cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/right_wall_check
@onready var ha_right = $cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/right_hand_ik
@onready var ik_right = $cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/hand_ik_right
func wall_check_right(delta):
	if wc_right.is_colliding():
		ik_right.start()
		var n = wc_right.get_collision_normal()
		ha_right.global_position = lerp(ha_right.global_position, wc_right.get_collision_point() + n*0.05, delta*16.0)
		var a = (n * transform.basis).dot(Vector3(0.0,0.0,1.0))
		ha_right.rotation.z = -a*PI*0.25
	else:
		ik_right.stop()

func _ready():
	PlayerInformation.connect("changed_using_senses", update_using_senses)
	#update_using_senses()
	pass

@onready var arm_meshes = [
	$cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/bodyMin_003,
	$cameraHandler/fp_hands_wip/metarig_001/Skeleton3D/bodyMin_005
]

func update_using_senses() -> void:
	if PlayerInformation.using_senses:
		var mat = $"../senses_trail".material.duplicate(true)
		for am in arm_meshes:
			am.set_surface_override_material(0, mat)
	else:
		for am in arm_meshes:
			am.set_surface_override_material(0, null)

var val = 0.0
var step = 0.0
func walking(delta) -> void:
	val += delta * 1.0
	var strength = 0.5
	if val > 1.0:
		val -= 1.0
		step = 0.5
	if val*2.0 > step:
		step += 1.0
		if floor_check.is_colliding():
			var hit = floor_check.get_collider()
			var groups = hit.get_groups()
			step_sound(groups)
	#camera.position.x = lerp(camera.position.x, sin(val*PI), delta*8.0)
	hands.position.x += delta * sin(val*PI*2.0) * strength
	hands.position.y += delta * sin((val*PI*4.0)+PI*0.5) * strength
	camera.rotation.y -= delta * sin(val*PI*2.0) * strength * PI*0.01
	pass

func running(delta) -> void:
	val += delta * 1.5
	var strength = 1.0
	if val > 1.0:
		val -= 1.0
		step = 0.0
	if val*2.0 > step:
		step += 1.0
		if floor_check.is_colliding():
			var hit = floor_check.get_collider()
			var groups = hit.get_groups()
			step_sound(groups)
	#camera.position.x = lerp(camera.position.x, sin(val*PI), delta*8.0)
	hands.position.x += delta * sin(val*PI*2.0) * strength
	hands.position.y += delta * sin((val*PI*4.0)+PI*0.5) * strength * 0.5
	camera.rotation.y -= delta * sin(val*PI*2.0) * strength * PI*0.005
	camera.rotation.x -= delta * sin((val*PI*4.0)+PI*0.5) * strength * 0.5* PI*0.05

@onready var floor_check = $"../floor_check"
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

func land() -> void:
	camera_rot_vel.x -= 0.025
	voice_audio_player.stream = load("res://assets/sounds/player_movement/player_land.ogg")
	voice_audio_player.play()
	if floor_check.is_colliding():
		var hit = floor_check.get_collider()
		var groups = hit.get_groups()
		step_sound(groups)

func shoot() -> void:
	camera_rot_vel += Vector3(PI*0.005,0.0,0.0)
	pass
