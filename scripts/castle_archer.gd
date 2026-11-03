extends CharacterBody3D
@export var alerted_distance = 8
@export var attack_distance = 5.0
@export var lunge_distance = 7.5
@export var walking_speed = 10.0
@export var running_speed = 15.0
@export var idle_wander_speed = 1.0
@export var lunge_speed = 10.0

var state = "idle"

@onready var anim = $AnimationPlayer
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
	if targeting_node == null:
		return
	var dif = (targeting_node.position - global_position)
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dir.x,dir.z)+PI,delta*8.0)
	velocity -= velocity * delta * 2.0

var lunge_timer = 0.0
func default(delta):
	if targeting_node == null:
		state = "idle"
		return
	var dif = (targeting_node.global_position - global_position)
	var dis = dif.length()
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	
	if dis < 22.0:
		if dis < 5.0:
			state = "running"
			return
		else:
			state = "shooting"
			return
	
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dir.x,dir.z)+PI,delta*8.0)
	velocity.x = lerp(velocity.x, dir.x*walking_speed,delta*8.0)
	velocity.z = lerp(velocity.z,dir.z * walking_speed,delta*8.0)
	
	

func running(delta):
	if targeting_node == null:
		state = "idle"
		return
	var dif = (global_position - targeting_node.global_position)
	var dis = dif.length()
	if dis > 8.0:
		state = "shooting"
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dir.x,dir.z)+PI,delta*8.0)
	velocity.x = lerp(velocity.x, dir.x*running_speed,delta*8.0)
	velocity.z = lerp(velocity.z,dir.z * running_speed,delta*8.0)

var shooting_timer = 0.0
var time_between_shots = 2.0
func shooting(delta):
	if targeting_node == null:
		state = "idle"
		return
	velocity.x -= velocity.x * 2.0 * delta
	velocity.z -= velocity.z * 2.0 * delta
	shooting_timer += delta
	if shooting_timer > time_between_shots:
		shooting_timer -= time_between_shots
		shoot(targeting_node.global_position)
	var dif = (targeting_node.global_position - global_position)
	var dis = dif.length()
	if dis > 22.0:
		state = "default"
	elif dis < 5.0:
		state = "running"
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dir.x,dir.z)+PI,delta*8.0)

@onready var look_dir_reference = $graphics/look_dir_reference
@export var arrow_dropoff_adjustment = 0.25
var loaded_arrow_key = "basic_arrow"
func shoot(target : Vector3):
	var dif = target - look_dir_reference.global_position
	var dis = dif.length()
	var dir = dif.normalized() + Vector3(0.0,arrow_dropoff_adjustment*dis,0.0)
	var pos = look_dir_reference.global_position
	Global.spawn_entity("basic_arrow",pos,dir*10.0,[loaded_arrow_key,self])

signal alerted
func _on_alerted(node):
	targeting_node = node
	#called externally when allies are alerted
	state = "default"

func inform_of_alert(node): #essentially same function but does not allow further recursion
	if targeting_node == null:
		targeting_node = node
	state = "default"
	pass

func alert_close_teamates():
	for n in get_tree().get_nodes_in_group(team):
		if n.has_method("inform_of_alert"):
			if (n.global_position - global_position).length() < alerted_distance:
				n.inform_of_alert(targeting_node)

var targeting_node = null

var random_target_pos = Vector3.ZERO
func idle(delta):
	var td = random_target_pos*Vector3(1.0,0.0,1.0) - position*Vector3(1.0,0.0,1.0)
	if td.length() < 1.0 or random_target_pos == Vector3.ZERO:
		random_target_pos = position + Vector3(randf_range(-5.0,5.0),0.0,randf_range(-5.0,5.0))
	var dir = Vector3(td.x,0.0,td.z).normalized()
	graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(dir.x,dir.z)+PI,delta*8.0)
	velocity.x = lerp(velocity.x, dir.x*idle_wander_speed,delta*8.0)
	velocity.z = lerp(velocity.z,dir.z * idle_wander_speed,delta*8.0)
	
	search_for_enemies()
	#velocity -= velocity*delta
	#var dif = (PlayerInformation.position - global_position)
	#var dis = dif.length()
	#if dis < alerted_distance:
		#state = "default"
		#emit_signal("alerted")

func search_for_enemies():
	var entities = get_tree().get_nodes_in_group("entity") + get_tree().get_nodes_in_group("player")
	var whitelist = get_tree().get_nodes_in_group(team) 
	for n in entities:
		if n != self and !whitelist.has(n):
			var pos = n.global_position
			var dif = pos- global_position
			var dis = dif.length()
			if dis < alerted_distance:
				targeting_node = n
				state = "default"
				emit_signal("alerted",n)
				alert_close_teamates()

func play_anim(key:StringName) -> void:
	anim.play(key)

@export var team = "team_01"
@export var entity_tag = "enemy_01"
func anim_on_attack(): #called by animation
	for hit in $graphics/attack_area.get_overlapping_bodies():
		if hit.has_method("take_damage"):
			if hit.team != team and team != "":
				hit.take_damage(4,Global.damage_types.SLICE)

@onready var graphics = $graphics
func anim_on_lunge():
	#var dir = Vector3(0.0,0.0,1.0) * graphics.transform.basis
	if targeting_node == null:
		return
	var dif = (targeting_node.position - global_position)
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	velocity = dir*lunge_speed
	pass

func get_data(): #NOTE [entity_key,[position, rotation, additional info]]
	var data = [position,Vector2.ZERO,[]]
	return [entity_tag,data]

func set_data(val : Array): # [position,rotation,additional info]
	position = val[0]

func set_unique_data(val : Array) -> void: #this is used when spawning the creature for the first time
	print("set_unique_data of enemy_01 with val " + str(val))
	pass

@onready var hh = $health_handler
func _ready():
	hh.connect("death",die)
	hh.connect("health_changed",update_health_graphics)

signal health_changed
func update_health_graphics() -> void:
	emit_signal("health_changed")
	var percentage = hh.health/hh.max_health
	if percentage > 0.5:
		$Label3D.modulate = Color.GREEN
	else:
		$Label3D.modulate = Color.RED
	$Label3D.text = str(hh.health) + " / " + str(hh.max_health)
	

signal perished

func die(limb:StringName = "",Type:int = 0) -> void:
	emit_signal("perished")
	call_deferred("queue_free")

func spawn_animation() -> void:
	play_anim("spawn_animation")

func create_spawn_particles() -> void:
	var p = load("res://assets/effects/generic_spawn_particles.tscn").instantiate()
	add_child(p)

func create_spawn_explosion() -> void:
	var p = load("res://assets/effects/generic_spawn_explosion.tscn").instantiate()
	add_child(p)

func get_health_info() -> Vector2i:
	return Vector2i(hh.health,hh.max_health)
