extends Node
var save_path = "campaign/saves/"

func _ready():
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
			info["seconds_played"]
		]
		if info["active"]:
			saves_list += [data]
	
	for x in save_button_handler.get_children(false):
		x.queue_free()
	
	for i in range(0,saves_list.size()):
		var button_name = saves_list[i][0] + " | " + saves_list[i][4]
		var b = Button.new()
		b.text = button_name
		b.connect("pressed", select_save.bind(i))
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
	$"Control/Panel/save info/continue game".disabled = false

func play_selected_save() -> void:
	if selected_save < 0:
		return #yeah that should never happen but just in case
	print("playing save of index " + str(selected_save))
	print("loading game from filepath " + saves_list[selected_save][1])
	Global.save_filepath = saves_list[selected_save][1]
	
	get_tree().call_deferred("change_scene_to_file", "res://campaign/campaign_main.tscn")

func return_to_main_menu():
	get_tree().call_deferred("change_scene_to_file", "res://menus/main_menu.tscn")

func create_new_save(save_name := "A brand new adventure!") -> void:
	var data = {
		"name" : save_name,
		"progress_percent" : 0.0,
		"progress_summary" : "you have not played this save yet",
		"active" : true,
		"version" : "early-dev",
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

