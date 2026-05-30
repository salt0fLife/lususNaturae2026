extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	load_level_data()
	if has_slept_before:
		extinguish_first_rest()
	PlayerInformation.connect("slept", _on_player_slept)
	

func load_level_data() -> void:
	var level_data = SaveHandler.load_file(Global.save_filepath+"levels_data/", "level_1_data.dat")
	if level_data == null:
		level_data = {
			"has_slept_before" : false
		}
	
	has_slept_before = level_data["has_slept_before"]


var has_slept_before = false
func _on_player_slept():
	if !has_slept_before:
		has_slept_before = true
		extinguish_first_rest()
	pass

func extinguish_first_rest():
	print("extinguished first rest")
	$Area3D.queue_free()
	var level_data = {
	"has_slept_before" : has_slept_before
	}
	SaveHandler.save_file(Global.save_filepath+"levels_data/", "level_1_data.dat", level_data)
