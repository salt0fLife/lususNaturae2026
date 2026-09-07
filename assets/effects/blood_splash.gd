class_name blood_splash extends Node3D

enum types {
	STANDARD_RED
}

const type_lookup:Dictionary = {
	types.STANDARD_RED : [
		5, #count
		"res://assets/materials/standard_blood_material.tres", #material
	]
}

static func new_splash(type : int, dir : Vector3, pos : Vector3):
	var bs = load("res://assets/effects/blood_splash.tscn").new()
	
	pass

var dir:Vector3 = Vector3.ZERO
var pos:Vector3 = Vector3.ZERO
var count: int = 5
var type : int = types.STANDARD_RED
func _enter_tree():
	plan_new_particles()
	pass

var particle_plans = []

func plan_new_particles():
	var mat = load(type_lookup[type][1])
	var m:Mesh = PlaneMesh.new()
	m.set("material",mat)
	
	for i in range(0,count):
		var mi = MeshInstance3D.new()
		mi.mesh = m
		add_child(mi)
		pass
	pass
