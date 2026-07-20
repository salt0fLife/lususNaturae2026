extends CharacterBody3D



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var speed = 15.0
@onready var graphics = $graphics

var state = "sleeping"

func _physics_process(delta):
	if player != null:
		match state:
			"sleeping":
				var dif = (player.global_position - global_position)
				velocity.x = 0.0
				velocity.z = 0.0
				if dif.length() < 3.0:
					state = "walking"
					anim.play("walk_forward_4L",0.5)
			"walking":
				var target_pos = player.global_position# + (player.velocity * 0.5)
				var dif = ( target_pos - global_position)
				var dir = Vector3(dif.x,0.0,dif.z).normalized()
				var desired_vel = 5.0*dir
				velocity -= (desired_vel-velocity)*delta*2.0
				var speed = Vector2(velocity.x,velocity.z).length()
				anim.speed_scale = speed / 5.0
				if dif.length() > 7.0:
					anim.speed_scale = 1.0
					state = "sleeping"
					anim.play("lay_down",0.75)
				
			"running":
				var target_pos = player.global_position# + (player.velocity * 0.5)
				var dif = ( target_pos - global_position)
				var dir = Vector3(dif.x,0.0,dif.z).normalized()
				var desired_vel = speed*dir
				velocity += (desired_vel-velocity)*delta
				
				if ((velocity*1.0 + global_position) - target_pos).length() < 4.0 and is_on_floor():
					anim.play("jump_attack", 0.1)
					velocity*= 1.2
					velocity.y += 7.0
				
				if dif.length() < 5.0:
					state = "fighting"
					anim.play("walk_forward_2L", 0.5)
			"fighting":
				var target_pos = player.global_position + (player.velocity * 0.5)
				var dif = ( target_pos - global_position)
				var dir = Vector3(dif.x,0.0,dif.z).normalized()
				var desired_vel = speed*dir*0.5
				velocity += (desired_vel-velocity)*delta*2.0
				var speed = Vector2(velocity.x,velocity.z).length()
				anim.speed_scale = speed / 6.0
				
				if ((velocity*0.5 + global_position) - target_pos).length() < 1.0:
					anim.play("claw_attack_R", 0.1)
					anim.speed_scale = 1.0
				
				if dif.length() > 15.0:
					state = "running"
					anim.play("run_forward_4l", 0.5)
					anim.speed_scale = 1.0
	else:
		player = get_tree().get_first_node_in_group("player")
	if velocity:
		
		var true_dir = Vector3(velocity.x,0.0,velocity.z).normalized()
		var desired_rot = atan2(true_dir.z,-true_dir.x) - PI*0.5
		graphics.rotation.y = lerp_angle(graphics.rotation.y, desired_rot, delta*4.0)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

@onready var anim = $graphics/wendigo_blockout/AnimationPlayer
var change_queued = ""
var change_timer = 0.0
var last_anim_processed = ""
func _process(delta):
	if $graphics/wendigo_blockout_smell/AnimationPlayer.current_animation != anim.current_animation:
		$graphics/wendigo_blockout_smell/AnimationPlayer.play(anim.current_animation, 0.25)
	
	if change_timer > 0.0:
		change_timer -= delta
		if change_timer < 0.0:
			change_timer = 0.0
			anim.play(change_queued)
	
	match anim.current_animation:
		"RESET":
			anim.play("lay_down")
		"lay_down":
				pass
	pass

var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim.connect("animation_finished", _on_anim_finished)
	anim.play("lay_down")
	PlayerInformation.connect("changed_using_senses", _on_changed_using_senses)
	_on_changed_using_senses()

func _on_anim_finished(key): 
	match key:
		"jump_attack":
			anim.play("run_forward_4l",0.25)
		"claw_attack_R":
			anim.play("walk_forward_2L", 0.25)
		_:
			anim.play(key,0.1)

func _input(event):
	if Input.is_action_just_pressed("ui_end"):
		if state == "sleeping":
			state = "running"
			anim.play("run_forward_4l", 0.5)
		else:
			state = "sleeping"
			anim.play("lay_down",0.75)

func _on_changed_using_senses():
	$graphics/wendigo_blockout.visible = !PlayerInformation.using_senses
	$graphics/wendigo_blockout_smell.visible = PlayerInformation.using_senses
	pass
