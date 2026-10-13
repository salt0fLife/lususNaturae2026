extends Node3D

@onready var limbo_entrances_gates = [
	$CSGCombiner3D/CSGBox3D3,
	$CSGCombiner3D/CSGBox3D10,
	$CSGCombiner3D/CSGBox3D11,
	$CSGCombiner3D/CSGBox3D12,
	$CSGCombiner3D/CSGBox3D13,
	$CSGCombiner3D/CSGBox3D14
]

func _ready():
	var entrances = Global.limbo_entrances_unlocked
	print(entrances)
	for i in range(0,limbo_entrances_gates.size()):
		limbo_entrances_gates[i].visible = Global.limbo_entrances_unlocked.has(i)


