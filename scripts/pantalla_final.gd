extends Control

@onready var img_victoria = $VBox/VICTORIA
@onready var img_derrota = $VBox/DERROTA

@onready var btn_menu = $BtnMenu
@onready var btn_reiniciar = $BtnReiniciar

@onready var sonido_victoria = $SonidoVictoria
@onready var sonido_derrota = $SonidoDerrota

var _reiniciar_escena := "res://scenes/Nivel1.tscn"

func _ready() -> void:

	# Ocultar imágenes al iniciar
	img_victoria.visible = false
	img_derrota.visible = false

	btn_menu.pressed.connect(_ir_menu)
	btn_reiniciar.pressed.connect(_reiniciar)

func configurar(victoria: bool, reiniciar_escena := "res://scenes/Nivel1.tscn") -> void:

	_reiniciar_escena = reiniciar_escena
	_configurar(victoria)

func _configurar(victoria: bool) -> void:

	# Ocultar ambas
	img_victoria.visible = false
	img_derrota.visible = false

	# Detener sonidos por seguridad
	sonido_victoria.stop()
	sonido_derrota.stop()

	# Mostrar y reproducir
	if victoria:

		img_victoria.visible = true
		sonido_victoria.play()

	else:

		img_derrota.visible = true
		sonido_derrota.play()

func _detener_sonidos() -> void:

	sonido_victoria.stop()
	sonido_derrota.stop()

func _ir_menu() -> void:

	_detener_sonidos()

	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")

func _reiniciar() -> void:

	_detener_sonidos()

	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file(_reiniciar_escena)
