class_name surface_impact extends Node3D
enum {
	STONE,
	WOOD,
	DIRT,
	NONE,
}

var particle_handler
var audio_player

static func new_impact(type : int, dir : Vector3) -> surface_impact:
	var si = load("res://assets/effects/surface_impact.tscn").instantiate()
	var rot = Global.dir_to_rot(dir)
	si.rotation.x = rot.x
	si.rotation.y = rot.y
	si.create_effects_for_type(type)
	return si

var life_time = 4.0
var gravity = 0.02
func create_effects_for_type(type : int):
	settup()
	match type:
		NONE:
			life_time = 0.0
		STONE:
			var t = Label3D.new()
			t.text = "stone chunks and sparks here"
			t.position.y = 0.2
			add_child(t)
			add_child(load("res://assets/debug/visualization_arrow.tscn").instantiate())
			#print("surface_collision stone")
			create_debug_particles(5)
		WOOD:
			var t = Label3D.new()
			t.text = "wood chips here"
			t.position.y = 0.2
			add_child(t)
			add_child(load("res://assets/debug/visualization_arrow.tscn").instantiate())
			#print("surface_collision wood")
			create_debug_particles(20)
		DIRT:
			var t = Label3D.new()
			t.text = "dirt clumps here"
			t.position.y = 0.2
			add_child(t)
			add_child(load("res://assets/debug/visualization_arrow.tscn").instantiate())
			#print("surface_collision dirt")
			create_debug_particles(10)
	pass

func settup():
	var ph = Node3D.new()
	add_child(ph)
	particle_handler = ph
	var ap = AudioStreamPlayer3D.new()
	add_child(ap)
	audio_player = ap

func rand_vec3(min:float,max:float) -> Vector3:
	var x:float = randf_range(min,max)
	var y:float = randf_range(min,max)
	var z:float = randf_range(min,max)
	return Vector3(x,y,z)

func create_debug_particles(count : int = 5) -> void:
	var bm = BoxMesh.new()
	bm.size = Vector3(0.1,0.1,0.1)
	for i in range(0,count):
		var m = MeshInstance3D.new()
		m.mesh = bm
		m.position += rand_vec3(-0.2,0.2)
		m.position.y = randf_range(0.1,0.2)
		particle_handler.add_child(m)

func _process(delta):
	move_particles(delta)
	life_time -= delta
	if life_time < 0.0:
		print("freed from queue")
		queue_free()

func move_particles(delta:float) -> void:
	for p in particle_handler.get_children(false):
		p.position += p.position.normalized() * delta
		p.global_position.y -= gravity*delta
