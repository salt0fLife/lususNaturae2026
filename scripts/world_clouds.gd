extends Node3D

#var camera = null
#var viewport = null
#@onready var camera_tracker = $camera_tracker
#@onready var mesh = $camera_tracker/MeshInstance3D.mesh

func _process(delta):
	pass
	#if Engine.is_editor_hint():
		#if camera == null:
			#camera = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		#else:
			#camera_tracker.transform = camera.global_transform
		#
		#if viewport == null:
			#viewport = EditorInterface.get_editor_viewport_3d(0)
		#else:
			#mesh.size = Vector2(viewport.size.x-10.0, viewport.size.y-10.0)*Vector2(0.002,0.002)
		#
		#return
	#if camera == null:
		#camera = get_viewport().get_camera_3d()
	#else:
		#camera_tracker.transform = camera.global_transform
	#if viewport == null:
		#viewport = get_viewport()
	#else:
		#mesh.size = Vector2(viewport.size.x-10.0, viewport.size.y-10.0)*Vector2(0.002,0.002)
