extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation.y = PlayerInformation.rotation.x
	position = PlayerInformation.position
	camera.global_transform = camera_distant.global_transform
	pass # Replace with function body.

@onready var camera_start =  $graphics/cameraHandler
@onready var camera = $graphics/fp_hands_wip/metarig_001/Skeleton3D/BoneAttachment3D/animated_camera/senses_camera
@onready var camera_animated = $graphics/fp_hands_wip/metarig_001/Skeleton3D/BoneAttachment3D/animated_camera
@onready var camera_distant = $graphics/camera_distant_start
var timer = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.

var zoom_time = 4.0
var pre_timer = 0.0
func _process(delta):
	pre_timer += delta
	if !pre_timer > zoom_time:
		
		camera.global_position = lerp(camera_distant.global_position, camera_start.global_position, pre_timer/zoom_time)
		camera.rotation.x = lerp(camera_distant.rotation.x, camera_start.rotation.x,pre_timer/zoom_time)
		return
	$graphics/fp_hands_wip/AnimationPlayer.play("emerge_from_ground")
	
	
	
	camera_start.position.z += 0.01*delta
	timer += delta
	if timer > 1.2:
		if !timer > 1.2+0.5:
			var val = (timer - 1.2)*2.0
			camera.global_position = lerp(camera_start.global_position, camera_animated.global_position, val)
			camera.rotation.x = lerp_angle(camera.rotation.x,0.0, val)
			camera.rotation.y = lerp_angle(camera.rotation.y,0.0, val)
			camera.rotation.z = lerp_angle(camera.rotation.z,0.0, val)
		else:
			camera.position = Vector3.ZERO
			camera.rotation = Vector3.ZERO
	else:
		camera.global_transform = camera_start.global_transform
	if timer > 4.2:
		#is done
		anim_finished()

func anim_finished():
	PlayerInformation.position = position
	PlayerInformation.rotation = Vector2(0.0,rotation.y)
	PlayerInformation.velocity = Vector3.ZERO
	PlayerInformation.change_player_scene(-1)
	pass

func tp(pos : Vector3, rot : Vector2, _vel := Vector3.ZERO) -> void:
	position = pos
	rotation.y = rot.y
