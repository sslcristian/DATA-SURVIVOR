extends Node

var _player: AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.stream = preload("res://assets/AUDIO Y LETRA/AUDIO/soundtrack.mp3")
	_player.bus = "Master"
	add_child(_player)

func play_gameplay() -> void:
	if not _player.playing:
		_player.play()

func stop() -> void:
	_player.stop()
