extends Node3D
var tool_tip = "sleep"

func interact():
	var data = [global_transform,0]
	return [Global.interact_returns.SLEEP_IN_BED,data]
