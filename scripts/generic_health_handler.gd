extends Node
class_name health_handler
@export var max_health : int = 100
@onready var health : int = max_health
signal death #(limb, type)
signal limb_death #(limb, type)
signal took_damage #(amount)

signal changed_resistances
const resistances = { #0.0 == no resistance, 1.0 == 100% damage negation
	Global.damage_types.BLEED : 1.0,
	Global.damage_types.SLICE : -0.1, #takes 10% more damage from slice
}

func _on_took_damage(amount,type:int,limb:StringName) -> void:
	if amount == 0:
		return
	if health - amount <= 0:
		health = max_health
		emit_signal("death",limb,type)
		limbs_health = limbs_max_health.duplicate()
	else:
		emit_signal("took_damage",amount)
		if limbs_health.has(limb):
			if limbs_health[limb] > 0.0: #is already dead
				limbs_health[limb] -= amount
				if limbs_health[limb] < 0.0:
					emit_signal("limb_death",limb,type)
		health -= amount

func _on_limb_death(limb : StringName, type : int):
	emit_signal("limb_death",limb,type)

func heal_limb(limb : StringName) -> void:
	if limbs_health.has(limb):
		limbs_health[limb] = limbs_max_health[limb]

var limbs_health = {}
var limbs_max_health = {}

func register_hurtbox(hb):
	hb.connect("took_damage", _on_took_damage)
	if !limbs_health.has(hb.limb_key): #so it does not overwrite
		limbs_health[hb.limb_key] = hb.limb_health
	limbs_max_health[hb.limb_key] = hb.limb_health #dont care max health shouldnt change per limb

