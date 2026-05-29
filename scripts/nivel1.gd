extends Node2D

const ESCENA_ENEMIGO      := preload("res://scenes/Enemigo.tscn")
const ESCENA_ENEMIGO_DISP := preload("res://scenes/EnemigoDisparador.tscn")
const ESCENA_OBJETO       := preload("res://scenes/ObjetoInteractivo.tscn")
const ESCENA_BASE_META    := preload("res://scenes/BaseMeta.tscn")
const _HOJA_OBJETOS       := preload("res://assets/objetos/obstacles-and-objects.png")
const _TEXTURA_SUELO      := preload("res://assets/escenario/Bright/plataforma-removebg-preview.png")
const _REGION_SUELO       := Rect2(-0.3079071, 28.066624, 311.5434, 84.91786)
const _TEXTURA_CARROS     := preload("res://assets/objetos/carro_daño.png")
const RESPAWN_DELAY       := 6.0

@onready var jugador     : CharacterBody2D = $Jugador
@onready var hud         : CanvasLayer     = $HUD
@onready var ui_pregunta : CanvasLayer     = $UI_Pregunta
@onready var gm          : Node            = $GameManager

var _pregunta_pendiente: bool = false

func _ready() -> void:
	get_tree().debug_collisions_hint = false
	MusicManager.play_gameplay()
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

	_enemigo(Vector2(200,  160))
	_enemigo(Vector2(550,  160))
	_enemigo(Vector2(1200, 160))

	_enemigo_plat(Vector2(150,  140), 180)
	_enemigo_plat(Vector2(650,  130), 160)
	_enemigo_plat(Vector2(1150, 120), 180)

	_enemigo_disp(Vector2(400,  75))
	_enemigo_disp(Vector2(900,  55))
	_enemigo_disp(Vector2(1350, 45))

	_obstaculo(Vector2(320,  184))
	_obstaculo(Vector2(500,  184))
	_obstaculo(Vector2(700,  184))
	_obstaculo(Vector2(980,  184))

	var z1 := [Vector2(150,140), Vector2(400,100), Vector2(650,130), Vector2(900,80), Vector2(1150,120), Vector2(1350,70)]
	z1.shuffle()
	_carro_plat(z1[0])
	_carro_plat(z1[1])

	_objeto(Vector2(430, 74), "facil")
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
	_enemigo(Vector2(2050, 160))
	_enemigo(Vector2(2450, 160))
	_enemigo(Vector2(2950, 160))

	_enemigo_plat(Vector2(1600, 110), 200)
	_enemigo_plat(Vector2(1850,  70), 180)
	_enemigo_plat(Vector2(2350,  80), 200)
	_enemigo_plat(Vector2(2600, 110), 180)

	_enemigo_disp(Vector2(1600,  85))
	_enemigo_disp(Vector2(1850,  45))
	_enemigo_disp(Vector2(2350,  55))
	_enemigo_disp(Vector2(2850,  35))

	_obstaculo(Vector2(1550, 184))
	_obstaculo(Vector2(1800, 184))
	_obstaculo(Vector2(2000, 184))
	_obstaculo(Vector2(2300, 184))
	_obstaculo(Vector2(2480, 184))
	_obstaculo(Vector2(2650, 184))
	_obstaculo(Vector2(2800, 184))

	var z2 := [Vector2(1600,110), Vector2(1850,70), Vector2(2100,120), Vector2(2350,80), Vector2(2600,110), Vector2(2850,60)]
	z2.shuffle()
	_carro_plat(z2[0])
	_carro_plat(z2[1])

	_objeto(Vector2(2100, 94), "media")
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
	_enemigo(Vector2(3500, 160))
	_enemigo(Vector2(3700, 160))
	_enemigo(Vector2(4200, 160))

	_enemigo_plat(Vector2(3100,  90), 180)
	_enemigo_plat(Vector2(3350,  60), 200)
	_enemigo_plat(Vector2(3600, 110), 160)
	_enemigo_plat(Vector2(3850,  75), 180)
	_enemigo_plat(Vector2(4100, 120), 200)
	_enemigo_plat(Vector2(4350,  65), 160)

	_enemigo_disp(Vector2(3100,  65))
	_enemigo_disp(Vector2(3350,  35))
	_enemigo_disp(Vector2(3850,  50))
	_enemigo_disp(Vector2(4350,  40))

	_obstaculo(Vector2(3100, 184))
	_obstaculo(Vector2(3250, 184))
	_obstaculo(Vector2(3500, 184))
	_obstaculo(Vector2(3750, 184))
	_obstaculo(Vector2(3950, 184))
	_obstaculo(Vector2(4200, 184))
	_obstaculo(Vector2(4350, 184))
	_obstaculo(Vector2(4450, 184))

	var z3 := [Vector2(3100,90), Vector2(3350,60), Vector2(3600,110), Vector2(3850,75), Vector2(4100,120), Vector2(4350,65)]
	z3.shuffle()
	_carro_plat(z3[0])
	_carro_plat(z3[1])

	_objeto(Vector2(3600, 84), "media")
	_lampara(Vector2(3150, 184))
	_lampara(Vector2(3500, 184))
	_lampara(Vector2(4080, 184))
	_lampara(Vector2(4400, 184))

	# ── Zona 4 — aproximación al cuartel (x 4500..5200) ──────────────────────
	_plataforma(Vector2(4650, 100), 180)
	_plataforma(Vector2(4900,  70), 200)
	_plataforma(Vector2(5100, 110), 160)

	_enemigo(Vector2(4750, 160))
	_enemigo(Vector2(5050, 160))

	_enemigo_plat(Vector2(4650, 100), 180)
	_enemigo_plat(Vector2(4900,  70), 200)
	_enemigo_plat(Vector2(5100, 110), 160)

	_enemigo_disp(Vector2(4650,  75))
	_enemigo_disp(Vector2(4900,  45))
	_enemigo_disp(Vector2(5100,  85))

	_obstaculo(Vector2(4800, 184))
	_obstaculo(Vector2(4950, 184))
	_obstaculo(Vector2(5000, 184))
	_obstaculo(Vector2(5180, 184))

	var z4 := [Vector2(4650,100), Vector2(4900,70), Vector2(5100,110)]
	z4.shuffle()
	_carro_plat(z4[0])

	_objeto(Vector2(4750, 168), "dificil")
	_lampara(Vector2(4620, 184))
	_lampara(Vector2(4880, 184))
	_lampara(Vector2(5060, 184))
	_lampara(Vector2(5200, 184))

	# ── Base enemiga final (x 5500) ──────────────────────────────────────────
	_base_meta(Vector2(5500, 152))
	_enemigo(Vector2(5280, 160))
	_enemigo(Vector2(5330, 160))
	_enemigo(Vector2(5660, 160))
	_enemigo(Vector2(5720, 160))
	_enemigo_disp(Vector2(5450,  90))
	_enemigo_disp(Vector2(5550,  90))
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

	var sprite := Sprite2D.new()
	sprite.texture = _TEXTURA_SUELO
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_rect = _REGION_SUELO
	sprite.scale = Vector2(ancho / 311.5434, 0.2951808)
	sprite.position = Vector2(0.0, -2.0)
	sprite.z_index = 1
	body.add_child(sprite)


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
	var v: int = e.vida
	e.enemigo_muerto.connect(func(): _programar_respawn(pos, false, v))

