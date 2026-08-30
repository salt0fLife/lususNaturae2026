extends entity_base

@export var migration_speed : float = 10.0
@export var avoid_speed : float = 20.0
var lazy_render:bool = false
@export var lazy_render_distance:float = 100.0

@onready var vision_ray = $RayCast3D
@export var frames_between_checks: int = 24
var frame_check_timer:int = 0
var recheck:int = 0
var rerout_add_vel:Vector3 = Vector3.ZERO
var main_vel:Vector3 = Vector3.ZERO
func _ready():
	vision_ray.target_position = Global.NORTH_DIR * migration_speed
	frame_check_timer = randi_range(0,frames_between_checks)
	pass

func _process(delta):
	if is_out_of_bounds():
		print("despawning skyfish")
		queue_free()
		return
	else:
		var dis = (position - PlayerInformation.position).length()
		if dis > lazy_render_distance:
			if !lazy_render:
				set_lazy_render(true)
		elif lazy_render:
			set_lazy_render(false)
		
		migrate(delta)
	
	#navigation
	rerout_add_vel -= rerout_add_vel*delta
	frame_check_timer += 1
	if recheck > frames_between_checks:
		recheck = -frames_between_checks*2
		main_vel = -Global.NORTH_DIR * avoid_speed
		main_vel.y = avoid_speed * randf_range(-1.0,1.0)
	elif recheck > 0:
		recheck -= 1
		check_for_obstructions()
		check_for_ground()
	elif recheck < 0:
		recheck += 1
		main_vel = -Global.NORTH_DIR * avoid_speed
		#main_vel.y = avoid_speed * randf_range(-1.0,1.0)
	elif frame_check_timer > frames_between_checks:
		frame_check_timer = 0
		check_for_obstructions()
		check_for_ground()
	
	#move_and_slide()
	velocity = lerp(velocity,main_vel + rerout_add_vel,delta*8.0)
	move_and_slide()
	#position += velocity * delta + rerout_add_vel*delta; # so it cannot be stopped
	pass

func check_for_obstructions() -> void:
	vision_ray.target_position =  Global.NORTH_DIR*migration_speed + rerout_add_vel
	#vision_ray.target_position = velocity+rerout_add_vel
	if vision_ray.is_colliding():
		var norm = vision_ray.get_collision_normal()
		var severety = abs((velocity.normalized()).dot(norm))
		#print(severety)
		rerout_add_vel = vision_ray.get_collision_normal() * severety * avoid_speed
		rerout_add_vel.y += randf_range(-1.0,1.0)
		#rerout_add_vel*=avoid_speed
		#frame_check_timer = frames_between_checks #so it checks again immediately after
		recheck += 2
		#vision_ray.target_position = rerout_add_vel
		#vision_ray.force_raycast_update()

@onready var ground_check = $RayCast3D2
func check_for_ground() -> void:
	if ground_check.is_colliding():
		var dis = (ground_check.get_collision_point() - position).length()
		if dis < 5.0:
			rerout_add_vel.y += 1.0 * (1.0-dis/5.0)*avoid_speed #ease up to desired_pos
	elif velocity.length() < migration_speed*0.5:
		rerout_add_vel.y += avoid_speed * randf_range(-1.0,1.0)

func set_lazy_render(val:bool) -> void:
	#graphics.visible = !val
	#$Sprite3D.visible = val
	#$MeshInstance3D2.visible = val
	lazy_render = val
	pass

@onready var graphics = $graphics
func migrate(delta) -> void:
	main_vel = Global.NORTH_DIR * migration_speed
	var rot = Global.dir_to_rot(velocity)
	graphics.rotation.y = rot.y
	graphics.rotation.x = rot.x + PI*0.5

func get_data() -> Array:
	return ["young_skyfish",[position]]

func set_data(val:Array) -> void:
	position = val[0]

func die():
	call_deferred("queue_free")
