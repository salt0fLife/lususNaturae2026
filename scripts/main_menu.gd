extends Node

func _ready():
	#MusicHandler.play_song("res://assets/sounds/music/menu_midi_test.wav")
	$control/Panel/VBoxContainer/campaign.connect("button_down", play_campaign)
	$control/Panel/VBoxContainer/multiplayer.connect("button_down", play_multiplayer)
	$control/Panel/VBoxContainer/settings.connect("button_down", open_settings)
	$control/Panel/VBoxContainer/quit.connect("button_down", save_and_quit)
	
	$control/Panel/VBoxContainer/campaign.connect("mouse_entered", _on_button_hovered)
	$control/Panel/VBoxContainer/multiplayer.connect("mouse_entered", _on_button_hovered)
	$control/Panel/VBoxContainer/settings.connect("mouse_entered", _on_button_hovered)
	$control/Panel/VBoxContainer/quit.connect("mouse_entered", _on_button_hovered)

func save_and_quit():
	print("quit the right way")
	get_tree().call_deferred("quit", 1)

func open_settings() -> void:
	print("opened settings menu")
	var s = load("res://menus/settings_menu.tscn").instantiate()
	add_child(s)
	pass

func play_campaign() -> void:
	$button_clicked.play()
	await $button_clicked.finished
	
	print("opening campaign menu")
	get_tree().call_deferred("change_scene_to_file", "res://campaign/campaign_main_menu.tscn")
	pass

func play_multiplayer() -> void:
	printerr("multiplayer not implemented yet")

func _on_button_hovered() -> void:
	print("button hovered")
	$button_hovered.play()
	pass
