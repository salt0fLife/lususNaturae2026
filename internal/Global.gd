extends Node

##my normal global script, any data about the world or any variables that need global reference
#ie, day_timer, all monster statistics, questlines, etc...

var save_filepath = "" #specifically the path to the save you are playing on
var version = "early-dev"

var settup_clouds = false #to minimize errors because its annoying



signal change_level
func change_level_from_key(key : String) -> void:
	emit_signal("change_level", key)

signal reached_major_point
func major_point_reached(key : int) -> void:
	emit_signal("reached_major_point", key)
	if major_points_reached.has(key):
		major_points_reached.append(key)

enum major_points {
	SKY_FALL, #discontinued :/
	WAKEUP,
	EXITED_LABORATORY,
	GATE_WARDEN_DEFEATED,
}

var major_points_reached = []

const levels: Dictionary = {
	"debug" : ["res://campaign/levels/debug_level.tscn"],
	"debug_v2" : ["res://campaign/levels/debug_level_v2.tscn"],
	"level_01" : ["res://campaign/levels/level_1.tscn"],
	"level_001" : ["res://campaign/levels/level_001.tscn"],
	"lighting_test" : ["res://campaign/levels/baked_lighting_test_level.tscn"],
	"dark_rooms" : ["res://campaign/levels/dark_rooms.tscn"],
	"stone_forest" : ["res://campaign/levels/stone_forest.tscn"],
	"warzone_laboratory" : ["res://campaign/levels/warzone_laboratory.tscn"],
	"canyon_cave_entrance" : ["res://campaign/levels/canyon_cave_entrance.tscn"],
	"abandoned_laboratory" : ["res://campaign/levels/abandoned_laboratory.tscn"],
	"laboratory_courtyard" : ["res://campaign/levels/laboratory_courtyard.tscn"],
}

var levels_persistent_data: Dictionary = {
	"debug" : [[],[]], #[lose_items, decals, entities]
}

const cutscenes: Dictionary = {
	"new_game_start" : ["res://campaign/cutscenes/game_start_cutscene.tscn", 30.0], #path seconds long
	"dream_1" : ["res://campaign/cutscenes/dream_cutscene.tscn",3.5],
	"fall_into_world" : ["res://campaign/cutscenes/falling_into_world_cutscene.tscn", 4.0],
	"gate_warden_introduction" : ["res://campaign/cutscenes/falling_into_world_cutscene.tscn", 1.0],
	"respawn" : ["res://campaign/cutscenes/death_cutscene.tscn",3.8]
}

signal play_cutscene_signal
func play_cutscene(key : StringName) -> void:
	emit_signal("play_cutscene_signal", key)
	if !cutscenes_watched.has(key):
		cutscenes_watched.append(key)

var progression:int = 0 #keeps track of various important events

var cutscenes_watched: Array = []

const entities: Dictionary = {
	"royal_guard" : ["res://campaign/enemies/royal_guard.tscn"],
	"basic_arrow" : ["res://assets/projectiles/basic_arrow.tscn"]
}

signal spawn_entity_signal
func spawn_entity(key, position : Vector3 = Vector3.ZERO,velocity:Vector3=Vector3.ZERO,custom_data:Array=[]) -> void:
	emit_signal("spawn_entity_signal", key, position, velocity,custom_data)

signal create_decal_signal
func create_decal(node) -> void:
	emit_signal("create_decal_signal", node)

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
	ENTER_DOOR, #[level_key, position, rotation(vec2)]
	SLEEP_IN_BED, #[bed_global_transform, bed_type]
	DO_NOTHING, #no action needed (should be pretty rare)
}

signal dialogue
func new_dialogue_box(text : String, custom_time : float = 0.0) -> void:
	if text == "":
		return
	emit_signal("dialogue", text, custom_time)
	pass

signal new_tooltip
func tooltip(text : String) -> void:
	if text == "":
		return
	emit_signal("new_tooltip", text)

##world stuff

func get_surface_info(groups : Array) -> Dictionary:
	for g in groups:
		if surface_lookup.has(g):
			return surface_lookup[g]
	return surface_lookup["default"]

enum {
	DIRT_KEY,
	GRASS_KEY,
	METAL_KEY,
	STONE_KEY,
	WOOD_KEY
}

enum {
	STEP_SOUNDS,
	BULLET_HIT_EFFECT,
}

const surface_lookup = { #this way i can bundle more info in if i need
	"dirt" : {
		STEP_SOUNDS : DIRT_KEY,
		BULLET_HIT_EFFECT : DIRT_KEY,
	},
	"stone" : {
		STEP_SOUNDS : STONE_KEY,
		BULLET_HIT_EFFECT : STONE_KEY,
	},
	"grass" : {
		STEP_SOUNDS : GRASS_KEY,
		BULLET_HIT_EFFECT : DIRT_KEY,
	},
	"metal" : {
		STEP_SOUNDS : METAL_KEY,
		BULLET_HIT_EFFECT : STONE_KEY,
	},
	"wood" : {
		STEP_SOUNDS : WOOD_KEY,
		BULLET_HIT_EFFECT : STONE_KEY,
	},
	"default" : {
		STEP_SOUNDS : STONE_KEY,
		BULLET_HIT_EFFECT : DIRT_KEY,
	}
	
}

const bullet_hit_effects = {
	STONE_KEY : ["res://assets/effects/decals/bullet_hole_default.tscn", ""],
	DIRT_KEY : ["",""],
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

enum damage_types{ #any kind of damage you can think of, this is the location for all tags
	SLICE,
	PUNCTURE,
	BLUDGEON,
	HOLY,
	ROT,
	POISON,
	MAGIC,
	BLEED,
	FIRE,
	FROST
}

#categories for resistances, weaknesses and such
const physical_damage_types = [
	damage_types.SLICE, 
	damage_types.PUNCTURE,
	damage_types.BLUDGEON
]

const purifying_damage_types = [
	damage_types.HOLY,
	damage_types.FIRE
]

func dir_to_rot(dir :Vector3) -> Vector2:
	var rot = Vector2.ZERO
	rot.y = atan2(dir.x, dir.z)
	rot.x = atan2(sqrt(dir.z*dir.z+dir.x*dir.x),dir.y)
	return rot
