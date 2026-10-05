extends Node

func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
#	MusicHandler.play_song("res://assets/sounds/music/menu_midi_test.wav")
	MusicHandler.play_song("main_menu")
	
	
	
	$control/Panel/VBoxContainer/campaign.connect("button_down", play_campaign)
	$control/Panel/VBoxContainer/multiplayer.connect("button_down", play_multiplayer)
	$control/Panel/VBoxContainer/settings.connect("button_down", open_settings)
	$control/Panel/VBoxContainer/quit.connect("button_down", save_and_quit)
	
	$control/Panel/VBoxContainer/campaign.connect("mouse_entered", _on_button_hovered.bind($control/Panel/VBoxContainer/campaign))
	$control/Panel/VBoxContainer/multiplayer.connect("mouse_entered", _on_button_hovered.bind($control/Panel/VBoxContainer/multiplayer))
	$control/Panel/VBoxContainer/settings.connect("mouse_entered", _on_button_hovered.bind($control/Panel/VBoxContainer/settings))
	$control/Panel/VBoxContainer/quit.connect("mouse_entered", _on_button_hovered.bind($control/Panel/VBoxContainer/quit))
	
	$control/Panel/VBoxContainer/campaign.connect("mouse_exited", mouse_exited)
	$control/Panel/VBoxContainer/multiplayer.connect("mouse_exited", mouse_exited)
	$control/Panel/VBoxContainer/settings.connect("mouse_exited", mouse_exited)
	$control/Panel/VBoxContainer/quit.connect("mouse_exited", mouse_exited)

var waiting_timer = 0.0
func mouse_exited() -> void:
	#selected_button = null
	waiting_timer = 0.4
	pass

func save_and_quit():
	print("quit the right way")
	get_tree().call_deferred("quit", 1)

func open_settings() -> void:
	print("opened settings menu")
	var s = load("res://menus/settings_menu.tscn").instantiate()
	add_child(s)
	pass

func play_campaign() -> void:
	selection_pulse = 1.0
	$button_clicked.play()
	await $button_clicked.finished
	
	print("opening campaign menu")
	get_tree().call_deferred("change_scene_to_file", "res://campaign/campaign_main_menu.tscn")
	pass

func play_multiplayer() -> void:
	printerr("multiplayer not implemented yet")
	selection_pulse = 1.0
	$locked_button.play()
	$tooltip.set_new_tooltip("mutliplayer not implemented",5.6)

func _on_button_hovered(button) -> void:
	selection_pulse = 1.0
	waiting_timer = 0.0
	print("button hovered")
	$button_hovered.play()
	hide_spacers()
	selected_button = button
	var indx = button.get_index()
	$control/Panel/VBoxContainer.get_child(indx-1).visible = true
	$control/Panel/VBoxContainer.get_child(indx+1).visible = true
	
	pass

func hide_spacers() -> void:
	$control/Panel/VBoxContainer/HSeparator.hide()
	$control/Panel/VBoxContainer/HSeparator2.hide()
	$control/Panel/VBoxContainer/HSeparator3.hide()
	$control/Panel/VBoxContainer/HSeparator4.hide()
	$control/Panel/VBoxContainer/HSeparator5.hide()

var selection_pulse = 0.0

var selected_button = null
var selection_outline_vel = Vector2.ZERO
@export_category("cursor_follow")
@export var sel_out_damp = 0.1
@export var sel_out_max_acceleration = 100.0
@export var sel_out_acceleration = 10.0
@export var cursor_spin_speed = 1.0
@export_category("selection_pulse")
@export var pulse_decay_speed = 1.0
@export var pulse_strength = 1.0
@onready var anim = $control/AnimationPlayer
@onready var cursor = $cursor
func _process(delta):
	cursor.position = get_viewport().get_mouse_position()
	if selection_pulse > 0.0:
		selection_pulse -= delta * pulse_decay_speed
		if selection_pulse < 0.0:
			selection_pulse = 0.0
		var sc = 1.0 + sin(PI*selection_pulse)*0.25*pulse_strength
		$control/Panel/Control.scale = Vector2(sc,sc)
	if waiting_timer != 0.0:
		waiting_timer -= delta
		if waiting_timer < 0.0:
			selected_button = null
			waiting_timer = 0.0
	if selected_button != null:
		var s_o = $control/Panel/Control
		var target_pos = selected_button.global_position+Vector2(59.0,5.0)
		var dif = (target_pos - s_o.global_position) * sel_out_acceleration
		var dir = dif.normalized()*clamp(dif.length(),0.0,sel_out_max_acceleration)
		selection_outline_vel += dir*delta
		selection_outline_vel -= selection_outline_vel*delta*sel_out_damp
		s_o.position += selection_outline_vel
		#$control/Panel/Control/selection_outline.visible = true
		#$control/Panel/Control/Control.visible = false
		$control/Panel/Control/Control.rotation = 0.0#lerp($control/Panel/Control/Control.rotation,0.0,delta*16.0)
		if anim.current_animation != "frame_idle" and anim.current_animation != "to_frame":
			anim.play("to_frame")
	else:
		$control/Panel/Control/Control.rotation += PI*delta*cursor_spin_speed
		#$control/Panel/Control/selection_outline.visible = false
		#$control/Panel/Control/Control.visible = true
		var s_o = $control/Panel/Control
		var target_pos = get_viewport().get_mouse_position() -Vector2(20.0,20.0)
		var dif = (target_pos - s_o.global_position) * sel_out_acceleration 
		var dir = dif.normalized()*clamp(dif.length(),0.0,sel_out_max_acceleration)
		selection_outline_vel += dir*delta
		selection_outline_vel -= selection_outline_vel*delta*sel_out_damp
		#s_o.global_position = lerp(s_o.global_position,target_pos,delta*16.0)
		s_o.position += selection_outline_vel
		if anim.current_animation != "cursor_idle" and anim.current_animation != "to_cursor":
			anim.play("to_cursor")

#var mouse_pos = Vector2.ZERO
#func _process(delta):
	#mouse_pos = lerp(mouse_pos,get_viewport().get_mouse_position(),delta*16.0)
	#
	#for i in $control/Panel/VBoxContainer.get_children():
		#var y_pos = i.global_position.y
		#i.scale.y = 0.5 + 0.5*(1.0 - clamp(abs(y_pos-mouse_pos.y) * 0.01,0.0,1.0))
		#pass
	#
	#pass

func _input(event):
	if event is InputEventMouseMotion:
		if selected_button == null:
			$control/Panel/Control.position += event.relative
