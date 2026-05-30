extends Control

var awaiting_event = false
signal found_event
var event_found

func _ready():
	$Panel/back.connect("button_down", close)
	pass


func save_settings():
	print("saved settings")
	pass

func close():
	save_settings()
	print("closing settings_menu")
	call_deferred("queue_free")

func _input(event):
	if awaiting_event:
		if event and !event.is_action_type():
			event_found = event
			emit_signal("found_event")
