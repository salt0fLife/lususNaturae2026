extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var run_speed:float = 8.0
@export var injured_speed_mult:float = 0.2 #loses 20% of speed every injured stack
var injured: int = 0
@onready var graphics = $graphics

func _physics_process(delta):
	chase_position(delta,PlayerInformation.position)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func chase_position(delta : float, pos : Vector3) -> void:
	var dif = pos - global_position
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	var trs = run_speed - run_speed*float(injured)*injured_speed_mult
	velocity = lerp(velocity,dir*trs,delta)
	graphics.rotation.y = Global.dir_to_rot(dir).y

@onready var health_handler = $health_handler
func _ready():
	health_handler.connect("death",die)
	health_handler.connect("took_damage",_on_took_damage)
	health_handler.connect("limb_death" , _on_limb_death)

func die(_t,_l):
	injured = 0
	print("forest spider died")
	$graphics/legs_left.visible = true
	$graphics/legs_right.visible = true
	$graphics/head.visible = true
	$graphics/abdomen.visible = true

func _on_took_damage(amount):
	velocity = Vector3.ZERO
	print("forest spider main took damage " + str(amount))

func _on_limb_death(limb, type):
	print("forest spider " + str(limb) + " died")
	injured += 1
	match limb:
		"head" : $graphics/head.visible = false
		"abdomen" : $graphics/abdomen.visible = false
		"legs_left" : $graphics/legs_left.visible = false
		"legs_right" : $graphics/legs_right.visible = false


