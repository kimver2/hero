class_name AudioManagerClass
extends Node

var sfx_slash = preload("res://assets/audio/sfx_slash.wav")
var sfx_hit = preload("res://assets/audio/sfx_hit.wav")
var sfx_skill = preload("res://assets/audio/sfx_skill.wav")
var sfx_potion = preload("res://assets/audio/sfx_potion.wav")
var sfx_dialog = preload("res://assets/audio/sfx_dialog.wav")
var sfx_roar = preload("res://assets/audio/sfx_roar.wav")

var players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL_SIZE):
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		players.append(asp)

func play_sfx(stream: AudioStream, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if not stream:
		return
	for asp in players:
		if not asp.playing:
			asp.stream = stream
			asp.pitch_scale = pitch
			asp.volume_db = volume_db
			asp.play()
			return
	players[0].stream = stream
	players[0].pitch_scale = pitch
	players[0].volume_db = volume_db
	players[0].play()
