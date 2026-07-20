extends Node3D
@export var level_to_enter:StringName = "debug"
@export var exit_pos: Vector3
@export var exit_rot: Vector2

var tool_tip = "exit laboratory"

func interact():
	var data = [level_to_enter,exit_pos,exit_rot]
	return [Global.interact_returns.ENTER_DOOR,data]

