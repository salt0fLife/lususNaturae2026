extends Node
@export var group_name : StringName
var subfolder = "entity_groups/"


func load_data(filepath):
	var data = SaveHandler.load_file(filepath+subfolder, group_name + ".dat")
	print(data)
	if data == null:
		print("no data for entity group " + group_name)
		return
	if data.keys().has("foo"):
		print(data["foo"])

func save_data(filepath) -> void:
	if !is_valid_name(group_name):
		printerr("invalid group_name")
		return
	print("saved entity group data")
	var data = {"foo" : "an alternative message!"}#{"foo" : "hello beautiful world!"}
	SaveHandler.save_file(filepath+subfolder, group_name + ".dat", data)
	pass

func is_valid_name(gn : StringName) -> bool:
	if gn =="":
		return false
	return gn.is_valid_filename()
