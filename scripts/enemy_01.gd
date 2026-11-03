extends CharacterBody3D
@export var alerted_distance = 8
@export var attack_distance = 5.0
@export var lunge_distance = 7.5
@export var walking_speed = 10.0
@export var idle_wander_speed = 1.0
@export var lunge_speed = 10.0

var state = "idle"

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

signal alerted
func _on_alerted(node):
	targeting_node = node
	#called externally when allies are alerted
	state = "default"
	pass

func inform_of_alert(node): #essentially same function but does not allow further recursion
	if targeting_node == null:
		targeting_node = node
	state = "default"
	pass

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

func search_for_enemies(distance = alerted_distance):
	var entities = get_tree().get_nodes_in_group("entity") + get_tree().get_nodes_in_group("player")
	var whitelist = get_tree().get_nodes_in_group(team) 
	for n in entities:
		if n != self and !whitelist.has(n):
			var pos = n.global_position
			var dif = pos- global_position
			var dis = dif.length()
			if dis < distance:
				targeting_node = n
				state = "default"
				emit_signal("alerted",n)
				return

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
	hh.connect("took_damage",took_damage)

func took_damage(_amount):
	print("extra alert")
	search_for_enemies(alerted_distance*3.0)

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
