@icon("res://assets/textures/icons/hurtbox.svg")
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
	update_debug_render(Global.debug_render)
	Global.connect("update_debug_render",update_debug_render)

func update_resistances() -> void:
	pass

func take_damage(amount : int,type : int) -> int:
	var dealt = get_real_amount(amount,type)
	emit_signal("took_damage",dealt,type,limb_key)
	Global.indicate_damage(dealt,type,global_position)
	return dealt

signal took_damage #(amount,type,limb)

func get_real_amount(amount : int, type : int) -> int:
	var val = float(amount) * damage_multiplier
	if health_handler == null:
		return amount #just in case
	if health_handler.resistances.has(type):
		val -= val*health_handler.resistances[type]
		print("resistances found, " + str(amount) + " dealt, " +str(int(val)) + " recieved")
	return int(val)


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
