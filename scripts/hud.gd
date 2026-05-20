extends CanvasLayer

const CORAZON_LLENO : Texture2D = preload("res://assets/ui/corazon_lleno.png")
const CORAZON_VACIO : Texture2D = preload("res://assets/ui/corazon_vacio.png")
const _PIP_ATLAS    : Texture2D = preload("res://assets/ui/panel-frames.png")

# panel-frames.png: 176x48 px, 4 cols x 3 rows, each frame 44x16
# Center crop (22x14) of each frame to use as pip texture
const REGION_ATK_ON  := Rect2( 11,  1, 22, 14)   # orange frame — ATK filled
const REGION_ATK_OFF := Rect2( 99,  1, 22, 14)   # gray frame   — empty
const REGION_DEF_ON  := Rect2( 11, 33, 22, 14)   # blue frame   — DEF filled
const REGION_DEF_OFF := Rect2( 99,  1, 22, 14)   # gray frame   — empty

@onready var contenedor_vida  : HBoxContainer  = $PanelHUD/VBox/FilaVida
@onready var contenedor_danio : HBoxContainer  = $PanelHUD/VBox/FilaStats/PipsDanio
@onready var contenedor_def   : HBoxContainer  = $PanelHUD/VBox/FilaStats/PipsDefensa
@onready var label_arma       : Label           = $PanelHUD/VBox/LabelArma
@onready var top_center       : CenterContainer = $TopCenter
@onready var label_mensaje    : Label           = $TopCenter/PanelMensaje/LabelMensaje

func _ready() -> void:
	var corazones := contenedor_vida.get_children()
	for i in corazones.size():
		var txt := corazones[i] as TextureRect
		txt.texture = CORAZON_LLENO
		txt.modulate = Color.WHITE

	_init_pips(contenedor_danio, REGION_ATK_OFF)
	_init_pips(contenedor_def,   REGION_DEF_OFF)
	actualizar_stats(1, 0)

func _init_pips(container: HBoxContainer, region: Rect2) -> void:
	for pip in container.get_children():
		var atlas := AtlasTexture.new()
		atlas.atlas  = _PIP_ATLAS
		atlas.region = region
		(pip as TextureRect).texture = atlas

func actualizar_vida(corazones: int) -> void:
	var hijos := contenedor_vida.get_children()
	while hijos.size() < corazones:
		var extra := TextureRect.new()
		extra.custom_minimum_size = Vector2(22, 22)
		extra.size_flags_horizontal = 0
		extra.expand_mode = 0
		extra.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		contenedor_vida.add_child(extra)
		hijos = contenedor_vida.get_children()
	for i in hijos.size():
		(hijos[i] as TextureRect).texture = CORAZON_LLENO if i < corazones else CORAZON_VACIO

func actualizar_stats(danio: int, defensa: int) -> void:
	var pips_atk := contenedor_danio.get_children()
	for i in pips_atk.size():
		var atlas := (pips_atk[i] as TextureRect).texture as AtlasTexture
		atlas.region = REGION_ATK_ON if i < danio else REGION_ATK_OFF

	var pips_def := contenedor_def.get_children()
	for i in pips_def.size():
		var atlas := (pips_def[i] as TextureRect).texture as AtlasTexture
		atlas.region = REGION_DEF_ON if i < defensa else REGION_DEF_OFF

func set_arma(nombre: String) -> void:
	label_arma.text = "ARMA: " + nombre

func mostrar_mensaje(texto: String, duracion: float = 2.0) -> void:
	label_mensaje.text = texto
	top_center.visible = true
	await get_tree().create_timer(duracion).timeout
	top_center.visible = false
