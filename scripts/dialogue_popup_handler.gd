extends Control

@onready var text_display = $Panel/RichTextLabel
func set_new_dialogue(text : String, custom_time : float) -> void:
	working = true
	visible = true
	displayed_letter_count = 0
	letters_timer = 0.0
	text_to_display = text
	if custom_time == 0.0:
		custom_time = (text_to_display.length() * time_per_character)
	dialogue_timer = custom_time
	pass

var time_per_character:float = 0.05

var text_to_display = ""
var displayed_letter_count: int = 0
var working = false

func close_dialogue() -> void:
	visible = false
	working = false

var dialogue_timer:float = 0.0
var letters_per_second:float = 120
var letters_timer = 0.0

func _process(delta):
	if !working:
		return
	if dialogue_timer > 0.0:
		if displayed_letter_count < text_to_display.length():
			letters_timer += delta * letters_per_second
			displayed_letter_count = int(letters_timer)
			$AudioStreamPlayer.play()
		update_text_display()
		dialogue_timer -= delta
		if dialogue_timer < 0.0:
			dialogue_timer = 0.0
			close_dialogue()

func update_text_display() -> void:
	text_display.text = text_to_display.left(displayed_letter_count)
