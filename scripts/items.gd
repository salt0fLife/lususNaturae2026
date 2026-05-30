extends Node

enum style { #for fonts and effects
	TAINTED,
	NORMAL,
	RARE,
	EVIL,
	BLESSED,
}

enum type { #types
	FOOD, #[food_value : int, food_type]
	THROWABLE,
	SWORD,
	BOOK,
}

enum sound { #sounds
	BREAD_SOUNDS,
	ROCK_SOUNDS,
	SWORD_SOUNDS,
	DBAT_SOUNDS,
}

enum animation { #animations
	BREAD_ANIM,
	SWORD_ANIM,
	DBAT_ANIM,
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
		"pickup" : "picked_up_bread",
		"eat" : "ate bread specifically",
		"dropped" : "dropped bread"
	},
	sound.ROCK_SOUNDS : {
		
	},
	sound.SWORD_SOUNDS : {
		
	},
	sound.DBAT_SOUNDS : {
		"eat" : "ate a dead bat specifically"
	},
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
	
	print(list)

enum {#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
	INDEX_NAME,
	INDEX_STYLE,
	INDEX_SOUNDS,
	INDEX_TYPE,
	INDEX_DATA,
	INDEX_TEXTURE,
	INDEX_MODEL,
	INDEX_ANIMATIONS
}



