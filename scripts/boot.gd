extends Node

#this is the first scene loaded

func _ready(): #this is only called when the game is launched, never again
	print("running test")
	
	
	print("did the boot stuff")
	get_tree().call_deferred("change_scene_to_file", "res://menus/main_menu.tscn")
