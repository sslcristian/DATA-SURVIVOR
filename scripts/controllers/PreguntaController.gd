class_name PreguntaController
extends Node

const RUTA_PREGUNTAS := "res://data/preguntas.json"

var _banco       : Array[PreguntaModel] = []
var _usadas      : Array[PreguntaModel] = []
var _pregunta_act: PreguntaModel = null

signal pregunta_lista(pregunta: PreguntaModel)
signal respuesta_correcta(recompensa: Dictionary)
signal respuesta_incorrecta(correcta_texto: String)

func _ready() -> void:
	_cargar_preguntas()

func _cargar_preguntas() -> void:
	var archivo := FileAccess.open(RUTA_PREGUNTAS, FileAccess.READ)
	if archivo == null:
		push_error("No se pudo abrir preguntas.json")
		return
	var json := JSON.new()
	var err := json.parse(archivo.get_as_text())
	archivo.close()
	if err != OK:
		push_error("Error parseando preguntas.json")
		return
	for d in json.get_data():
		_banco.append(PreguntaModel.desde_diccionario(d))

func mostrar_pregunta(dificultad: String = "") -> void:
	var disponibles := _banco.filter(func(p): return not _usadas.has(p) and (dificultad == "" or p.dificultad == dificultad))
	if disponibles.is_empty():
		_usadas.clear()
		disponibles = _banco.duplicate()
		if dificultad != "":
			disponibles = disponibles.filter(func(p): return p.dificultad == dificultad)
	_pregunta_act = disponibles[randi() % disponibles.size()]
	_usadas.append(_pregunta_act)
	emit_signal("pregunta_lista", _pregunta_act)

func validar_respuesta(indice: int) -> void:
	if _pregunta_act == null:
		return
	if indice == _pregunta_act.correcta:
		emit_signal("respuesta_correcta", _pregunta_act.recompensa)
	else:
		var correcta_texto: String = _pregunta_act.opciones[_pregunta_act.correcta]
		emit_signal("respuesta_incorrecta", correcta_texto)
	_pregunta_act = null
