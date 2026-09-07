extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var run_speed:float = 8.0
@export var acceleration:float = 10.0
@export var injured_speed_mult:float = 0.2 #loses 20% of speed every injured stack
@export var turn_speed:float = 5.0
@export var locked_slow_mult : float = 2.0
var injured: int = 0
@onready var graphics = $graphics

func _physics_process(delta):
	if !is_state_locked():
		#play_anim("idle")
		chase_position(delta,PlayerInformation.position)
		
	else:
		velocity.x -= velocity.x * delta * locked_slow_mult
		velocity.z -= velocity.z * delta * locked_slow_mult
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func chase_position(delta : float, pos : Vector3) -> void:
	play_anim("walk")
	var dif = pos - global_position
	var wish_dir = Vector3(dif.x,0.0,dif.z).normalized()
	var trs = run_speed - run_speed*float(injured)*injured_speed_mult
	graphics.rotation.y = lerp_angle(graphics.rotation.y, Global.dir_to_rot(wish_dir).y, delta*turn_speed)
	var dir = Vector3(0.0,0.0,1.0).rotated(Vector3.UP,graphics.rotation.y)
	velocity = lerp(velocity,dir*run_speed,delta*acceleration)

@onready var health_handler = $health_handler
func _ready():
	health_handler.connect("death",die)
	health_handler.connect("took_damage",_on_took_damage)
	health_handler.connect("limb_death" , _on_limb_death)

func die(_t,_l):
	injured = 0
	print("forest spider died")
	call_deferred("queue_free")
	#$graphics/legs_left.visible = true
	#$graphics/legs_right.visible = true
	#$graphics/head.visible = true
	#$graphics/abdomen.visible = true

func _on_took_damage(amount):
#	velocity = Vector3.ZERO
	play_anim("hit_left")
	print("forest spider main took damage " + str(amount))

func _on_limb_death(limb, type):
	print("forest spider " + str(limb) + " died")
	injured += 1
	play_anim("stunned")
	match limb:
		"leg_1":
			pass
	#match limb:
		#"head" : $graphics/head.visible = false
		#"abdomen" : $graphics/abdomen.visible = false
		#"legs_left" : $graphics/legs_left.visible = false
		#"legs_right" : $graphics/legs_right.visible = false

const state_lock_anims = [
	"stunned",
	"hit_left",
	"hit_right"
]

@onready var anim = $graphics/forest_spider_test_anim/AnimationPlayer
func is_state_locked() -> bool:
	return state_lock_anims.has(anim.current_animation)

func play_anim(key : StringName) -> void:
	if anim.current_animation == key:
		return
	anim.play(key)

func get_rot() -> Vector2: #just in case climbing
	return Vector2(0.0,graphics.rotation.y)

func get_data() -> Array:
	var pos = position
	var health = $health_handler.health
	var rot = get_rot()
	var injuries = [] #just empty for now because yah
	var unique_attributes = {} #for display and other stuff
	var data:Array = [pos,rot,health,unique_attributes, injuries]
	return ["forest_spider",data]

func set_data(data : Array):
	position = data[0]
	var rot = data[1]
	$health_handler.health = data[2]
	var unique_attributes = data[3]
	var injuries = data[4]
