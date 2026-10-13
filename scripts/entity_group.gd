extends Node
@export var group_name : StringName
var subfolder = "entity_groups/"
@export var entity_handler : Node3D #this needs to be empty except for the groups entity nodes
@export var auto_spawn:bool = true #spawns entities whenever scene is loaded
@export var group_alert:bool = false
@export var start_alerted:bool = false
@export var spawn_animation:bool = false
@export var monitor_health_pool:bool = false
var all_dead = false
var has_spawned = false

func load_data(filepath):
	var data = SaveHandler.load_file(filepath+subfolder, group_name + ".dat")
	print(data)
	if data == null:
		print("no data for entity group " + group_name)
		if auto_spawn:
			default_spawn()
		return
	if data.keys().has("foo"):
		print(data["foo"])
	if data.keys().has("all_dead"):
		all_dead = data["all_dead"]
	
	if data.keys().has("entities_list"):
		spawn_entities(data["entities_list"])
	else:
		if auto_spawn:
			default_spawn()

func save_data(filepath) -> void:
	if !has_spawned:
		return
	
	if !is_valid_name(group_name):
		printerr("invalid group_name")
		return
	print("saved entity group data")
	
	var entity_list = []
	if entity_handler != null:
		for e in entity_handler.get_children(false):
			var ed = e.get_data()
			entity_list.append(ed)
	
	
	var data = {
		"foo" : "an alternative message!",
		"entities_list" : entity_list,
		"all_dead" : all_dead
	}#{"foo" : "hello beautiful world!"}
	
	SaveHandler.save_file(filepath+subfolder, group_name + ".dat", data)
	
	pass

func default_spawn() -> void:
	spawn_entities(get_default_spawn_list(),spawn_animation)

func get_default_spawn_list() -> Array:
	#[position,entity_key,default_data]
	var list = []
	for sp in get_children(false):
		if sp.has_method("get_spawn_info"):
			var info = sp.get_spawn_info()
			list.append(info)
	return list

func spawn_entities(list:Array, spawn_anim:bool = false) -> void:
	has_spawned = true
	if entity_handler == null:
		entity_handler = Node3D.new()
		entity_handler.name = "entity_handler"
		add_child(entity_handler)
	for entity_info in list:
		var entity = load(Global.entities[entity_info[0]][0]).instantiate()
		entity.set_data(entity_info[1])
		entity_handler.add_child(entity)
		entity.connect("perished",_on_entity_death)
		if entity.has_method("_on_alerted"):
			if start_alerted:
				entity._on_alerted()
			elif group_alert:
				entity.connect("alerted",_on_entity_alerted)
		if entity.has_method("spawn_animation") and spawn_anim:
			entity.spawn_animation()
		if monitor_health_pool:
			if entity.has_signal("health_changed"):
				entity.connect("health_changed",update_health_pool)
	if monitor_health_pool:
		health_pool = get_entity_health_pool()
		emit_signal("health_pool_changed")

signal all_entities_dead
func _on_entity_death():
	await  get_tree().process_frame #in case call deferred queue_free
	var count = entity_handler.get_child_count(false)
	print("entity_death, new count " + str(count))
	if count == 0:
		all_dead = true
		emit_signal("all_entities_dead")

func _on_entity_alerted():
	for n in entity_handler.get_children(false):
		if n.has_method("_on_alerted"):
			n._on_alerted()

func is_valid_name(gn : StringName) -> bool:
	if gn =="":
		return false
	return gn.is_valid_filename()

var health_pool = Vector2i(0,0)
func get_entity_health_pool() -> Vector2i:
	var hp = Vector2i(0,0)
	for e in entity_handler.get_children():
		if e.has_method("get_health_info"):
			var hi = e.get_health_info()
			hp += hi
	return hp

signal health_pool_changed
func update_health_pool() -> void:
	var new_hp = get_entity_health_pool()
	if health_pool.x != new_hp.x:
		health_pool.x = new_hp.x
		emit_signal("health_pool_changed")
