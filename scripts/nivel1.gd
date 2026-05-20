extends Node2D

const ESCENA_ENEMIGO      := preload("res://scenes/Enemigo.tscn")
const ESCENA_ENEMIGO_DISP := preload("res://scenes/EnemigoDisparador.tscn")
const ESCENA_OBJETO       := preload("res://scenes/ObjetoInteractivo.tscn")
const ESCENA_BASE_META    := preload("res://scenes/BaseMeta.tscn")
const _HOJA_OBJETOS       := preload("res://assets/objetos/obstacles-and-objects.png")

@onready var jugador     : CharacterBody2D = $Jugador
@onready var hud         : CanvasLayer     = $HUD
@onready var ui_pregunta : CanvasLayer     = $UI_Pregunta
@onready var gm          : Node            = $GameManager

var _pregunta_pendiente: bool = false

func _ready() -> void:
	get_tree().debug_collisions_hint = false
	_generar_nivel()

	var enemigos: Array[Node] = get_tree().get_nodes_in_group("enemigo")
	gm.iniciar_juego(jugador, enemigos)
	gm.juego_terminado.connect(_on_juego_terminado)

	jugador.sistema_vida.vida_cambiada.connect(hud.actualizar_vida)
	hud.actualizar_vida(jugador.sistema_vida.corazones)
	hud.actualizar_stats(jugador.danio, jugador.defensa)

	gm.controlador_pregunta.pregunta_lista.connect(_on_pregunta_lista)
	gm.controlador_pregunta.respuesta_correcta.connect(_on_respuesta_correcta)
	gm.controlador_pregunta.respuesta_incorrecta.connect(_on_respuesta_incorrecta)

	ui_pregunta.opcion_seleccionada.connect(_on_opcion_seleccionada)

	for obj in get_tree().get_nodes_in_group("interactivo"):
		obj.activado.connect(_on_objeto_activado)

	jugador.objeto_cercano.connect(_on_objeto_cercano)
	jugador.sistema_vida.vida_cambiada.connect(_on_jugador_vida_cambiada)

# ─── Generación del nivel ────────────────────────────────────────────────────

