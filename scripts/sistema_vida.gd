class_name SistemaVida
extends Node

signal vida_cambiada(corazones_actuales: int)
signal sin_vida

var MAX_CORAZONES: int = 5

var corazones: int = MAX_CORAZONES

func reducir_vida(cantidad: int = 1) -> void:
	corazones = max(0, corazones - cantidad)
	emit_signal("vida_cambiada", corazones)
	if corazones == 0:
		emit_signal("sin_vida")

func recuperar_vida(cantidad: int = 1) -> void:
	corazones = min(MAX_CORAZONES, corazones + cantidad)
	emit_signal("vida_cambiada", corazones)

func esta_vivo() -> bool:
	return corazones > 0

func reiniciar() -> void:
	corazones = MAX_CORAZONES
	emit_signal("vida_cambiada", corazones)
