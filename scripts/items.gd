extends Node

#gules (red), azure (blue), vert (green), sable (black), argent (white), 
#gilt (golden), sanguine (blood), murrey (purple / mulberry), ermine (black and white pattern)
enum style { #for fonts and effects
	GULES, #red
	AZURE, #blue,
	VERT, #green,
	SABLE, #black,
	ARGENT, #white,
	GILT, #golden,
	SCARLET, #blood,
	MURREY, #purple / mulberry,
	ERMINE, #pattern
	
	TAINTED,
	NORMAL,
	RARE,
	EVIL,
	BLESSED,
}

enum rarity {
	NORMAL,
	UNCOMMON,
	RARE,
	OBSCURE,
	UNIQUE,
}

const style_icons:Dictionary = {
	style.GULES : [
		"res://assets/textures/gui/suits/gules_small.png",
		"res://assets/textures/gui/suits/gules_obscure_small.png"
	],
	style.AZURE : [
		"res://assets/textures/gui/suits/azure_small.png",
		"res://assets/textures/gui/suits/azure_obscure_small.png"
	],
	style.VERT : [
		"res://assets/textures/gui/suits/vert_small.png",
		"res://assets/textures/gui/suits/vert_obscure_small.png"
	],
	style.SABLE : [
		"res://assets/textures/gui/suits/sable_small.png",
		"res://assets/textures/gui/suits/sable_obscure_small.png"
	],
	style.ARGENT : [
		"res://assets/textures/gui/suits/argent_small.png",
		"res://assets/textures/gui/suits/argent_obscure_small.png"
	],
	style.GILT : [
		"res://assets/textures/gui/suits/gilt_small.png",
		"res://assets/textures/gui/suits/gilt_obscure_small.png"
	],
	style.SCARLET : [
		"res://assets/textures/gui/suits/scarlet_small.png",
		"res://assets/textures/gui/suits/scarlet_obscure_small.png"
	],
	style.MURREY : [
		"res://assets/textures/gui/suits/murrey_small.png",
		"res://assets/textures/gui/suits/murrey_obscure_small.png"
	],
	style.ERMINE : [
		"res://assets/textures/gui/suits/ermine_small.png",
		"res://assets/textures/gui/suits/ermine_small.png"
	],
}

const style_colors : Array[Color] = [
	Color.DARK_RED,
	Color.DARK_BLUE,
	Color.SEA_GREEN,
	Color.BLACK,
	Color.SILVER,
	Color.GOLDENROD,
	Color.CRIMSON,
	Color.WEB_PURPLE,
	Color.WHITE, #is a texture so white works for now
	#TAINTED,
	Color.DIM_GRAY,
	#NORMAL,
	Color.GRAY,
	#RARE,
	Color.CADET_BLUE,
	#EVIL,
	Color.BROWN,
	#BLESSED,
	Color.PALE_GOLDENROD,
]

enum type { #types
	FOOD, #[food_value : int, food_type]
	THROWABLE,
	SWORD,
	BOOK,
	GUN,
	HAMMER,
	BOW,
	ARROW,
	BAG,
	USELESS,
}

enum sound { #sounds
	BREAD_SOUNDS,
	ROCK_SOUNDS,
	SWORD_SOUNDS,
	DBAT_SOUNDS,
	GUN_SOUNDS,
	BOW_SOUNDS,
	WOOD_TRINKET_SOUNDS,
}

enum animation { #animations
	BREAD_ANIM,
	SWORD_ANIM,
	DBAT_ANIM,
	GUN_ANIM,
	HAMMER_ANIM,
	BOW_ANIM,
}

enum food_type { #food types
	FOOD_VILE, #nobody likes ever
	FOOD_PREPARED, #baked breads, stew, jerky, etc..
	FOOD_QUESTIONABLE, #prepared foods that have expired
	FOOD_HEARTY, #cooked meats, thick stews are arguably here, good meal everyone likes
	FOOD_WILD, #berries, larve, mushrooms, etc..
	FOOD_BLOODY, #recently dead things
}

var list = { #["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
	#"moldy_bread" : ["moldy bread", style.TAINTED, sound.BREAD_SOUNDS, type.FOOD, [2,food_type.FOOD_QUESTIONABLE], "res://assets/textures/material/DebuggTexture.png", "res://assets/items/bread/bread.tscn", animation.BREAD_ANIM]
	
}

var sounds = {
	sound.BREAD_SOUNDS : {
		"pickup" : "res://assets/sounds/item_sounds/draw_bread.ogg",
		"eat" : "ate bread specifically",
		"dropped" : "dropped bread",
		"grab_end" : "set down bread"
	},
	sound.ROCK_SOUNDS : {
		
	},
	sound.SWORD_SOUNDS : {
		"pickup" : "res://assets/sounds/item_sounds/swordsfx01.wav",#"res://assets/sounds/item_sounds/draw_short_sword.ogg",
		"swing" : "res://assets/sounds/item_sounds/swing_short_sword.ogg",
		"grab_start" : "res://assets/sounds/item_sounds/swordInventoryPickUp01.wav",#"res://assets/sounds/item_sounds/sword_grab_start.ogg",
		"grab_end" : "res://assets/sounds/item_sounds/swordInventoryDrop01.wav",#"res://assets/sounds/item_sounds/sword_grab_end.ogg",
	},
	sound.DBAT_SOUNDS : {
		"pickup" : "res://assets/sounds/item_sounds/draw_dbat.ogg",
		"eat" : "ate a dead bat specifically",
		"grab_end" : "set down dead bat"
	},
	sound.GUN_SOUNDS : {
		"pickup" : "res://assets/sounds/item_sounds/draw_gun.ogg",
		"shoot" : "res://assets/sounds/item_sounds/fire_gun.ogg",
		"grab_end" : "set down gun"
	},
	sound.BOW_SOUNDS : {
		
	},
	sound.WOOD_TRINKET_SOUNDS : {
		
	}
}

func _ready():
	populate_list()
	pass

func populate_list(): ##NOTE MAY NOT WORK ON EXPORT
	#var test_item = load("res://items/moldy_bread.tres")
	#list["moldy_bread"] = test_item.get_item()
	var items_folder = "res://items/"
	var items = SaveHandler.get_files_at_path(items_folder)
	for f in items:
		var i = load(items_folder+f)
		var item_data = i.get_item()
		var k = i.internal_reference_name
		list[k] = item_data
		interactions[k] = i.interactions
	
	print(list)
	print(interactions)

func key_to_item(key : StringName):
	var custom_data = {}
	var info = list[key]
	match info[INDEX_TYPE]: #can do some small stuff for convienience
		type.BAG:
			var inv = []
			for i in info[INDEX_DATA][0]:
				inv.append([])
			custom_data["inventory"] = inv
	return [key,custom_data]; #[internal_reference_name, attributes/custom_data]

enum {#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations, has_deformations]
	INDEX_NAME,
	INDEX_STYLE,
	INDEX_SOUNDS,
	INDEX_TYPE,
	INDEX_DATA,
	INDEX_TEXTURE,
	INDEX_MODEL,
	INDEX_ANIMATIONS,
	INDEX_HAS_DEFORMATIONS,
	INDEX_EQUIPMENT_ID,
	INDEX_COLLISION_SHAPE,
}


var interactions = {
	#"item_key" = {
		#key = item_key_that_triggers_this_interaction : [inter_id : int, inter_data : Array]
		#etc... for all interactions
	#}
}

enum equipment_id { #for items with slots they can or cannot be put in
	NORMAL,
	BACKPACK,
	QUIVER,
	ARROW
}
