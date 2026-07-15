extends Node
@onready var worldHandler = $WorldHandler
@onready var playerHandler = $playerHandler
@onready var itemHandler = $itemHandler
@onready var cutsceneHandler = $cutsceneHandler
@onready var entityHandler = $entityHandler
@onready var loading_screen = $loading_screen
@onready var decalHandler = $decalHandler

#game variables
var day_timer: float = 500.1
var day_length: float = 1000.0
var seconds_played = 0

var level = "debug"
var player_stage = -2
var in_game_days = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInformation.connect("dropped_item", _on_dropped_item)
	PlayerInformation.connect("perished", _on_player_death)
	PlayerInformation.connect("changed_using_senses", _on_changed_using_senses)
	Global.connect("dialogue", _on_dialogue)
	Global.connect("new_tooltip", _on_tooltip)
	Global.connect("change_level", change_level)
	Global.connect("reached_major_point", _on_major_point_reached)
	Global.connect("spawn_entity_signal", spawn_entity)
	Global.connect("create_decal_signal", create_decal)
	Global.connect("play_cutscene_signal", play_cutscene)
	PlayerInformation.connect("change_player", change_player)
	$pause_menu/buttonHandler/resume.connect("button_down", set_paused.bind(false))
	$"pause_menu/buttonHandler/save and quit".connect("button_down", save_and_quit)
	
	setup_dev_controls()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	load_data_from_save()
	
	if Global.progression == 0:
		load_current_level_persistent_data() # a bandaid fix to be sure
		play_cutscene("new_game_start")
		Global.progression = 1
	else:
		start_game()

func start_game():
	#var level_data = Global.levels[level]
	#var level_scene = load(level_data[0]).instantiate()
	#worldHandler.add_child(level_scene)
	change_level(level, false)
	change_player(player_stage)
	load_current_level_persistent_data()

const default_save_data = {
	"velocity" : Vector3.ZERO,
	"position" : Vector3.ZERO,
	"rotation" : Vector2.ZERO,
	"player_stage" : -2,
	"level" : "debug",
	"day_timer" : 500.1,
	"seconds_played" : 0,
	"food" : 2,
	"min_sleep_food" : 4,
	"max_food" : 5,
	"health" : 1.0,
	"max_health" : 5.0,
	"in_game_days" : 0,
}

const default_inventory_data = {
	"inventory" :[[],[],[],[],[]],
	"held_item_index" : 0
	}

const default_story_info = {
	"cutscenes_watched" = [],
	"progression" = 0,
	"major_points_reached" = []
}

func change_level(level_key : String, update_persistent_data = true) -> void:
	if changing_level:
		printerr("already loading different level")
		return
	set_paused(true)
	if update_persistent_data:
		update_persistent_levels_data()
	for old in worldHandler.get_children(false):
		old.queue_free()
	level = level_key
	level_to_change_too = Global.levels[level][0]
	ResourceLoader.load_threaded_request(Global.levels[level][0])
	changing_level = true
	
	#level = level_key
	#var level_data = Global.levels[level]
	#var level_scene = load(level_data[0]).instantiate()
	#worldHandler.add_child(level_scene)
	#
	#load_current_level_persistent_data()

func set_level_to_scene(scene : PackedScene) -> void:
	var level_scene = scene.instantiate()
	worldHandler.add_child(level_scene)
	load_current_level_persistent_data()

