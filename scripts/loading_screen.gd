extends Control

func _ready():
	$Control/AnimatedSprite2D.play()

func update_progress(val : float):
	$ProgressBar.value = val*100.0
	pass

func update_mode(text_mode = false, text = "loading"):
	$ProgressBar.visible = !text_mode
	$Label.text = text
	$Label.visible = text_mode
	
	pass
