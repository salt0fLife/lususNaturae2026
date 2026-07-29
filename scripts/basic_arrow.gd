extends CharacterBody3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 0.98
@export var drag = 0.1
@onready var graphics = $graphics
func _physics_process(delta):
	velocity.y -= gravity * delta
	var col = move_and_collide(velocity,false)
	velocity -= velocity*drag*delta
	var rot = Global.dir_to_rot(velocity.normalized())
	graphics.rotation.x = rot.x
	graphics.rotation.y = rot.y
	
	if col != null:
		print("collided")
		print(col.get_collider_id(0))
		
		var pos = col.get_position(0)
		var norm = col.get_normal(0)
		var decal = load("res://assets/items/arrows/arrow_ph.glb").instantiate()
		#decal.position = pos - norm
		#var r = Global.dir_to_rot(norm)
		#decal.rotation.x=r.x
		#decal.rotation.y=r.y
		decal.rotation = graphics.rotation
		decal.position = $graphics/Node3D/arrow_ph.global_position
		Global.create_decal(decal)
		
		emit_signal("hit_target",0.0,1,null)
		queue_free()


#func get_data() -> Array:
	#
	#pass

var ruler = null
func set_ruler(new_ruler):
	ruler = new_ruler
	connect("hit_target",ruler._on_projectile_hit_enemy)

func set_arrow_type(key:StringName):
	
	pass


signal hit_target

func set_custom_data(custom_data): #[type of arrow(item_key), ruler_node]
	set_ruler(custom_data[1])
	set_arrow_type(custom_data[0])
	pass
