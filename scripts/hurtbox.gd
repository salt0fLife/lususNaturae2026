extends StaticBody3D
class_name hurtbox
@export var health_handler : Node
@export var limb_key : StringName 
@export var limb_health : int = 1
@export var damage_multiplier : float = 1.0

func _ready():
	if health_handler != null:
		health_handler.register_hurtbox(self)
		pass

func update_resistances() -> void:
	pass

func take_damage(amount : int,type : int) :
	var dealt = get_real_amount(amount,type)
	emit_signal("took_damage",dealt,type,limb_key)
	return dealt

signal took_damage #(amount,type,limb)

func get_real_amount(amount : int, type : int):
	var val = float(amount) * damage_multiplier
	if health_handler == null:
		return amount #just in case
	if health_handler.resistances.has(type):
		val -= val*health_handler.resistances[type]
		print("resistances found, " + str(amount) + " dealt, " +str(int(val)) + " recieved")
	return int(val)
