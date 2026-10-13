extends StaticBody3D
@export var entrance_id:int #for unlocking and saving
@export var level_to_enter : StringName
@export var exit_pos : Vector3
@export var exit_rot : Vector2
@export var toolTip : String = "enter limbo"
var tool_tip :String = "unlock gateway"
var unlocked = false

func interact():
	if !is_unlocked():
		set_unlocked()
		play_unlock_anim()
		return [Global.interact_returns.DO_NOTHING,[]]
	var data = [level_to_enter,exit_pos,exit_rot]
	return [Global.interact_returns.ENTER_DOOR,data]

func is_unlocked() -> bool:
	return Global.limbo_entrances_unlocked.has(entrance_id)

func _ready():
	if is_unlocked():
		set_unlocked()
		print("limbo entrance " + str(entrance_id) + " unlocked")

func play_unlock_anim() -> void:
	var s = load("res://assets/effects/generic_spawn_explosion.tscn").instantiate()
	add_child(s)

func set_unlocked() -> void: #for settup
	tool_tip = toolTip
	unlocked = true
	$unlocked_graphics.show()
	$hint_graphics.hide()
	if !is_unlocked():
		Global.limbo_entrances_unlocked.append(entrance_id)
		print("unlocked limbo entrance " + str(entrance_id) + " for the first time")

func _on_unlock_area_body_entered(body):
	if !unlocked:
		set_unlocked()
		play_unlock_anim()