func _enemigo_disp(pos: Vector2) -> void:
	var e := ESCENA_ENEMIGO_DISP.instantiate()
	e.position = pos
	add_child(e)
	var v: int = e.vida
	e.enemigo_muerto.connect(func(): _programar_respawn(pos, true, v))

func _enemigo_plat(plat_pos: Vector2, ancho: float) -> void:
	# Y: plat_pos.y - 10 (top de plataforma) - 24 (offset igual al suelo) = plat_pos.y - 34
	_spawn_plat(Vector2(plat_pos.x, plat_pos.y - 34), ancho, 3)

func _spawn_plat(pos: Vector2, ancho: float, v: int) -> void:
	var e := ESCENA_ENEMIGO.instantiate()
	e.vida = v
	e.position = pos
	var margen := 12.0
	e.set("_limite_izq", pos.x - ancho * 0.5 + margen)
	e.set("_limite_der", pos.x + ancho * 0.5 - margen)
	add_child(e)
	e.enemigo_muerto.connect(func():
		await get_tree().create_timer(RESPAWN_DELAY).timeout
		if is_inside_tree() and gm.jugando:
			_spawn_plat(pos, ancho, v)
	)

func _carro_plat(plat_pos: Vector2) -> void:
	# Regiones exactas: 4 columnas × fila 0 (y=6-29, h=24)
	# cada celda es un carro individual detectado por análisis de píxeles
	var regiones := [
		Rect2(  6, 6, 26, 24),  # tipo 1
		Rect2( 38, 6, 26, 24),  # tipo 2
		Rect2( 73, 6, 21, 24),  # tipo 3
		Rect2(105, 6, 20, 24),  # tipo 4
	]
	const ESCALA := 1.0
	var region: Rect2 = regiones[randi() % 4]
	var sw := region.size.x * ESCALA
	var sh := region.size.y * ESCALA  # 48 px

	# Carro apoyado en la superficie de la plataforma
	var pos := Vector2(plat_pos.x, plat_pos.y - 10.0 - sh * 0.5)

	var body := StaticBody2D.new()
	body.position = pos
	body.add_to_group("carro_danio")
	# Capa 2: el jugador la detecta (añadida en _ready) pero el enemigo volador no
	body.collision_layer = 2
	body.collision_mask  = 0
	add_child(body)

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(sw * 0.85, sh)
	col.shape = rect
	body.add_child(col)

	var atlas := AtlasTexture.new()
	atlas.atlas  = _TEXTURA_CARROS
	atlas.region = region
	var sprite := Sprite2D.new()
	sprite.texture        = atlas
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale          = Vector2(ESCALA, ESCALA)
	sprite.z_index        = 1
	body.add_child(sprite)

