extends Control

@onready var text_display = $PanelContainer/VBoxContainer/Label
func set_new_tooltip(text : String, linger_time : float = 0.5) -> void:
	if text == text_to_display:
		dialogue_timer = linger_time
		return #resets timer but does not retype
	working = true
	visible = true
	displayed_letter_count = 0
	letters_timer = 0.0
	text_to_display = text
	dialogue_timer = linger_time

var time_per_character:float = 0.05

var text_to_display = ""
var displayed_letter_count: int = 0
var working = false

func close_dialogue() -> void:
	working = false

var dialogue_timer:float = 0.0
var letters_per_second:float = 120
var letters_timer = 0.0

func _process(delta):
	visible = dialogue_timer > 0.0 #this way it does not need to retype if same tip
	if !working:
		if dialogue_timer > 0.0:
			dialogue_timer -= delta
			if dialogue_timer < 0.0:
				dialogue_timer = 0.0
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
