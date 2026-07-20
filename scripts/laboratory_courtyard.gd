extends Node3D

func _ready():
	if Global.cutscenes_watched.has("gate_warden_introduction"):
		$skeleton_king_wip/AnimationPlayer.play("idle")
	else:
		$skeleton_king_wip/AnimationPlayer.play("dormant")
	pass

func _on_area_3d_body_entered(body):
	if !Global.major_points_reached.has(Global.major_points.GATE_WARDEN_DEFEATED):
		start_boss_fight()
	pass # Replace with function body.

func start_boss_fight():
	if !Global.cutscenes_watched.has("gate_warden_introduction"):
		#Global.play_cutscene("gate_warden_introduction")
		$skeleton_king_wip/AnimationPlayer.play("wakeUp")
		if !Global.cutscenes_watched.has("gate_warden_introduction"): #kind o jank but whatever lol
			Global.cutscenes_watched.append("gate_warden_introduction")
	pass
