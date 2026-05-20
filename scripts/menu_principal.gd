extends Control

@onready var btn_iniciar : Button = $BtnIniciar
@onready var btn_salir   : Button = $BtnSalir

func _ready() -> void:
	btn_iniciar.pressed.connect(_on_iniciar)
	btn_salir.pressed.connect(_on_salir)

func _on_iniciar() -> void:
	get_tree().change_scene_to_file("res://scenes/Nivel1.tscn")

func _on_salir() -> void:
	get_tree().quit()