func _generar_nivel() -> void:
	# ── Zona 1 — introducción (x 0..1500) ─────────────────────────────────────
	_plataforma(Vector2(150,  140), 180)
	_plataforma(Vector2(400,  100), 200)
	_plataforma(Vector2(650,  130), 160)
	_plataforma(Vector2(900,   80), 200)
	_plataforma(Vector2(1150, 120), 180)
	_plataforma(Vector2(1350,  70), 160)

	_enemigo(Vector2(200,  160))          # melee en suelo
	_enemigo(Vector2(550,  160))          # melee en suelo
	_enemigo_disp(Vector2(900,  62))      # francotirador sobre plataforma alta
	_enemigo(Vector2(1200, 160))          # melee en suelo

	_obstaculo(Vector2(320,  184))
	_obstaculo(Vector2(500,  184))
	_obstaculo(Vector2(700,  184))
	_obstaculo(Vector2(980,  184))

	_objeto(Vector2(430, 68), "facil")
	_lampara(Vector2(100,  184))
	_lampara(Vector2(480,  184))
	_lampara(Vector2(780,  184))
	_lampara(Vector2(1050, 184))

	# ── Zona 2 — intermedia (x 1500..3000) ────────────────────────────────────
	_plataforma(Vector2(1600, 110), 200)
	_plataforma(Vector2(1850,  70), 180)
	_plataforma(Vector2(2100, 120), 160)
	_plataforma(Vector2(2350,  80), 200)
	_plataforma(Vector2(2600, 110), 180)
	_plataforma(Vector2(2850,  60), 160)

	_enemigo(Vector2(1700, 160))
	_enemigo_disp(Vector2(1850,  52))     # francotirador en alto
	_enemigo(Vector2(2200, 160))
	_enemigo_disp(Vector2(2350,  62))     # francotirador en alto
	_enemigo(Vector2(2700, 160))

	_obstaculo(Vector2(1550, 184))
	_obstaculo(Vector2(1800, 184))
	_obstaculo(Vector2(2000, 184))
	_obstaculo(Vector2(2300, 184))
	_obstaculo(Vector2(2480, 184))
	_obstaculo(Vector2(2650, 184))
	_obstaculo(Vector2(2800, 184))

	_objeto(Vector2(2100, 102), "media")
	_lampara(Vector2(1620, 184))
	_lampara(Vector2(1900, 184))
	_lampara(Vector2(2450, 184))
	_lampara(Vector2(2720, 184))

	# ── Zona 3 — avanzada (x 3000..4500) ─────────────────────────────────────
	_plataforma(Vector2(3100,  90), 180)
	_plataforma(Vector2(3350,  60), 200)
	_plataforma(Vector2(3600, 110), 160)
	_plataforma(Vector2(3850,  75), 180)
	_plataforma(Vector2(4100, 120), 200)
	_plataforma(Vector2(4350,  65), 160)

	_enemigo(Vector2(3050, 160))
	_enemigo_disp(Vector2(3350,  42))     # francotirador muy arriba
	_enemigo(Vector2(3650, 160))
	_enemigo_disp(Vector2(3850,  57))
	_enemigo(Vector2(4050, 160))
	_enemigo_disp(Vector2(4350,  47))

	_obstaculo(Vector2(3100, 184))
	_obstaculo(Vector2(3250, 184))
	_obstaculo(Vector2(3500, 184))
	_obstaculo(Vector2(3750, 184))
	_obstaculo(Vector2(3950, 184))
	_obstaculo(Vector2(4200, 184))
	_obstaculo(Vector2(4350, 184))
	_obstaculo(Vector2(4450, 184))

	_objeto(Vector2(3600,  92), "media")
	_lampara(Vector2(3150, 184))
	_lampara(Vector2(3500, 184))
	_lampara(Vector2(4080, 184))
	_lampara(Vector2(4400, 184))

	# ── Zona 4 — aproximación al cuartel (x 4500..5200) ──────────────────────
	_plataforma(Vector2(4650, 100), 180)
	_plataforma(Vector2(4900,  70), 200)
	_plataforma(Vector2(5100, 110), 160)

	_enemigo(Vector2(4700, 160))
	_enemigo_disp(Vector2(4900,  52))
	_enemigo_disp(Vector2(5100,  92))

	_obstaculo(Vector2(4800, 184))
	_obstaculo(Vector2(4950, 184))
	_obstaculo(Vector2(5000, 184))
	_obstaculo(Vector2(5180, 184))

	_objeto(Vector2(4750, 168), "dificil")
	_lampara(Vector2(4620, 184))
	_lampara(Vector2(4880, 184))
	_lampara(Vector2(5060, 184))
	_lampara(Vector2(5200, 184))

	# ── Base enemiga final (x 5500) ──────────────────────────────────────────
	_base_meta(Vector2(5500, 152))
	_enemigo(Vector2(5330, 160))
	_enemigo(Vector2(5660, 160))
	_enemigo_disp(Vector2(5500, 90))
	_lampara(Vector2(5400, 184))
	_lampara(Vector2(5600, 184))

# ─── Helpers de construcción ─────────────────────────────────────────────────

func _plataforma(pos: Vector2, ancho: float) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	add_child(body)

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(ancho, 20)
	col.shape = rect
	body.add_child(col)

	# Cuerpo de concreto desgastado
	var tierra := ColorRect.new()
	tierra.size = Vector2(ancho, 16)
	tierra.position = Vector2(-ancho * 0.5, -6)
	tierra.color = Color(0.28, 0.25, 0.21, 1)
	body.add_child(tierra)

	# Superficie superior oxidada
	var hierba := ColorRect.new()
	hierba.size = Vector2(ancho, 6)
	hierba.position = Vector2(-ancho * 0.5, -10)
	hierba.color = Color(0.36, 0.30, 0.24, 1)
	body.add_child(hierba)

	# Borde oscuro inferior
	var borde := ColorRect.new()
	borde.size = Vector2(ancho, 3)
	borde.position = Vector2(-ancho * 0.5, 8)
	borde.color = Color(0.16, 0.13, 0.11, 1)
	body.add_child(borde)


