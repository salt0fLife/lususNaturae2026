extends Node

@export var group_name : StringName
var subfolder = "persistent/"
@export var item_handler : Node3D #this needs to be empty except for the groups entity nodes
var has_spawned = false

func load_data(filepath):
	var data = SaveHandler.load_file(filepath+subfolder, group_name + ".dat")
	print(data)
	if data == null:
		print("no data for item group " + group_name)
		default_spawn()
		return
	if data.keys().has("has_spawned"):
		has_spawned = data["has_spawned"]
	if data.keys().has("item_list"):
		spawn_items(data["item_list"])
	else:
		default_spawn()

func save_data(filepath) -> void:
	if !has_spawned:
		return
	
	if !is_valid_name(group_name):
		printerr("invalid group_name")
		return
	print("saved entity group data")
	
	var item_list = []
	if item_handler != null:
		for e in item_handler.get_children(false):
			#var ed = e.get_data()
			var ed = [e.position,e.rotation,e.stuck,e.data]
			item_list.append(ed)
	
	
	var data = {
		"has_spawned" : has_spawned,
		"item_list" : item_list,
	}#{"foo" : "hello beautiful world!"}
	
	SaveHandler.save_file(filepath+subfolder, group_name + ".dat", data)
	
	pass

func is_valid_name(gn : StringName) -> bool:
	if gn =="":
		return false
	return gn.is_valid_filename()

func default_spawn() -> void:
	spawn_items(get_default_spawn_list())
	pass

func spawn_items(data) -> void:
	has_spawned = true
	if item_handler == null:
		printerr("invalid item_handler path for item group " + str(group_name))
		return
	var n = load("res://campaign/entities/loose_item.tscn")
	for i in data:
		var pos = i[0]
		var rot = i[1]
		var stuck = i[2]
		var item_data = i[3]
		var n_i = n.instantiate()
		n_i.data = item_data
		n_i.position = pos
		n_i.rotation = rot
		n_i.stuck = stuck
		item_handler.add_child(n_i)

func get_default_spawn_list() -> Array:
	#[position,entity_key,default_data]
	var list = []
	for sp in get_children(false):
		if sp.has_method("get_spawn_info"):
			var info = sp.get_spawn_info()
			list.append(info)
	return list
