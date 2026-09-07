extends AudioStreamPlayer

const songs = {
	#"main_menu" : "res://assets/sounds/music/north_of_eden_menu.wav",
	"main_menu" : "res://assets/sounds/music/main_menu_music.wav",
	"menu_midi" : "res://assets/sounds/music/menu_midi_test.wav"
}

var current_song = ""

func play_file(filepath : String) -> void:
	stream = load(filepath)
	play()
	volume_db = -10.0

func play_song(key:StringName) -> void:
	if !songs.keys().has(key):
		stop()
		printerr("recieved invalid song key")
		return
	if current_song == key:
		print("already playing song")
		return
	current_song = key
	var filepath = songs[key]
	stream = load(filepath)
	play()
	volume_db = -10.0

func _ready():
	connect("finished",_on_song_finished)

func _on_song_finished():
	play()
	print("playlist not implemented, looping song")
