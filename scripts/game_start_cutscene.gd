extends Node

var timer = 0.0

var text = [
	["you are in war", 1.2],
	["you watch as your companion is caught in an explosion", 2.3],
	["your outstretched arm is shredded in the shockwave", 2.3],
	["you wake up in the enemy camp, restrained and surrounded by your dead comrads", 4.5],
	["they mix blood with something glowing and inject you", 3.0],
	["you vision fades red, and you wake up in a room full of dead scientists, blood on your TWO hands", 5.5],
]

signal end
func _ready():
	for t in text:
		$temp/Label.text = t[0]
		await get_tree().create_timer(t[1]).timeout
	emit_signal("end")

func default_load() -> void:
	
	
	pass