func _obstaculo(pos: Vector2) -> void:
	var tipos := [
		{"region": Rect2(0,  64, 32, 32), "h": 32.0, "cw": 28.0},
		{"region": Rect2(32, 64, 32, 32), "h": 32.0, "cw": 28.0},
		{"region": Rect2(64, 64, 32, 32), "h": 32.0, "cw": 28.0},
		{"region": Rect2(0, 133, 32, 24), "h": 24.0, "cw": 26.0},
		{"region": Rect2(0, 163, 32, 22), "h": 22.0, "cw": 26.0},
	]
	var t: Dictionary = tipos[randi() % tipos.size()]
	var h  : float = t["h"]
	var cw : float = t["cw"]

	var body := StaticBody2D.new()
	body.position = pos
	add_child(body)

	var col  := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size    = Vector2(cw, h)
	col.shape    = rect
	col.position = Vector2(0.0, -h * 0.5)
	body.add_child(col)

	var atlas := AtlasTexture.new()
	atlas.atlas  = _HOJA_OBJETOS
	atlas.region = t["region"]
	var sprite := Sprite2D.new()
	sprite.texture        = atlas
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position       = Vector2(0.0, -h * 0.5)
	sprite.z_index        = 1
	body.add_child(sprite)

func _lampara(pos: Vector2) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas  = _HOJA_OBJETOS
	atlas.region = Rect2(0, 6, 32, 39)
	var sprite := Sprite2D.new()
	sprite.texture        = atlas
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position       = Vector2(pos.x, pos.y - 20.0)
	sprite.z_index        = 1
	add_child(sprite)

func _enemigo(pos: Vector2) -> void:
	var e := ESCENA_ENEMIGO.instantiate()
	e.position = pos
	add_child(e)

func _enemigo_disp(pos: Vector2) -> void:
	var e := ESCENA_ENEMIGO_DISP.instantiate()
	e.position = pos
	add_child(e)

func _objeto(pos: Vector2, dificultad: String = "") -> void:
	var obj := ESCENA_OBJETO.instantiate()
	obj.position = pos
	obj.set("dificultad", dificultad)
	add_child(obj)

func _base_meta(pos: Vector2) -> void:
	var obj := ESCENA_BASE_META.instantiate()
	obj.position = pos
	add_child(obj)

# ─── Callbacks de señales ─────────────────────────────────────────────────────

func _on_objeto_cercano(_obj: Node) -> void:
	hud.mostrar_mensaje("Presiona [E] para interactuar", 2.0)

func _on_objeto_activado(objeto: Node) -> void:
	if _pregunta_pendiente:
		return
	_pregunta_pendiente = true
	gm.activar_pregunta(objeto)

func _on_pregunta_lista(pregunta: Dictionary) -> void:
	ui_pregunta.mostrar(pregunta)

func _on_opcion_seleccionada(indice: int) -> void:
	gm.controlador_pregunta.validar_respuesta(indice)

func _on_respuesta_correcta(recompensa: Dictionary) -> void:
	var tipo_str: String = recompensa.tipo.to_upper()
	var r := Recompensa.new(Recompensa.Tipo[tipo_str], recompensa.valor)
	r.aplicar(jugador)
	hud.actualizar_vida(jugador.sistema_vida.corazones)
	hud.actualizar_stats(jugador.danio, jugador.defensa)
	ui_pregunta.mostrar_resultado(true, r.descripcion())
	_pregunta_pendiente = false

func _on_respuesta_incorrecta() -> void:
	jugador.recibir_danio(1)
	hud.actualizar_vida(jugador.sistema_vida.corazones)
	ui_pregunta.mostrar_resultado(false)
	_pregunta_pendiente = false

func _on_jugador_vida_cambiada(corazones: int) -> void:
	hud.actualizar_vida(corazones)

func _on_juego_terminado(victoria: bool) -> void:
	if victoria:
		hud.mostrar_mensaje("¡NIVEL 1 COMPLETADO! Siguiente nivel...", 2.0)
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/Nivel2.tscn")
	else:
		var capa := CanvasLayer.new()
		capa.layer = 100
		get_tree().root.add_child(capa)
		var pantalla: Control = load("res://scenes/PantallaFinal.tscn").instantiate()
		capa.add_child(pantalla)
		pantalla.configurar(false, "res://scenes/Nivel1.tscn")
