extends AudioStreamPlayer

const songs = {
	#"main_menu" : "res://assets/sounds/music/north_of_eden_menu.wav",
	#"main_menu" : "res://assets/sounds/music/main_menu_music.wav",
	#"main_menu" : "res://assets/sounds/music/northofedenmenumusic.wav",
	"main_menu" : "res://assets/sounds/music/cant ship with very sad/sleepwalk-Deftones.wav",
	#"menu_midi" : "res://assets/sounds/music/menu_midi_test.wav"
	"weary_atmosphere" : "res://assets/sounds/immersion/weary_atmosphere.wav",
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

var playing_sounds = {
	
}

var killing_sounds = {
	
}

func play_sound(path:String):
	print("playing sound " + path)
	if playing_sounds.has(path):
		killing_sounds[path] = [playing_sounds[path],1.5] #number is seconds of fade out
		#dont need to erase just overwrite
		pass
	var n = AudioStreamPlayer.new()
	n.stream = load(path)
	add_child(n)
	n.play()
	n.connect("finished",_on_sound_ended_natrually.bind(path))
	playing_sounds[path] = n

func end_sound(path:String,fadeout:float = 1.5):
	if playing_sounds.has(path):
		killing_sounds[path] = [playing_sounds[path],fadeout,fadeout] #number is seconds of fade out
		playing_sounds.erase(path)
		print("killing sound " + path)
	else:
		printerr("cannot kill sound as it is not playing")

func _on_sound_ended(node):
	node.call_deferred("queue_free")
	print("sound ended")

func _on_sound_ended_natrually(path):
	if playing_sounds.has(path):
		_on_sound_ended(playing_sounds[path])
		playing_sounds.erase(path)

func _process(delta):
	if playing_sounds.is_empty():
		if volume_db != 0.0:
			volume_db = lerp(volume_db,0.0,delta*0.5)
			if volume_db > -0.1:
				volume_db = 0.0
	else:
		volume_db = lerp(volume_db,-80.0,delta)
		pass
	for k in killing_sounds.keys():
		var n = killing_sounds[k][0]
		var t = killing_sounds[k][1]
		var mt = killing_sounds[k][2]
		t -= delta
		killing_sounds[k][1] = t
		var db = remap(t,mt,0.0,0.0,-80.0)
		n.volume_db = db
		if t<=0.0:
			killing_sounds.erase(k)
			_on_sound_ended(n)


