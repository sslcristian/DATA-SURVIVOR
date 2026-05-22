extends CanvasLayer

const CORAZON_LLENO : Texture2D = preload("res://assets/ui/corazon_lleno.png")
const CORAZON_VACIO : Texture2D = preload("res://assets/ui/corazon_vacio.png")
const ATK_CARGADO   : Texture2D = preload("res://assets/ui/atk_cargado.png")
const ATK_VACIO     : Texture2D = preload("res://assets/ui/atk_vacio.png")
const DEF_CARGADO   : Texture2D = preload("res://assets/ui/def_cargado.png")
const DEF_VACIO     : Texture2D = preload("res://assets/ui/def_vacio.png")

@onready var contenedor_vida  : HBoxContainer  = $PanelHUD/VBox/FilaVida
@onready var contenedor_danio : HBoxContainer  = $PanelHUD/VBox/FilaStats/PipsDanio
@onready var contenedor_def   : HBoxContainer  = $PanelHUD/VBox/FilaStats/PipsDefensa
@onready var label_arma       : Label           = $PanelHUD/VBox/LabelArma
@onready var top_center       : CenterContainer = $TopCenter
@onready var label_mensaje    : Label           = $TopCenter/PanelMensaje/LabelMensaje

func _ready() -> void:
	for txt in contenedor_vida.get_children():
		(txt as TextureRect).texture = CORAZON_LLENO

	for pip in contenedor_danio.get_children():
		(pip as TextureRect).texture = ATK_VACIO
	for pip in contenedor_def.get_children():
		(pip as TextureRect).texture = DEF_VACIO

	actualizar_stats(1, 0)

func actualizar_vida(corazones: int) -> void:
	var hijos := contenedor_vida.get_children()
	while hijos.size() < corazones:
		var extra := TextureRect.new()
		extra.custom_minimum_size = Vector2(22, 22)
		extra.size_flags_horizontal = 0
		extra.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		extra.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		contenedor_vida.add_child(extra)
		hijos = contenedor_vida.get_children()
	for i in hijos.size():
		(hijos[i] as TextureRect).texture = CORAZON_LLENO if i < corazones else CORAZON_VACIO

func actualizar_stats(danio: int, defensa: int) -> void:
	var pips_atk := contenedor_danio.get_children()
	for i in pips_atk.size():
		(pips_atk[i] as TextureRect).texture = ATK_CARGADO if i < danio else ATK_VACIO

	var pips_def := contenedor_def.get_children()
	for i in pips_def.size():
		(pips_def[i] as TextureRect).texture = DEF_CARGADO if i < defensa else DEF_VACIO

func set_arma(nombre: String) -> void:
	label_arma.text = "ARMA: " + nombre

func mostrar_mensaje(texto: String, duracion: float = 2.0) -> void:
	label_mensaje.text = texto
	top_center.visible = true
	await get_tree().create_timer(duracion).timeout
	top_center.visible = false
