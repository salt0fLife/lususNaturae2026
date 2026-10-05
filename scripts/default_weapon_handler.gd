extends Node3D

signal dealt_damage
@onready var sword_area = $sword_slash

func item_damage(item_data : Array) -> void:
	
	
	pass

func sword_slash() -> void:
	print("sword_slashing")
	var item_data = PlayerInformation.get_held_item_data()
	if item_data.is_empty():
		return
	
	var damage_amount:int
	var damage_type:int
	
	match item_data[Items.INDEX_TYPE]:
		Items.type.SWORD:
			var item_info = item_data[Items.INDEX_DATA]
			#[attack_speed, damage, damage_type, vfx_method_name]
			damage_amount = item_info[1]
			damage_type = item_info[2]
			if has_method(item_info[3]):
				call(item_info[3])
		_:
			return
	
	print("dealing damage")
	
	for hit in sword_area.get_overlapping_bodies():
		if hit.has_method("take_damage"):
			print("found hit " + str(hit))
			var true_amount = hit.take_damage(damage_amount,damage_type)
			on_dealt_damage(true_amount,damage_type)
	pass

func on_dealt_damage(amount,type):
	emit_signal("dealt_damage",amount,type)
