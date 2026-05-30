extends Node3D


var has_entered_senses_mode = false
func _on_area_3d_body_exited(body):
	if !has_entered_senses_mode:
		Global.new_dialogue_box("press  *TAB*  to enter 'senses' mode\nthis will allow you to navigate dark spaces and track enemies as well as food.", 80.0)
	pass # Replace with function body.

func _ready():
	PlayerInformation.connect("changed_using_senses", _on_changed_using_senses)
	pass

func _on_changed_using_senses() -> void:
	if has_entered_senses_mode:
		return
	has_entered_senses_mode = true
	Global.new_dialogue_box("you can also press  *TAB*  again to toggle senses off\nthis can be to look light you would not otherwise see")
	pass


func _on_exit_outside_door_trigger_body_entered(body): #rather jank but it will work for now
	Global.major_point_reached(Global.major_points.SKY_FALL)
	#var p = get_tree().get_first_node_in_group("player")
	#p.tp(Vector3.ZERO, Vector2.ZERO)
	#await  get_tree().process_frame
	#Global.new_dialogue_box("you left the dark rooms!\nwelcome to the surface!")
	#Global.change_level_from_key("stone_forest")
	
	
	pass # Replace with function body.
