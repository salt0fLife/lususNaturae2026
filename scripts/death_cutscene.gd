extends Node


func _ready():
	#AnimatedSprite2D.new()
	#$Control2/Control/AnimatedSprite2D.play()
	$AnimationPlayer.play("death")

func update_life_info():
	$extra_info/RichTextLabel.text = str(Global.cutscenes_watched)
	$extra_info/RichTextLabel2.text = str(Global.major_points_reached)
	$extra_info/Label.text = str(Global.progression)
	$extra_info.visible = true
