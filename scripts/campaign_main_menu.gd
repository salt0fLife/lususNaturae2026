extends Node
var save_path = "campaign/saves/"

func _ready():
	MusicHandler.play_song("res://assets/sounds/music/menu_midi_test.wav")
	print("started campaign")
	$Control/Panel/back.connect("button_down", return_to_main_menu)
	$"Control/Panel/save info/continue game".connect("button_down", play_selected_save)
	populate_saves_list()
	$Control/Panel/create_new_save.connect("button_down", open_new_save_dialogue)
	$Control/Control/new_game_dialogue/confirm.connect("button_down", confirm_new_save_button_down)
	$Control/Control/new_game_dialogue/cancel.connect("button_down", hide_new_save_dialogue)
	$"Control/Panel/save info/delete_save".connect("button_down", open_delete_save_dialogue)
	$Control/delete_save_dialogue/new_game_dialogue/cancel.connect("button_down",close_delete_save_dialogue)
	$Control/delete_save_dialogue/new_game_dialogue/confirm.connect("button_down",confirm_and_delete_selected_save)
	$Control/Label.text = "version: " + str(Global.version)

var saves_list = [
	#[saveName, filepath, progress_percent, progress_summary, folder_name, version, seconds_played]
]


@onready var save_button_handler = $Control/Panel/PanelContainer/ScrollContainer/savesButtonHandler

func populate_saves_list() -> void:
	saves_list = []
	
	print("populating saves list")
	var saves = SaveHandler.get_saves_list(save_path)
	for folder in saves:
		var path = save_path + folder + "/"
		print(path)
		var info = SaveHandler.load_file(path, "preview.dat")
		info = JSON.parse_string(info)
		var data = [
			info["name"],
			path,
			info["progress_percent"],
			info["progress_summary"],
			folder,
			info["version"],
			info["seconds_played"],
			info["version"]
		]
		if info["active"]:
			saves_list += [data]
	
	for x in save_button_handler.get_children(false):
		x.queue_free()
	
	for i in range(0,saves_list.size()):
		var button_name = saves_list[i][0] + " | " + saves_list[i][4]
		var b = Button.new()
		if saves_list[i][7] != Global.version: #outdated version
			b.set("theme_override_colors/font_color", Color.INDIAN_RED)
		else:
			b.set("theme_override_colors/font_color", Color.WEB_GREEN)
		b.text = button_name
		b.connect("pressed", select_save.bind(i))
		b.connect("pressed", _on_button_pressed)
		b.connect("mouse_entered",_on_button_hovered)
		save_button_handler.add_child(b)
		

var selected_save = -1
func select_save(indx : int) -> void:
	selected_save = indx
	print("selected save of index " + str(indx))
	#[saveName, filepath, progress_percent, progress_summary, folder_name]
	var data = saves_list[indx]
	
	
	$"Control/Panel/save info/progress".value = data[2]
	$"Control/Panel/save info/RichTextLabel".text = data[3]
	$"Control/Panel/save info/selected save name".text = data[0]
	#$"Control/Panel/save info/continue game".disabled = false
	$"Control/Panel/save info/continue game".disabled = (data[7] != Global.version)
	$"Control/Panel/save info/Label3".text = "version: " + str(data[7])
	if (data[7] != Global.version):
		$"Control/Panel/save info/Label3".set("theme_override_colors/font_color", Color.RED)
	else:
		$"Control/Panel/save info/Label3".set("theme_override_colors/font_color", Color.LIGHT_GRAY)
	
	##DEBUG SAVE_INFO
	var save_filepath = saves_list[selected_save][1]
	var story_info = SaveHandler.load_file(save_filepath,"story_info.dat")
	$"Control/Panel/save info/RichTextLabel".text = str(story_info)

func play_selected_save() -> void:
	if selected_save < 0:
		return #yeah that should never happen but just in case
	print("playing save of index " + str(selected_save))
	print("loading game from filepath " + saves_list[selected_save][1])
	Global.save_filepath = saves_list[selected_save][1]
	
	#get_tree().call_deferred("change_scene_to_file", "res://campaign/campaign_main.tscn")
	
	
	game_status = 0.0
	scene_to_change_to = "res://campaign/campaign_main.tscn"
	ResourceLoader.load_threaded_request(scene_to_change_to)
	starting_game = true

var game_status = 0.0
var starting_game = false
var scene_to_change_to = ""
@onready var loading_screen = $Control/loading_screen
func _process(delta):
	if starting_game:
		if !ResourceLoader.has_cached(scene_to_change_to):
			print("well thats a problem")
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(scene_to_change_to, progress)
		print("game progress : " + str(progress[0]))
		game_status = lerp(game_status,float(progress[0]),delta*10.0)
		if game_status > 0.99 and progress[0] == 1:
			game_status = 1.0
		print("game status : " + str(game_status))
		loading_screen.visible = true
		loading_screen.update_progress(game_status)
		if ResourceLoader.THREAD_LOAD_LOADED and game_status == 1.0:#progress[0] >= 1.0:
			starting_game = false
			#get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_to_change_to))
			get_tree().call_deferred("change_scene_to_packed",ResourceLoader.load_threaded_get(scene_to_change_to))
			#return #finished loading

func return_to_main_menu():
	get_tree().call_deferred("change_scene_to_file", "res://menus/main_menu.tscn")

func create_new_save(save_name := "A brand new adventure!") -> void:
	var data = {
		"name" : save_name,
		"progress_percent" : 0.0,
		"progress_summary" : "you have not played this save yet",
		"active" : true,
		"version" : Global.version,
		"seconds_played" : 0
	}
	data = JSON.stringify(data)
	
	var file_name = str(Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(false), false))
	file_name = file_name.erase(13,1)
	file_name = file_name.erase(15,1)
	
	SaveHandler.save_file(save_path+file_name+"/", "preview.dat", data)
	
	populate_saves_list()

func open_new_save_dialogue():
	$Control/Control.show()
	pass

func confirm_new_save_button_down():
	var t = $Control/Control/new_game_dialogue/LineEdit.text
	if t == "":
		create_new_save()
	else:
		create_new_save(t)
	hide_new_save_dialogue()

func hide_new_save_dialogue():
	$Control/Control.visible = false
	$Control/Control/new_game_dialogue/LineEdit.text = ""
	pass

func delete_save(indx : int) -> void: #just sets active to false in preview
	print("deleted save : " + str(indx))
	var path = saves_list[indx][1]
	var data = SaveHandler.load_file(path,"preview.dat")
	data = JSON.parse_string(data)
	data["active"] = false
	data= JSON.stringify(data)
	SaveHandler.save_file(path,"preview.dat",data)
	
	populate_saves_list()

func open_delete_save_dialogue():
	var data = saves_list[selected_save]
	var seconds = data[6]
	var save_name = data[0]
	$Control/delete_save_dialogue/new_game_dialogue/Label3.text = save_name
	var abrev_time = Global.get_abreviated_time(seconds)
	$Control/delete_save_dialogue/new_game_dialogue/Label2.text = "you have " + abrev_time + " on record"
	
	
	$Control/delete_save_dialogue.show()
	pass

func close_delete_save_dialogue():
	$Control/delete_save_dialogue.hide()
	pass

func confirm_and_delete_selected_save():
	delete_save(selected_save)
	close_delete_save_dialogue()

func _on_button_hovered():
	$button_hovered.play()

func _on_button_pressed():
	$button_clicked.play()
