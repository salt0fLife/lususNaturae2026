extends Node

##my normal global script, any data about the world or any variables that need global reference
#ie, day_timer, all monster statistics, questlines, etc...

var save_filepath = "" #specifically the path to the save you are playing on

signal change_level
func change_level_from_key(key : String) -> void:
	emit_signal("change_level", key)

signal reached_major_point
func major_point_reached(key : int) -> void:
	emit_signal("reached_major_point", key)

enum major_points {
	SKY_FALL
}

const levels: Dictionary = {
	"debug" : ["res://campaign/levels/debug_level.tscn"],
	"debug_v2" : ["res://campaign/levels/debug_level_v2.tscn"],
	"level_01" : ["res://campaign/levels/level_1.tscn"],
	"level_001" : ["res://campaign/levels/level_001.tscn"],
	"lighting_test" : ["res://campaign/levels/baked_lighting_test_level.tscn"],
	"dark_rooms" : ["res://campaign/levels/dark_rooms.tscn"],
	"stone_forest" : ["res://campaign/levels/stone_forest.tscn"]
}

var levels_persistent_data: Dictionary = {
	"debug" : [[],[]], #[lose_items, decals, entities]
}

const cutscenes: Dictionary = {
	"new_game_start" : ["res://campaign/cutscenes/game_start_cutscene.tscn", 4.0], #path seconds long
	"fall_into_world" : ["res://campaign/cutscenes/falling_into_world_cutscene.tscn", 4.0]
}

var progression:int = 0 #keeps track of various important events

var cutscenes_watched: Array = []


func get_abreviated_time(seconds : int) -> String:
	var abrev_time = ""
	if seconds < 60:
		abrev_time = "' " + str(seconds) + " seconds '"
	else:
		var minutes = round(float(seconds) / 60.0)
		if minutes < 60:
			abrev_time = "' " + str(minutes) + " minutes '"
		else:
			var hours = round(minutes / 60.0)
			abrev_time = "' " + str(hours) + " hours"
	return abrev_time

var in_game_mouse = false #mouse visible while playing, ie in inventory

enum interact_returns {
	PICKUP_ITEM, #includes path_to loose_item node
	DO_NOTHING, #no action needed (should be pretty rare)
}

signal dialogue
func new_dialogue_box(text : String, custom_time : float = 0.0) -> void:
	if text == "":
		return
	emit_signal("dialogue", text, custom_time)
	pass

##world stuff
enum {
	DIRT_KEY,
	GRASS_KEY,
	METAL_KEY,
	STONE_KEY,
	WOOD_KEY
}

enum {
	STEP_SOUNDS,
}

const surface_lookup = { #this way i can bundle more info in if i need
	"dirt" : {
		STEP_SOUNDS : DIRT_KEY,
	},
	"stone" : {
		STEP_SOUNDS : STONE_KEY,
	},
	"grass" : {
		STEP_SOUNDS : GRASS_KEY,
	},
	"metal" : {
		STEP_SOUNDS : METAL_KEY,
	},
	"wood" : {
		STEP_SOUNDS : WOOD_KEY,
	},
	"default" : {
		STEP_SOUNDS : STONE_KEY
	}
	
}

const surface_step_sounds = {
	DIRT_KEY : ["res://assets/sounds/footsteps/dirt/footstepDirt1.wav",
	"res://assets/sounds/footsteps/dirt/footstepStone2.wav"
	],
	GRASS_KEY : [
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep1.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep2.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep3.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep4.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep5.ogg"
	],
	METAL_KEY : [
		"res://assets/sounds/footsteps/metal/footstepMatal3.wav"
	],
	STONE_KEY : [
		"res://assets/sounds/footsteps/stone/footstepStone1.wav",
		"res://assets/sounds/footsteps/stone/footstepStone2.wav",
		"res://assets/sounds/footsteps/stone/footstepStone4.wav"
	],
	WOOD_KEY : [
		"res://assets/sounds/footsteps/wood/footstepWood1.wav",
		"res://assets/sounds/footsteps/wood/footstepWood2.wav",
		"res://assets/sounds/footsteps/wood/footstepWood3.wav",
		"res://assets/sounds/footsteps/wood/footstepWood4.wav",
		"res://assets/sounds/footsteps/wood/footstepWood5.wav",
		"res://assets/sounds/footsteps/wood/footstepWood6.wav"
	],
}



##





