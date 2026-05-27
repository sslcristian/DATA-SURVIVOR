extends CanvasLayer

signal opcion_seleccionada(indice: int)

@onready var overlay         : Panel  = $Control
@onready var label_pregunta  : Label  = $Control/Panel/LabelPregunta
@onready var label_resultado : Label  = $Control/Panel/LabelResultado
@onready var _btn0           : Button = $Control/Panel/BtnOpcion0
@onready var _btn1           : Button = $Control/Panel/BtnOpcion1
@onready var _btn2           : Button = $Control/Panel/BtnOpcion2
@onready var _btn3           : Button = $Control/Panel/BtnOpcion3

var botones: Array[Button]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	botones = [_btn0, _btn1, _btn2, _btn3]
	overlay.visible = false
	label_resultado.visible = false
	for i in botones.size():
		botones[i].pressed.connect(_on_opcion_seleccionada.bind(i))

func mostrar(pregunta: Dictionary) -> void:
	label_pregunta.text = pregunta.texto
	label_pregunta.visible = true
	label_resultado.visible = false
	for i in botones.size():
		if i < pregunta.opciones.size():
			botones[i].text = pregunta.opciones[i]
			botones[i].disabled = false
			botones[i].visible = true
		else:
			botones[i].visible = false
	overlay.visible = true
	get_tree().paused = true

func mostrar_resultado(correcto: bool, recompensa_desc: String = "") -> void:
	label_pregunta.visible = false
	label_resultado.visible = true
	if correcto:
		label_resultado.text = "¡Correcto! " + recompensa_desc
		label_resultado.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
	else:
		label_resultado.text = "Incorrecto. -1 corazon"
		label_resultado.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
	for b in botones:
		b.disabled = true
	await get_tree().create_timer(2.0).timeout
	cerrar()

func cerrar() -> void:
	overlay.visible = false
	get_tree().paused = false

func _on_opcion_seleccionada(indice: int) -> void:
	emit_signal("opcion_seleccionada", indice)
