@tool
extends Area3D
@export var damage_amount : int = 10
@export var damage_type : Global.damage_types


func _ready():
	if Engine.is_editor_hint():
		update_debug_render(true)
	else:
		Global.connect("update_debug_render",update_debug_render)
		update_debug_render(Global.debug_render)

func update_debug_render(val : bool) -> void:
	var mat = load("res://assets/materials/world_trigger_material.tres")
	for node in get_children():
		if node is CollisionShape3D:
			for old in node.get_children(false):
				if old is MeshInstance3D:
					old.queue_free()
			if node.shape != null and val:
				var shape = node.shape
				var mi = MeshInstance3D.new()
				match shape.get_class():
					"BoxShape3D":
						mi.mesh = BoxMesh.new()
						mi.mesh.size = shape.size
					"SphereShape3D":
						mi.mesh = SphereMesh.new()
						mi.mesh.radius = shape.radius
						mi.mesh.height = shape.radius*2.0
					"CapsuleShape3D":
						mi.mesh = CapsuleMesh.new()
						mi.mesh.radius = shape.radius
						mi.mesh.height = shape.height
					_:
						mi.mesh = load("res://assets/meshes/debug_object.obj")
						print("unemplemented shape")
				mi.material_override = mat
				node.add_child(mi)




func _on_body_entered(body): #i dont wanna talk about it
	print(body)
	if body.has_method("take_damage"):
		body.take_damage(damage_amount,damage_type)
	else:
		printerr("hurtbox node missing take_damage method : " + str(body))


func _on_area_entered(area):
	_on_body_entered(area) #yeah yeah i know i know
