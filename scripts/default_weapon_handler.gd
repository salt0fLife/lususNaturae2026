extends Node3D

signal dealt_damage
@onready var sword_area = $sword_slash
@onready var wall_check = $wall_check
@export var player_main : CharacterBody3D
@export var pogo_strength : float = 4.0

func item_damage(item_data : Array) -> void:
	
	
	pass

func sword_slash() -> void:
	if wall_check.is_colliding() and !player_main.is_on_floor():
		player_main.velocity -= player_main.get_look_dir() * pogo_strength
		pass
	#print("sword_slashing")
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
	
	#print("dealing damage")
	
	for hit in sword_area.get_overlapping_bodies():
		if hit.has_method("take_damage"):
			#print("found hit " + str(hit))
			var true_amount = hit.take_damage(damage_amount,damage_type)
			on_dealt_damage(true_amount,damage_type)
	check_for_sword_impacts()

func on_dealt_damage(amount,type):
	emit_signal("dealt_damage",amount,type)

func check_for_sword_impacts() -> void:
	var impacts:Array[Array] = []
	for r in $sword_impacts_check.get_children(false):
		if r.is_colliding():
			var surface = Global.get_surface_info(r.get_collider().get_groups())
			var d = [r.get_collision_point(),surface[Global.WEAPON_HIT_EFFECT]]
			impacts.append(d)
	
	for i in impacts:
		var dir = -player_main.get_look_dir()
		var pos = i[0]
		var type = i[1]
		Global.new_impact(type,dir,pos)
