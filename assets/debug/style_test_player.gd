extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$player_01_wip_rig_test/AnimationPlayer.connect("animation_finished", play_anim)
	play_anim()
	pass # Replace with function body.

func play_anim(_old_anim : StringName = ""):
	$player_01_wip_rig_test/AnimationPlayer.play("walkF")
	pass
