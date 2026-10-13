extends CPUParticles3D
@export var life_time: float = 1.0
@export var auto_emitting : bool = false

func _ready():
	if auto_emitting:
		emitting = true

func _process(delta):
	life_time -= delta
	if life_time < 0.0:
		call_deferred("queue_free")
