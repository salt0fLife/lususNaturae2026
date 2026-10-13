extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$entity_group2.connect("all_entities_dead",spawn_second_wave)
	$entity_group3.connect("all_entities_dead",spawn_boss)
	$entity_group4.connect("all_entities_dead",open_gate)
	$entity_group4.connect("health_pool_changed",_on_health_pool_changed)

func spawn_second_wave():
	print("spawning second wave")
	$entity_group3.default_spawn()
	pass

func spawn_boss():
	print("spawning boss")
	$entity_group4.default_spawn()
	pass

func open_gate():
	print("open_gate")
	$world_animations.play("wall_collapse")
	pass

func _on_health_pool_changed():
	if $entity_group4.all_dead:
		$boss_bar.hide()
		return
	$boss_bar.visible = $entity_group4.health_pool.x > 0
	$boss_bar/ProgressBar.value = $entity_group4.health_pool.x
	$boss_bar/ProgressBar.max_value = $entity_group4.health_pool.y

func _on_player_exit():
	print("player exited")
	Global.major_point_reached(Global.major_points.GAMEPLAY_TEST_COMPLETED)

func _on_exit_area_body_entered(body):
	_on_player_exit()
