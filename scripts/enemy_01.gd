extends CharacterBody3D
var alerted_distance = 20.0
@export var attack_distance = 5.0
@export var lunge_distance = 7.5
@export var walking_speed = 10.0
@export var lunge_speed = 10.0

var state = "default"

@onready var anim = $animationPlayer
func _physics_process(delta):
	if anim.is_playing():
		while_anim(delta)
	elif has_method(state):
		call(state,delta)
	else:
		state = "default"
	if !is_on_floor():
		velocity.y -= 9.8*delta
	move_and_slide()

func while_anim(delta) -> void:
	var dif = (PlayerInformation.position - global_position)
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dir.x,dir.z)+PI,delta*8.0)
	velocity -= velocity * delta * 2.0

var lunge_timer = 0.0
func default(delta):
	var dif = (PlayerInformation.position - global_position)
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dir.x,dir.z)+PI,delta*8.0)
	velocity.x = lerp(velocity.x, dir.x*walking_speed,delta*8.0)
	velocity.z = lerp(velocity.z,dir.z * walking_speed,delta*8.0)
	
	var dis = dif.length()
	
	if dis < attack_distance:
		play_anim("attack_standard")
	elif dis < lunge_distance:
		lunge_timer -= delta
		if lunge_timer < 0.0:
			lunge_timer = randf_range(0.0,7.0)
			play_anim("attack_lunge")

func play_anim(key:StringName) -> void:
	anim.play(key)

func anim_on_attack(): #called by animation
	for hit in $graphics/attack_area.get_overlapping_bodies():
		if hit.has_method("take_damage"):
			hit.take_damage(4,Global.damage_types.TRUE_DAMAGE)

@onready var graphics = $graphics
func anim_on_lunge():
	#var dir = Vector3(0.0,0.0,1.0) * graphics.transform.basis
	var dif = (PlayerInformation.position - global_position)
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	velocity = dir*lunge_speed
	pass

func get_data():
	var data = [position]
	return ["enemy_01",data]

func set_data(val : Array):
	position = val[0]

func die():

	queue_free()