func load_current_level_persistent_data():
	loading_screen.visible = true
	loading_screen.update_mode(true, "recreating level data")
	for old_i in itemHandler.get_children(false):
		old_i.call_deferred("queue_free")
	for old_e in entityHandler.get_children(false):
		old_e.call_deferred("queue_free")
	for old_d in decalHandler.get_children(false):
		old_d.queue_free() #should never have their own processes
	
	var data = [[],[[],[]]]
	if Global.levels_persistent_data.has(level):
		data = Global.levels_persistent_data[level]
	else:
		for w in worldHandler.get_children():
			if w.has_method("default_settup"):
				w.call("default_settup")
				print("default_level_settup")
	
	for i in data[0]:
		_on_dropped_item(i[1],i[0])
	
	if data.size() > 1:
		#for d in data[1]:
		#decals
		var d = data[1]
		#print("loaded decals vvv\n\n")
		#print(d)
		if d.size() > 1:
			for pi in range(0,d[0].size()):
				var s = load(d[0][pi]) #the scene
				for t in d[1][pi]: #every transform of the scene
					var s_i = s.instantiate()
					s_i.transform = t
					decalHandler.add_child(s_i)
	
	if data.size() > 2:
		for e in data[2]:
			#entities
			#spawn_entity(e[0],e[1])
			var scene = spawn_entity(e[0])
			scene.set_data(e[1])
	loading_screen.visible = false
	loading_screen.update_mode(false, "recreating level data")

func spawn_entity(key : String, position : Vector3 = Vector3.ZERO):
	if !Global.entities.has(key):
		return null
	var e = load(Global.entities[key][0]).instantiate()
	entityHandler.add_child(e)
	e.position = position
	return e

func create_decal(node) -> void: #just for visuals
	if decalHandler.get_child_count(false) > 512:
		decalHandler.get_child(0).queue_free()
	decalHandler.add_child(node)

func change_player(stage : int) -> void:
	for old in playerHandler.get_children(false):
		old.queue_free()
	
	player_stage = stage
	var player_stage_data = PlayerInformation.player_scenes[player_stage]
	var player_scene = load(player_stage_data[0]).instantiate()
	var pos = [PlayerInformation.position,PlayerInformation.rotation,PlayerInformation.velocity]
	playerHandler.add_child(player_scene)
	player_scene.tp(pos[0],pos[1],pos[2])
	player_scene.connect("fall_asleep", _on_player_fall_asleep)

func load_data_from_save():
	var saved_data = SaveHandler.load_file(Global.save_filepath,"generic_save.dat")
	#saved_data = JSON.parse_string(saved_data)
	if saved_data == null:
		saved_data = default_save_data.duplicate(true)
	PlayerInformation.velocity = saved_data["velocity"]
	PlayerInformation.position = saved_data["position"]
	PlayerInformation.rotation = saved_data["rotation"]
	seconds_played = saved_data["seconds_played"]
	day_timer = saved_data["day_timer"]
	player_stage = saved_data["player_stage"]
	level = saved_data["level"]
	PlayerInformation.food = saved_data["food"]
	PlayerInformation.max_food = saved_data["max_food"] 
	PlayerInformation.min_sleep_food = saved_data["min_sleep_food"]
	PlayerInformation.health = saved_data["health"]
	PlayerInformation.max_health = saved_data["max_health"]
	in_game_days = saved_data["in_game_days"]
	
	##inventory
	
	var inventory_data = SaveHandler.load_file(Global.save_filepath,"inventory.dat")
	if inventory_data == null:
		inventory_data = default_inventory_data.duplicate(true)
	PlayerInformation.held_item_index = inventory_data["held_item_index"]
	PlayerInformation.inventory = inventory_data["inventory"]
	PlayerInformation.emit_signal("update_inventory")
	
	##world
	#var world_data = SaveHandler.load_file(Global.save_filepath,"world_data.dat")
	#var lose_item_data = world_data["lose_items"]
	#for li_data in lose_item_data:
		#_on_dropped_item(li_data[1],li_data[0])
	var persistent_data = SaveHandler.load_file(Global.save_filepath,"levels_persistent.dat")
	if persistent_data == null:
		persistent_data = {}
	Global.levels_persistent_data = persistent_data
	
	##story
	var story_info = SaveHandler.load_file(Global.save_filepath,"story_info.dat")
	if story_info == null:
		story_info = default_story_info.duplicate(true)
	Global.cutscenes_watched = story_info["cutscenes_watched"]
	
	Global.progression = story_info["progression"]
	Global.major_points_reached = story_info["major_points_reached"]

