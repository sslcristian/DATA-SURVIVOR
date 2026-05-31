extends Node

signal juego_iniciado
signal juego_terminado(victoria: bool)

var _enemigos_vivos: int = 0
var _jugador: Node = null
var jugando: bool = false

var controlador_pregunta: PreguntaController
var controlador_combate : CombateController

func _ready() -> void:
	controlador_pregunta = PreguntaController.new()
	add_child(controlador_pregunta)
	controlador_combate = CombateController.new()
	add_child(controlador_combate)

func iniciar_juego(jugador: Node, enemigos: Array) -> void:
	_jugador = jugador
	_enemigos_vivos = enemigos.size()
	jugando = true

	_jugador.jugador_muerto.connect(_on_jugador_muerto)
	for e in enemigos:
		e.enemigo_muerto.connect(_on_enemigo_muerto)

	emit_signal("juego_iniciado")

func _on_enemigo_muerto() -> void:
	_enemigos_vivos -= 1
	if _enemigos_vivos <= 0:
		terminar_juego(true)

func _on_jugador_muerto() -> void:
	terminar_juego(false)

func terminar_juego(victoria: bool) -> void:
	if not jugando:
		return
	jugando = false
	emit_signal("juego_terminado", victoria)

func activar_pregunta(objeto: Node) -> void:
	var dif: String = objeto.dificultad if objeto.get("dificultad") != null else ""
	controlador_pregunta.mostrar_pregunta(dif)
