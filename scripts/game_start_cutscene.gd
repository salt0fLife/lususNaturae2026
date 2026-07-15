extends Node

var timer = 0.0

var text = [
	["and those who were forsaken", 4.0],
	["and those who were forsaken\nran to the north", 4.0],
	["and those who were forsaken\nran to the north\nto the north of eden", 4.0],
	#["your vision is all warped a franctured like a memory", 2.5],
	#["you are in war", 1.2],
	#["you watch as your companion is caught in an explosion", 2.3],
	#["your outstretched arm is shredded in the shockwave", 2.3],
	#["you die",1.5],
	#["you wake up with bright lights and magic around you",2.3],
	##["you wake up in the enemy camp, restrained and surrounded by your dead comrads", 4.5],
	#["they mix blood with something glowing and inject you", 3.0],
	##["you vision fades red, and you wake up in a room full of dead scientists, blood on your TWO hands", 5.5],
	#["your vision fades red", 2.5],
	#["your about to wake up in an abandoned lab lol", 3.0]
]

signal end
func _ready():
	for t in text:
		$temp/Label.text = t[0]
		await get_tree().create_timer(t[1]).timeout
	emit_signal("end")

func default_load() -> void:
	
	
	pass