func save_game_data():
	
	##generic_save
	var game_data = {
	"velocity" : PlayerInformation.velocity,
	"position" : PlayerInformation.position,
	"rotation" : PlayerInformation.rotation,
	"player_stage" : player_stage,
	"level" : level,
	"day_timer" : day_timer,
	"seconds_played" : seconds_played,
	"food" : PlayerInformation.food,
	"max_food" : PlayerInformation.max_food,
	"min_sleep_food" : PlayerInformation.min_sleep_food,
	"health" : PlayerInformation.health,
	"max_health" : PlayerInformation.max_health,
	"in_game_days" : in_game_days,
	"version" : Global.version
	}
	
	#game_data = JSON.stringify(game_data)
	SaveHandler.save_file(Global.save_filepath,"generic_save.dat", game_data)
	
	##world
	update_persistent_levels_data()
	SaveHandler.save_file(Global.save_filepath,"levels_persistent.dat", Global.levels_persistent_data)
	
	##preview
	var summary = "you played the demo version!" + "\nyou also played for about " + Global.get_abreviated_time(seconds_played)
	var preview_data = SaveHandler.load_file(Global.save_filepath,"preview.dat")
	preview_data = JSON.parse_string(preview_data)
	preview_data["progress_summary"] = summary
	preview_data["seconds_played"] = seconds_played
	preview_data = JSON.stringify(preview_data)
	SaveHandler.save_file(Global.save_filepath,"preview.dat",preview_data)
	
	
	##inventory
	var inventory_data = {
		"held_item_index" : PlayerInformation.held_item_index,
		"inventory" : PlayerInformation.inventory
	}
	SaveHandler.save_file(Global.save_filepath,"inventory.dat", inventory_data)
	
	
	
	
	##story
	var story_info = {
		"cutscenes_watched" : Global.cutscenes_watched,
		"progression" : Global.progression,
		"major_points_reached" : Global.major_points_reached,
	}
	SaveHandler.save_file(Global.save_filepath,"story_info.dat", story_info)

func update_persistent_levels_data() -> void:
	if in_cutscene:
		return
	var loose_items_save = []
	var decals_save = [[],[]]
	
	for dc in decalHandler.get_children(false):
		var path = dc.scene_file_path
		if decals_save[0].has(path):
			var i = decals_save.find(path)
			decals_save[1][i] += [dc.transform] #it exists so adds to list
		else: #does not exist yet so adds entries for both
			decals_save[0] += [path]
			decals_save[1] += [[dc.transform]]
	#print("saved decals : " + str(decals_save))
	
	for li in itemHandler.get_children(false):
		var data = [li.position, li.data]
		loose_items_save += [data]
	
	var entity_save = []
	for e in entityHandler.get_children(false):
		var data = e.get_data()
		entity_save += [data]
	
	
	Global.levels_persistent_data[level] = [loose_items_save,decals_save,entity_save]

var changing_level:bool = false
var level_to_change_too:StringName = ""


