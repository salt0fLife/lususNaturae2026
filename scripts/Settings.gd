extends Node


##just normal settings script
signal updated_controls
var controls = {
	"mouse_sensitivity" : 1.5,
	"keybinds" : [], #honestly no idea how this works rn lol
}

enum {
	DISABLED,
	ENABLED,
	FAST,
	FANCY,
	FABULOUS
}
signal updated_graphics
var graphics = {
	"ssao" : false,
	"ssr" : false,
	"FOV" : 80.0,
	"environment_quality" : FANCY,
}
