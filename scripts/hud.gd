extends CanvasLayer

const CORAZON_LLENO : Texture2D = preload("res://assets/ui/corazon_lleno.png")
const CORAZON_VACIO : Texture2D = preload("res://assets/ui/corazon_vacio.png")
const ATK_CARGADO   : Texture2D = preload("res://assets/ui/atk_cargado.png")
const ATK_VACIO     : Texture2D = preload("res://assets/ui/atk_vacio.png")
const DEF_CARGADO   : Texture2D = preload("res://assets/ui/def_cargado.png")
const DEF_VACIO     : Texture2D = preload("res://assets/ui/def_vacio.png")

const MAX_ATK := 5
const MAX_DEF := 5

@onready var contenedor_vida : HBoxContainer = $Control/HBoxContainer
@onready var contenedor_atk  : HBoxContainer = $Control/ContenedorAtk
@onready var contenedor_def  : HBoxContainer = $Control/ContenedorDef
@onready var label_arma      : Label          = $Control/LabelArma
@onready var label_nivel     : Label          = $Control/LabelNivel
@onready var label_mensaje   : Label          = $Control/LabelMensaje

func _ready() -> void:
	for txt in contenedor_vida.get_children():
		(txt as TextureRect).texture = CORAZON_LLENO
	_actualizar_barra(contenedor_atk, MAX_ATK, MAX_ATK, ATK_CARGADO, ATK_VACIO)
	_actualizar_barra(contenedor_def, MAX_DEF, MAX_DEF, DEF_CARGADO, DEF_VACIO)

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

func set_stats(atk: int, def: int) -> void:
	_actualizar_barra(contenedor_atk, atk, MAX_ATK, ATK_CARGADO, ATK_VACIO)
	_actualizar_barra(contenedor_def, def, MAX_DEF, DEF_CARGADO, DEF_VACIO)

func actualizar_stats(danio: int, defensa: int) -> void:
	set_stats(danio, defensa)

func set_arma(nombre: String) -> void:
	label_arma.text = "Arma: " + nombre

func set_nivel(nivel: int) -> void:
	label_nivel.text = "NIVEL: " + str(nivel)

func mostrar_mensaje(texto: String, duracion: float = 2.0) -> void:
	label_mensaje.text = texto
	await get_tree().create_timer(duracion).timeout
	label_mensaje.text = ""

func _actualizar_barra(contenedor: HBoxContainer, valor: int, maximo: int,
		tex_llena: Texture2D, tex_vacia: Texture2D) -> void:
	var hijos := contenedor.get_children()
	while hijos.size() < maximo:
		var icono := TextureRect.new()
		icono.custom_minimum_size = Vector2(14, 14)
		icono.size_flags_horizontal = 0
		icono.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		contenedor.add_child(icono)
		hijos = contenedor.get_children()
	for i in hijos.size():
		(hijos[i] as TextureRect).texture = tex_llena if i < valor else tex_vacia
