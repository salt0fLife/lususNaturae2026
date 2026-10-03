extends Control

@onready var portraits = [
	preload("res://assets/textures/portraits/vidica_portrait_bb_f1.png"),
	preload("res://assets/textures/portraits/vidica_portrait_bb_f2.png")
]

var current_portraits = ""
var portrait_presets = {
	"test" : [
		load("res://assets/textures/portraits/vidica_portrait_test_f1.png"),
		load("res://assets/textures/portraits/vidica_portrait_test_f2.png")
	],
	"blaze_blood" : [
		load("res://assets/textures/portraits/vidica_portrait_bb_f1.png"),
		load("res://assets/textures/portraits/vidica_portrait_bb_f2.png")
	]
}


@export var portrait_shuffle_time = 0.25;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	portrait_stuff(delta)
	#update_graphics()
	update_clock()

var portrait_index:int = 0
var portrait_shuffle_timer:float = 0.0
@onready var portrait = $portrait/TextureRect
func set_portrait(key : StringName) -> void:
	if current_portraits == key:
		return
	current_portraits = key
	if portrait_presets.has(key):
		portraits = portrait_presets[key]
	else:
		portraits = []
	$portrait/bb_particles.visible = key=="blaze_blood"
func portrait_stuff(delta) -> void:
	if Global.world_time > 0.25:
		set_portrait("blaze_blood")
	else:
		set_portrait("test")
	if portraits.size() < 1:
		#no portrait to switch too
		return
	portrait_shuffle_timer += delta
	if portrait_shuffle_timer > portrait_shuffle_time:
		portrait_shuffle_timer = 0.0
		portrait_index += 1
		if portrait_index >= portraits.size():
			portrait_index = 0
		portrait.texture = portraits[portrait_index]

func update_graphics() -> void:
	$health_bar/ProgressBar.max_value = float(PlayerInformation.max_health)
	$health_bar/ProgressBar.value = float(PlayerInformation.health)
	$stamina_display/ProgressBar.max_value = float(PlayerInformation.max_dash)
	$stamina_display/ProgressBar.value = float(PlayerInformation.current_dash)
	$hunger_bar/ProgressBar.max_value = float(PlayerInformation.max_food)
	$hunger_bar/ProgressBar.value = float(PlayerInformation.food)

@onready var clock_hand = $clock_hand
func update_clock():
	var wt = Global.world_time
	if wt > 0.5:
		wt -=1.0
	wt += 0.5
	wt = clamp(wt*2.0,0.0,1.0)
	wt = 1.0 - wt #dont worry about it very not confusing yes
	var angle = remap(wt,0.0,1.0,-0.88,0.88)
	clock_hand.rotation = angle

func _ready():
	PlayerInformation.connect("health_changed",update_hearts)
	PlayerInformation.connect("blood_changed",update_blood)
	update_hearts()
	update_blood()
	pass

@onready var hearts_atlas = {
	4 : preload("res://assets/textures/gui/gameplay_always/heart_full.png"),
	3 : preload("res://assets/textures/gui/gameplay_always/heart_three_quarter.png"),
	2 : preload("res://assets/textures/gui/gameplay_always/heart_half.png"),
	1 : preload("res://assets/textures/gui/gameplay_always/heart_one_quarter.png"),
	0 : preload("res://assets/textures/gui/gameplay_always/heart_broken.png")
}

@onready var heart_handler = $health_info/hearts
func update_hearts() -> void:
	for old in heart_handler.get_children(false):
		old.queue_free()
	
	var i = 0
	while i < PlayerInformation.max_health:
		var key = 0
		for x in range(0,4):
			var indx = x+i
			if PlayerInformation.health > indx:
				key += 1
		var tex = hearts_atlas[key]
		var t = TextureRect.new()
		t.texture = tex
		heart_handler.add_child(t)
		i += 4
		pass

func update_blood() -> void:
	$blood_bar.value = PlayerInformation.blood
	$blood_bar.max_value = PlayerInformation.max_blood
	
	pass




