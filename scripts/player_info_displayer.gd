extends Control



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_graphics()

func update_graphics() -> void:
	$health_bar/ProgressBar.max_value = float(PlayerInformation.max_health)
	$health_bar/ProgressBar.value = float(PlayerInformation.health)
	$stamina_display/ProgressBar.max_value = float(PlayerInformation.max_dash)
	$stamina_display/ProgressBar.value = float(PlayerInformation.current_dash)
	$hunger_bar/ProgressBar.max_value = float(PlayerInformation.max_food)
	$hunger_bar/ProgressBar.value = float(PlayerInformation.food)
