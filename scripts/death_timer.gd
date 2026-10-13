extends Node3D
@export var life_time: float = 1.0

func _process(delta):
	life_time -= delta
	if life_time < 0.0:
		call_deferred("queue_free")
