extends Node3D
var sounds = [
	"res://assets/sounds/footsteps/snow/snow1.wav",
	"res://assets/sounds/footsteps/snow/snow2.wav",
	"res://assets/sounds/footsteps/snow/snow3.wav",
	"res://assets/sounds/footsteps/snow/snow4.wav"
	
]

var timer = 0.0
var time_to_play = 2.0
func _process(delta):
	timer += delta
	if timer > time_to_play:
		timer = 0.0
		time_to_play = randf_range(1.0,4.0)
		$soundEmitter.stream = load(sounds.pick_random())
		$soundEmitter.play()
