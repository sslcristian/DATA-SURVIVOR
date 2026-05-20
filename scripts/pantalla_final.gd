extends Control

@onready var label_titulo  : Label  = $VBox/LabelTitulo
@onready var label_mensaje : Label  = $VBox/LabelMensaje
@onready var btn_menu      : Button = $VBox/BtnMenu
@onready var btn_reiniciar : Button = $VBox/BtnReiniciar

var _reiniciar_escena := "res://scenes/Nivel1.tscn"

func _ready() -> void:
	_configurar(false)
	btn_menu.pressed.connect(_ir_menu)
	btn_reiniciar.pressed.connect(_reiniciar)

func configurar(victoria: bool, reiniciar_escena := "res://scenes/Nivel1.tscn") -> void:
	_reiniciar_escena = reiniciar_escena
	_configurar(victoria)

func _configurar(victoria: bool) -> void:
	if victoria:
		label_titulo.text  = "¡VICTORIA!"
		label_mensaje.text = "Has derrotado a todos los robots.\n¡Las estructuras de datos te hicieron más fuerte!"
		label_titulo.add_theme_color_override("font_color", Color.YELLOW)
	else:
		label_titulo.text  = "GAME OVER"
		label_mensaje.text = "El mundo postapocalíptico te venció.\n¡Estudia más y vuelve a intentarlo!"
		label_titulo.add_theme_color_override("font_color", Color.RED)

func _ir_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")

func _reiniciar() -> void:
	get_tree().change_scene_to_file(_reiniciar_escena)
