extends CanvasLayer

signal opcion_seleccionada(indice: int)

@onready var panel        : Panel        = $Panel
@onready var label_texto  : Label        = $Panel/VBox/LabelPregunta
@onready var contenedor   : VBoxContainer = $Panel/VBox/Opciones
@onready var label_result : Label        = $Panel/VBox/LabelResultado

var _botones: Array[Button] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	label_result.visible = false

func mostrar(pregunta: Dictionary) -> void:
	label_texto.text = pregunta.texto
	label_result.visible = false

	for b in _botones:
		b.queue_free()
	_botones.clear()

	for i in pregunta.opciones.size():
		var btn := Button.new()
		btn.text = pregunta.opciones[i]
		btn.pressed.connect(_on_opcion_presionada.bind(i))
		contenedor.add_child(btn)
		_botones.append(btn)

	panel.visible = true
	get_tree().paused = true

func mostrar_resultado(correcto: bool, recompensa_desc: String = "") -> void:
	label_result.visible = true
	if correcto:
		label_result.text = "¡Correcto! " + recompensa_desc
		label_result.add_theme_color_override("font_color", Color.GREEN)
	else:
		label_result.text = "Incorrecto. -1 corazon"
		label_result.add_theme_color_override("font_color", Color.RED)
	for b in _botones:
		b.disabled = true
	await get_tree().create_timer(2.0).timeout
	cerrar()

func cerrar() -> void:
	panel.visible = false
	get_tree().paused = false

func _on_opcion_presionada(indice: int) -> void:
	emit_signal("opcion_seleccionada", indice)
