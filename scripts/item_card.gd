class_name item_card extends Node2D
#gules (red), azure (blue), vert (green), sable (black), argent (white), 
#gilt (golden), sanguine / scarlet (blood), murrey (purple / mulberry), ermine (black and white pattern)enum {
const dimensions = Vector2(212.0,300.0)
enum {
	GULES, #red
	AZURE, #blue,
	VERT, #green,
	SABLE, #black,
	ARGENT, #white,
	GILT, #golden,
	SCARLET, #blood,
	MURREY, #purple / mulberry,
	ERMINE, #pattern
	
	TAINTED, #older designs who can stay,
	NORMAL,
	RARE,
	EVIL,
	BLESSED,
}
const colors : Array[Color]= [
	Color.DARK_RED,
	Color.DARK_BLUE,
	Color.SEA_GREEN,
	Color.BLACK,
	Color.SILVER,
	Color.GOLDENROD,
	Color.CRIMSON,
	Color.WEB_PURPLE,
	Color(1.0,0.0,1.0,1.0), #error until i get textures working
	
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
const text_colors : Array[Color] = [
	Color.BURLYWOOD,
	Color.CORNSILK,
	Color.DARK_ORANGE,
	Color.WHITE,
	Color.DARK_SLATE_GRAY,
	Color.RED,
	Color.WHITE,
	Color.BLACK,
	Color.WHITE, #error until i get textures working
	
	#TAINTED,
	Color.AQUAMARINE,
	#NORMAL,
	Color.WHITE,
	#RARE,
	Color.AQUA,
	#EVIL,
	Color.MAGENTA,
	#BLESSED,
	Color.DARK_GOLDENROD,
]

static func new_card(item_media : Array) -> item_card:
	var ic = load("res://menus/item_card.tscn").instantiate()
	if item_media.is_empty():
		ic.set_blank()
		return ic
	var item_key = item_media[0]
	var item_unique_data = item_media[1]
	var item_data = Items.list[item_key]
	var item_name = item_data[Items.INDEX_NAME]
	var item_style = item_data[Items.INDEX_STYLE]
	if item_unique_data.has("custom_style"):
		item_style = item_unique_data["custom_style"]
	if item_unique_data.has("custom_name"):
		item_name = item_unique_data["custom_name"]
	ic.set_item_name(item_name)
	ic.set_style(item_style)
	return ic

func set_item_name(text : String) -> void:
	$CanvasGroup/Label.text = text
	pass

func get_font(style : int) -> Array:
	var path = "res://assets/fonts/ANTQUABI.TTF"
	var size = 31.0
	match style:
		GILT:
			path = "res://assets/fonts/ITCEDSCR.TTF"
			size = 50.0
		_:
			pass
	return [load(path),31.0]

var applied_style = -1
func set_style(style: int) -> void:
	if style == applied_style:
		return
	applied_style = style
	$CanvasGroup/ColorRect.color = colors[style]
	$CanvasGroup/Label.set("theme_override_colors/font_color", text_colors[style])
	var font_info = get_font(style)
	$CanvasGroup/Label.set("theme_override_fonts/font",font_info[0])
	$CanvasGroup/Label.set("theme_override_font_sizes/font_size",font_info[1])
	
	if Items.style_icons.keys().has(style):
		var tex = load(Items.style_icons[style][0])
		$CanvasGroup/TextureRect.texture = tex
	

func set_blank() -> void:
	$CanvasGroup/ColorRect.color = Color(1.0,0.0,1.0,1.0)
	$CanvasGroup/Label.text = "blank card"
	
	pass

var display_mode = false
func set_display_mode(val : bool) -> void:
	if val == display_mode:
		return
	display_mode = val
	if val: 
		var t_pos = get_tree().create_tween()
		var t_rot = get_tree().create_tween()
		var desired_pos =  Vector2(0.0,-50.0).rotated(-global_rotation)
		t_pos.tween_property($CanvasGroup,"position",desired_pos,0.15)
		var desired_rot = $CanvasGroup.rotation - ($CanvasGroup.global_rotation)
		t_rot.tween_property($CanvasGroup,"rotation",desired_rot,0.1)
		#$CanvasGroup.rotation = desired_rot
		#$CanvasGroup.skew = 0.1
		$CanvasGroup.z_index = 10
		var t_scale = get_tree().create_tween()
		t_scale.tween_property($CanvasGroup,"scale",Vector2(1.25,1.25),0.15)
	else:
		var t_pos = get_tree().create_tween()
		var t_rot = get_tree().create_tween()
		t_pos.tween_property($CanvasGroup,"position", Vector2.ZERO,0.15)
		t_rot.tween_property($CanvasGroup,"rotation",0.0,0.1)
		#$CanvasGroup.rotation = 0.0
		#$CanvasGroup.skew = 0.0
		$CanvasGroup.z_index = 0
		var t_scale = get_tree().create_tween()
		t_scale.tween_property($CanvasGroup,"scale",Vector2(1.0,1.0),0.15)
