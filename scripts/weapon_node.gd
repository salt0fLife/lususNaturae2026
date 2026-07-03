extends Node3D


func slash_close(damage_amount : int, damage_type : int, vfx_method : StringName, special : bool) -> void:
	var hits = []
	var hit_positions : PackedVector3Array = []
	for r in $slash_close.get_children(false):
		if r.is_colliding():
			var c = r.get_collider()
			if !hits.has(c):
				hits += [c]
				hit_positions.append(r.get_collision_point())
	
	for h in hits:
		if h.has_method("take_damage"):
			h.take_damage(damage_amount,damage_type)
	
	if has_method(vfx_method):
		call(vfx_method, special, hit_positions)
	pass

@onready var slash_mesh = $effects/standard_slash/MeshInstance3D
@onready var slash_mat = $effects/standard_slash/MeshInstance3D.get_active_material(0)
func standard_slash(towards_right : bool, impact_points : PackedVector3Array) -> void:
	print("standard_slash")
	if towards_right:
		slash_mesh.rotation.z = -0.17
	else:
		slash_mesh.rotation.z = 0.17+PI
	var tween = get_tree().create_tween()
	slash_mat.set("shader_parameter/progress", 0.0)
	tween.tween_property(slash_mat, "shader_parameter/progress", 1.0, 0.25)
	
	

@onready var hitscan = $hitscan
func get_hitscan_info() -> Array:
	if hitscan.is_colliding():
		var hit = hitscan.get_collider()
		var poi = hitscan.get_collision_point()
		var norm = hitscan.get_collision_normal()
		return [[hit,poi,norm]]
	return []

func shoot_bullet_hitscan(damage_amount : int, damage_type : int) -> void:
	var hits = get_hitscan_info()
	for h in hits:
		if h[0].has_method("take_damage"):
			print("applied " +str(damage_amount) + " damage of type " + str(damage_type))
			h[0].take_damage(damage_amount,damage_type) #(amount, type)
		else:
			var decal = load("res://assets/effects/decals/bullet_hole_default.tscn").instantiate()
			decal.position = h[1]
			var norm = h[2]
			decal.rotation.y = atan2(norm.x, norm.z)
			decal.rotation.x = atan2(sqrt(norm.z*norm.z+norm.x*norm.x),norm.y)
			Global.create_decal(decal)
			print("hit surface with info of " + str(Global.get_surface_info(h[0].get_groups())))
	pass

##visual effects
