class_name PreguntaModel
extends RefCounted

var texto: String = ""
var opciones: Array = []
var correcta: int = 0
var dificultad: String = ""
var pista: String = ""
var recompensa: Dictionary = {}

static func desde_diccionario(d: Dictionary) -> PreguntaModel:
	var m := PreguntaModel.new()
	m.texto = d.get("texto", "")
	m.opciones = d.get("opciones", [])
	m.correcta = d.get("correcta", 0)
	m.dificultad = d.get("dificultad", "")
	m.pista = d.get("pista", "")
	m.recompensa = d.get("recompensa", {})
	return m
