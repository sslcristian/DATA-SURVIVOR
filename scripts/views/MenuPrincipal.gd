extends Control

@onready var btn_iniciar: TextureButton = $BtnIniciar
@onready var btn_salir: TextureButton = $BtnSalir
@onready var menu_musica: AudioStreamPlayer = $MenuMusica

func _ready() -> void:
	btn_iniciar.pressed.connect(_on_iniciar)
	btn_salir.pressed.connect(_on_salir)
	menu_musica.play(3.0)

func _on_iniciar() -> void:
	menu_musica.stop()
	get_tree().change_scene_to_file("res://scenes/Nivel1.tscn")

func _on_salir() -> void:
	menu_musica.stop()
	get_tree().quit()
