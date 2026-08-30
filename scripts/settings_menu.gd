extends Control

var awaiting_event = false
signal found_event
var event_found
var graphics_changes = {}
var controls_changes = {}

func _ready():
	$Panel/back.connect("button_down", close)
	pass

func save_settings():
	
	pass

func close():
	save_settings()
	call_deferred("queue_free")