var sub_second_counter = 0.0
func _process(delta):
	if changing_level:
		if !ResourceLoader.has_cached(level_to_change_too):
			print("well thats a problem")
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(level_to_change_too, progress)
		print("level status : " + str(progress[0]))
		loading_screen.visible = true
		loading_screen.update_progress(progress[0])
		if ResourceLoader.THREAD_LOAD_LOADED:#progress[0] >= 1.0:
			changing_level = false
			set_level_to_scene(ResourceLoader.load_threaded_get(level_to_change_too))
			level_to_change_too = ""
			set_paused(false)
			loading_screen.visible = false
			#return #finished loading
	
	
	update_debug_graphics()
	if paused:
		$Label2.text = "paused"
		return
	else:
		$Label2.text = "playing"
	
	if in_cutscene:
		cutscene_timer -= delta
		if cutscene_timer < 0.0:
			end_cutscene()
		return
	
	day_timer += delta
	if day_timer > day_length:
		day_timer -= day_length
		in_game_days += 1
	PlayerInformation.world_time = (day_timer/day_length) #IMPORTANT
	
	
	sub_second_counter += delta
	while sub_second_counter > 1.0: #allows for accurate counting through harsh stuttering
		seconds_played += 1
		sub_second_counter -= 1.0
	$Label.text = str(seconds_played)
	$debug_menu/left/in_game_days.text = "days past = " + str(in_game_days)

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		set_paused(!paused)
	if paused or in_cutscene:
		return
	if Input.is_action_just_pressed("use_item"):
		use_held_item()
	if Input.is_action_just_pressed("use_item_special"):
		use_held_item(true)
	if Input.is_action_just_pressed("drop_item"):
		PlayerInformation.drop_held_item()
	if Input.is_action_just_pressed("inventory"):
		set_inventory_open(true)
	if Input.is_action_just_released("inventory"):
		set_inventory_open(false)
	if Input.is_action_just_pressed("action_wheel"):
		set_action_menu_open(true)
	if Input.is_action_just_released("action_wheel"):
		set_action_menu_open(false)
	
	if Input.is_action_just_pressed("inventory_slot_1"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(0, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(0)
	if Input.is_action_just_pressed("inventory_slot_2"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(1, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(1)
	if Input.is_action_just_pressed("inventory_slot_3"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(2, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(2)
	if Input.is_action_just_pressed("inventory_slot_4"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(3, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(3)
	if Input.is_action_just_pressed("inventory_slot_5"):
		if inventory_open:
			var sel_indx = inventory_menu.get_menu_selection()
			var data = PlayerInformation.swap_inventory_slot(4, PlayerInformation.inventory[sel_indx])
			PlayerInformation.set_inventory_slot(sel_indx,data)
		else:
			select_inventory_slot(4)

var paused = false

var in_cutscene = false
var cutscene_timer = 0.0

func play_cutscene(key : String) -> void:
	update_persistent_levels_data()
	purge_world()
	var data = Global.cutscenes[key]
	var scene = load(data[0]).instantiate()
	cutsceneHandler.add_child(scene)
	scene.connect("end", end_cutscene)
	cutscene_timer = data[1]
	in_cutscene = true
	if !Global.cutscenes_watched.has(key):
		Global.cutscenes_watched.append(key)

func end_cutscene() -> void:
	in_cutscene = false
	for c in cutsceneHandler.get_children(false):
		c.queue_free()
	start_game()

func set_paused(val := true):
	paused = val
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif !Global.in_game_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$pause_menu.visible = val
	get_tree().paused = paused

func save_and_quit() -> void:
	get_tree().paused = false
	save_game_data()
	await get_tree().process_frame
	get_tree().call_deferred("change_scene_to_file", "res://menus/main_menu.tscn")

##dev controls

var player_stages = PlayerInformation.player_scenes.keys()
var level_keys = Global.levels.keys()
var cutscene_keys = Global.cutscenes.keys()
var item_list_keys = Items.list.keys()
var entity_keys = Global.entities.keys()
func setup_dev_controls():
	var stage_selector = $pause_menu/devtools/HFlowContainer/PanelContainer/VBoxContainer/debugPlayer_scene_select
	for stage in player_stages:
		stage_selector.add_item(str(stage))
	stage_selector.connect("item_selected", _on_player_scene_selected)
	stage_selector.selected = 0
	
	var level_selector = $pause_menu/devtools/HFlowContainer/PanelContainer2/VBoxContainer/OptionButton
	for lk in level_keys:
		level_selector.add_item(str(lk))
	level_selector.connect("item_selected", _on_level_key_selected)
	level_selector.selected = 0
	
	var cutscene_selector = $pause_menu/devtools/HFlowContainer/PanelContainer3/VBoxContainer/OptionButton
	for cs in cutscene_keys:
		cutscene_selector.add_item(str(cs))
	cutscene_selector.connect("item_selected", _on_cutscene_key_selected)
	
	var major_point_selector = $pause_menu/devtools/HFlowContainer/PanelContainer4/VBoxContainer/OptionButton
	for mp in Global.major_points:
		major_point_selector.add_item(str(mp))
	major_point_selector.connect("item_selected", _on_major_point_reached)
	
	var give_item_menu = $pause_menu/devtools/HFlowContainer/PanelContainer5/VBoxContainer/OptionButton
	for ik in Items.list.keys():
		give_item_menu.add_item(ik)
	give_item_menu.connect("item_selected", _on_give_item_key_selected)
	
	var spawn_entity_menu = $pause_menu/devtools/HFlowContainer/PanelContainer6/VBoxContainer/OptionButton
	for se in Global.entities.keys():
		spawn_entity_menu.add_item(se)
	spawn_entity_menu.connect("item_selected", _on_spawn_entity_key_selected)
	
	$pause_menu/devtools/HFlowContainer/sleepTest.connect("button_down", player_sleep)
	
	$pause_menu/devtools/HFlowContainer/giveFood.connect("button_down", PlayerInformation.pickup_item.bind(["dead_bat"]))
	
	$pause_menu/devtools/HFlowContainer/damage_test.connect("button_down", PlayerInformation.take_damage.bind(0.2,PlayerInformation.DAMAGE_DEV))
	
	$pause_menu/devtools/HFlowContainer/set_checkpoint.connect("button_down", _on_checkpoint_reached)
	
	$pause_menu/devtools/HFlowContainer/killbind.connect("button_down", PlayerInformation.die)
	
	$pause_menu/devtools/HFlowContainer/tp_ZERO.connect("button_down", PlayerInformation.tp.bind(Vector3.ZERO))
	
	$pause_menu/devtools/HFlowContainer/reset_level.connect("button_down", _on_kill_all_entities)
	
	$pause_menu/devtools/HFlowContainer/PanelContainer7/VBoxContainer/HSlider.connect("value_changed", set_time_of_day)
	

func set_time_of_day(val : float) -> void: #0.0 -> 1.0
	day_timer = day_length*val

func _on_kill_all_entities() -> void:
	for i in get_tree().get_nodes_in_group("entity"):
		if i.has_method("die"):
			i.die()
		else:
			i.call_deferred("queue_free")

func _on_give_item_key_selected(i : int) -> void:
	PlayerInformation.pickup_item([item_list_keys[i]])
	pass

func _on_cutscene_key_selected(i : int) -> void:
	play_cutscene(cutscene_keys[i])

func _on_player_scene_selected(i : int) -> void:
	change_player(player_stages[i])

func _on_level_key_selected(i : int) -> void:
	change_level(level_keys[i])

func _on_spawn_entity_key_selected(i : int) -> void:
	spawn_entity(entity_keys[i], PlayerInformation.position)

var inventory_open = false

@onready var inventory_menu = $inventory_menu
func set_inventory_open(val : bool) -> void:
	inventory_open = val
	inventory_menu.visible = val
	if val:
		Global.in_game_mouse = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		select_inventory_slot(inventory_menu.get_menu_selection())
		Global.in_game_mouse = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var action_menu_open = false

@onready var action_menu = $action_menu
func set_action_menu_open(val : bool) -> void:
	action_menu_open = val
	action_menu.visible = val
	if val:
		Global.in_game_mouse = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		select_action_index(action_menu.get_menu_selection())
		Global.in_game_mouse = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func select_action_index(i : int) -> void:
	print("action index selected " + str(i))
	match i:
		0:
			make_player_perform_action("rest")
		1:
			make_player_perform_action("sit")

func make_player_perform_action(key : String) -> void:
	print("making player perform action " + key)
	for p in playerHandler.get_children(false):
		p.perform_action(key)

func select_inventory_slot(i : int) -> void:
	if i >= PlayerInformation.inventory.size():
		print("invalid inventory slot selection")
		return
	PlayerInformation.change_held_item(i)
	#if i == -1:
		#player_sleep() 
	#elif i == 0:
		#_on_player_take_damage(0.25)
	pass

func update_debug_graphics() -> void:
	$debug_menu/left/paused.text = "paused = " + str(paused)
	$debug_menu/left/time_of_day.text = "time = " + get_time_of_day()
	$debug_menu/left/day_timer.text = "day_timer = " + str(round(day_timer))
	$debug_menu/left/health.text = "health = " + str(PlayerInformation.health) + " / " + str(PlayerInformation.max_health)
	$debug_menu/left/food.text = "food = " + str(PlayerInformation.food) + " / " + str(PlayerInformation.max_food) + "   min_for_sleep : " + str(PlayerInformation.min_sleep_food)
	$debug_menu/left/held_item.text = "held_item_data = " + str(PlayerInformation.get_held_item_data())
	$debug_menu/left/dash_charges.text = "dash_charges : " + str(PlayerInformation.current_dash) + " / " + str(PlayerInformation.max_dash)
	$debug_menu/left/velocity.text = "velocity = " + str(PlayerInformation.velocity)
	$debug_menu/left/speed.text = "speed = " + str(PlayerInformation.velocity.length())
	pass


func get_time_of_day() -> String:
	var tod = "midday"
	if day_timer > day_length*0.5:
		tod = "night"
		if day_timer > day_length*(0.9):
			tod = "dawn"
		elif day_timer < day_length*(0.6):
			tod = "dusk"
	elif day_timer > day_length*(0.5-0.125):
		tod = "evening"
	elif day_timer < day_length*0.125:
		tod = "morning"
	return tod

func _on_player_fall_asleep():
	print("fell asleep")
	player_sleep()
	pass

func player_sleep() -> bool: #weather or not you can sleep
	if PlayerInformation.min_sleep_food > PlayerInformation.food:
		print("you are too hungry to sleep")
		return false
	day_timer = 0.0
	print("player_slept")
	PlayerInformation.health = clamp(round(PlayerInformation.health-0.49) + 1.0, 0.0, PlayerInformation.max_health)
	PlayerInformation.food -= 2
	in_game_days += 1
	PlayerInformation.emit_signal("slept")
	_on_checkpoint_reached()
	return true

func _on_player_take_damage(amount : float) -> void:
	PlayerInformation.health -= amount
	pass

func use_held_item(special = false) -> void:
	for p in playerHandler.get_children(false):
		p.use_held_item(special)

var item_scene = preload("res://campaign/entities/loose_item.tscn")
func _on_dropped_item(data : Array, pos : Vector3) -> void:
	var i = item_scene.instantiate()
	i.data = data
	i.position = pos
	itemHandler.add_child(i)
	
	pass

func purge_world() -> void:
	for p in playerHandler.get_children(false):
		p.call_deferred("queue_free")
	for i in itemHandler.get_children(false):
		i.queue_free()
	for w in worldHandler.get_children(false):
		w.call_deferred("queue_free")
	for c in cutsceneHandler.get_children(false):
		c.call_deferred("queue_free")

##checkpoints and dying
func _on_player_death() -> void:
	print("player_died")
	#print("loading last checkpoint")
	#purge_world()
	#load_data_from_save()
	#start_game()

func _on_checkpoint_reached() -> void:
	print("checkpoint reached")
	save_game_data()

func _on_changed_using_senses() -> void:
	for light in get_tree().get_nodes_in_group("light"):
		light.visible = !PlayerInformation.using_senses
	
	if PlayerInformation.using_senses:
		play_sound("res://assets/sounds/misc_effects/senses_on.ogg")
	else:
		play_sound("res://assets/sounds/misc_effects/senses_off.ogg")
	
#	for sound_only in get_tree().get_nodes_in_group("")
	pass

func _on_dialogue(text, custom_time) -> void:
	$dialogue_popup_handler.set_new_dialogue(text, custom_time)
	pass

@onready var play_sound_handler = $playSoundHandler
func play_sound(path) -> void: #so there is not a bagillion sound_nodes for everything
	play_sound_handler.stream = load(path)
	play_sound_handler.play()
	pass

func _on_major_point_reached(key : int) -> void:
	print("major point reached, key = " + str(key))
	match key:
		Global.major_points.SKY_FALL: 
			play_cutscene("fall_into_world")
			PlayerInformation.tp(Vector3.ZERO)
			level = "stone_forest"
			pass
	pass



func _on_tooltip(text) -> void:
	$tooltip.set_new_tooltip(text)
