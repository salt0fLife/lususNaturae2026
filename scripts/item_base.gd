extends Resource
class_name item

#["display_name", item_style, sounds, item_type, data, texture_path, model_path, animations]
@export var internal_reference_name: String
@export var display_name: String
@export var item_style: Items.style
@export var sounds: Items.sound
@export var animations: Items.animation
@export var model_path: String
@export var has_deformations: bool #is true if you want the mesh to be parented directly to armature
@export var texture_path: String
@export var interactions: Dictionary
@export var equipment_id: Items.equipment_id
@export var collision_shape: Vector3 = Vector3(1.0,1.0,1.0) #careful changing this for items as they may clip out of bounds when loading back in
#interactions info
#key = item_key_that_triggers_this_interaction : [inter_id : int, inter_data : Array]