func _programar_respawn(pos: Vector2, es_disp: bool, vida_spawn: int) -> void:
	await get_tree().create_timer(RESPAWN_DELAY).timeout
	if not is_inside_tree() or not gm.jugando:
		return
	var e: CharacterBody2D
	if es_disp:
		e = ESCENA_ENEMIGO_DISP.instantiate()
	else:
		e = ESCENA_ENEMIGO.instantiate()
	e.vida = vida_spawn
	e.position = pos
	add_child(e)
	e.enemigo_muerto.connect(func(): _programar_respawn(pos, es_disp, vida_spawn))

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

func _on_respuesta_incorrecta(pista: String) -> void:
	jugador.recibir_danio(1)
	hud.actualizar_vida(jugador.sistema_vida.corazones)
	ui_pregunta.mostrar_resultado(false, pista)
	_pregunta_pendiente = false

func _on_jugador_vida_cambiada(corazones: int) -> void:
	hud.actualizar_vida(corazones)

func _on_juego_terminado(victoria: bool) -> void:
	if victoria:
		hud.mostrar_mensaje("¡NIVEL 1 COMPLETADO! Siguiente nivel...", 2.0)
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/Nivel2.tscn")
	else:
		MusicManager.stop()
		var capa := CanvasLayer.new()
		capa.layer = 100
		get_tree().root.add_child(capa)
		var pantalla: Control = load("res://scenes/PantallaFinal.tscn").instantiate()
		capa.add_child(pantalla)
		pantalla.configurar(false, "res://scenes/Nivel1.tscn")
  
