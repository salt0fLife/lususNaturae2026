extends AudioStreamPlayer3D
class_name soundEmitter


func _ready():
	visible = PlayerInformation.using_senses
	PlayerInformation.connect("changed_using_senses", update_visibility)

func update_visibility() -> void:
	visible = PlayerInformation.using_senses

func _process(delta):
	if playing:
		$graphics.visible = true
		$graphics.scale += Vector3.ONE * delta * 2.0
	else:
		$graphics.visible = false
		$graphics.scale = Vector3.ONE
