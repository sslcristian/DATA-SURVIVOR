extends StaticBody2D

@export var dificultad: String = ""

signal activado(objeto)

func _ready() -> void:
	add_to_group("interactivo")

func activar() -> void:
	emit_signal("activado", self)
