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
var fade_in = 0.0
func set_background(texture : Texture) -> void:
	$TextureRect.texture = texture
	fade_in = 1.0
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if fade_in > 0.0:
		fade_in -= delta
		$ColorRect.color = Color(0.0,0.0,0.0,fade_in)
		if fade_in < 0.0:
			fade_in = 0.0
			$ColorRect.color = Color(0.0,0.0,0.0,fade_in)
			process_mode = Node.PROCESS_MODE_DISABLED

