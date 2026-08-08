extends AudioStreamPlayer


func play_song(filepath : String) -> void:
	stream = load(filepath)
	play()
