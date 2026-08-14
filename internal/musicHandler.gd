extends AudioStreamPlayer


func play_song(filepath : String) -> void:
	stream = load(filepath)
	play()
	volume_db = -10.0
