class_name surface_impact extends Node3D
enum {
	STONE,
	WOOD,
	DIRT,
	NONE,
}


static func new_impact(type : int, dir : Vector3) -> surface_impact:
	var si = load("res://assets/effects/surface_impact.tscn").instantiate()
	var rot = Global.dir_to_rot(dir)
	si.rotation.x = rot.x
	si.rotation.y = rot.y
	si.create_effects_for_type(type)
	return si

var life_time = 4.0
func create_effects_for_type(type : int):
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
		WOOD:
			var t = Label3D.new()
			t.text = "wood chips here"
			t.position.y = 0.2
			add_child(t)
			add_child(load("res://assets/debug/visualization_arrow.tscn").instantiate())
			#print("surface_collision wood")
		DIRT:
			var t = Label3D.new()
			t.text = "dirt clumps here"
			t.position.y = 0.2
			add_child(t)
			add_child(load("res://assets/debug/visualization_arrow.tscn").instantiate())
			#print("surface_collision dirt")
	pass

func _process(delta):
	life_time -= delta
	if life_time < 0.0:
		print("freed from queue")
		queue_free()
