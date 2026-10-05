extends Node


##all the functions for saving and loading data
var savePath = "res://tempSave/"


func save_file(subFolder : String, fileName : String, data) -> void:
	if !DirAccess.dir_exists_absolute(savePath+subFolder):
		DirAccess.make_dir_recursive_absolute(savePath+subFolder)
	var path = savePath+subFolder+fileName
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	print("saved " + fileName)

func load_file(subFolder : String, fileName : String):
	var path = savePath+subFolder+fileName
	if !DirAccess.dir_exists_absolute(savePath+subFolder):
		printerr("tried to load from nonexistant directory")
		return null
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		print("loaded " + fileName)
		return data
	else:
		printerr("tried to load nonexistant file")
		return null

func get_saves_list(subfolder : String):
	var folders = []
	var directory_path = savePath + subfolder
	if !DirAccess.dir_exists_absolute(directory_path):
		DirAccess.make_dir_recursive_absolute(directory_path)
		print("first time loaded, setting up directories")
	for f in DirAccess.get_directories_at(directory_path):
		folders += [f]
	return folders

func get_files_at_path(path : String):
	if !DirAccess.dir_exists_absolute(path):
		printerr("invalid save path provided of * " + path + " *")
	return DirAccess.get_files_at(path)

func does_file_exist(path : String) -> bool:
	return FileAccess.file_exists(path)
