extends CharacterBody3D

@export var state = "hover"
@onready var graphics = $graphics

func _physics_process(delta):
	if has_method(state):
		call(state, delta)
	else:state = "hover"
	move_and_slide()

func hover(delta):
	play_anim("hovering")
	if $RayCast3D.is_colliding():
		var poi = $RayCast3D.get_collision_point()
		var dis = (poi - global_position).length()
		velocity.y += clamp((2.0-dis),0.0,2.0) * delta
	else:
		velocity.y -= 1.0*delta
	decision_timer += delta
	
	if decision_timer > 10.0:
		decision_timer = 0.0
		pick_next_location()
		state = "migrating"

func pick_next_location():
	goal_location = global_position + Vector3(randf_range(-20.0,20.0),0.0,randf_range(-20.0,20.0))

var goal_location = Vector3.ZERO

func migrating(delta):
	var dir = (goal_location - global_position).normalized()
	velocity = lerp(velocity, dir*5.0, delta*4.0)
	play_anim("flapping", 0.2)
	graphics.rotation.y = lerp(graphics.rotation.y, atan2(dir.x,dir.z), delta*4.0)
	if (global_position - goal_location).length() < 2.0:
		decision_timer = 0.0
		state = "hover"
		#state = "dead"
		#play_anim("die")
		#velocity.y += 1.0

var on_floor = false
func dead(delta):
	if !is_on_floor():
		on_floor = false
		velocity.y -= 9.8*delta
		if $graphics/bat_creature_blockout/AnimationPlayer.current_animation != "die":
			play_anim("fall")
	elif !on_floor:
		on_floor = true
		play_anim("land_dead")
	else:
		velocity = lerp(velocity, Vector3.ZERO, delta*4.0)
		decision_timer += delta
		if decision_timer > 5.0:
			state = "hover"

func take_damage(amount, _type) -> void:
	print("took " + str(amount) + " damage, dying now")
	die()

func die():
	decision_timer = 0.0
	state = "dead"
	play_anim("die")
	velocity.y += 1.0
	var data = ["dead_bat"]
	PlayerInformation.emit_signal("dropped_item", data, position)

var decision_timer = 0.0

var flap_timer = 0.0
var flap_break_timer = 0.0

@export var flap_speed = 1.0
@export var flap_strength = 1.0
@export var dampening:float = 0.0

func fly_aimlessly_without_landing(delta):
	velocity.y -= 9.8*delta
	flap_timer += delta * flap_speed
	if flap_timer > PI*2.0:
		flap_timer -= PI*2.0
	
	
	var desired_y_dir = 0.0
	if $RayCast3D.is_colliding():
		var poi = $RayCast3D.get_collision_point()
		var dis = abs((poi - global_position).y)
		desired_y_dir = 1.0
	
	flap_break_timer += delta
	if flap_break_timer > 1.0:
		flap_break_timer -= 1.5
	elif flap_break_timer < 0.0:
		desired_y_dir = 0.0
	
	#velocity.y += ((sin(flap_timer)*0.5)+1.0)*desired_y_dir * flap_strength * delta
	
	velocity += Vector3(0.0,(((sin(flap_timer)*0.5)+1.0)*desired_y_dir * flap_strength * delta), 0.0).rotated(Vector3.LEFT,PI*0.1)
	
	
	velocity -= velocity*dampening*delta

func play_anim(key : StringName, blend_time: float = 0.0) -> void:
	if $graphics/bat_creature_blockout/AnimationPlayer.current_animation != key:
		$graphics/bat_creature_blockout/AnimationPlayer.play(key,blend_time)
		#print(key)
