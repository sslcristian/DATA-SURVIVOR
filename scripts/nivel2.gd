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
	# ── Zona 1 — zona desolada (x 0..2000) ────────────────────────────────────
	_plataforma(Vector2(200,  130), 200)
	_plataforma(Vector2(450,   90), 180)
	_plataforma(Vector2(700,  120), 200)
	_plataforma(Vector2(950,   70), 180)
	_plataforma(Vector2(1200, 110), 200)
	_plataforma(Vector2(1450,  60), 160)
	_plataforma(Vector2(1700, 100), 180)
	_plataforma(Vector2(1950,  70), 200)

	_enemigo(Vector2(250,  160))
	_enemigo(Vector2(600,  160))
	_enemigo_disp(Vector2(950,   52))
	_enemigo(Vector2(1300, 160))
	_enemigo_disp(Vector2(1450,  42))
	_enemigo(Vector2(1800, 160))

	_obstaculo(Vector2(150,  184))
	_obstaculo(Vector2(380,  184))
	_obstaculo(Vector2(550,  184))
	_obstaculo(Vector2(820,  184))
	_obstaculo(Vector2(1050, 184))
	_obstaculo(Vector2(1350, 184))
	_obstaculo(Vector2(1600, 184))
	_obstaculo(Vector2(1850, 184))

	var z1 := [Vector2(200,130), Vector2(450,90), Vector2(700,120), Vector2(950,70), Vector2(1200,110), Vector2(1450,60), Vector2(1700,100), Vector2(1950,70)]
	z1.shuffle()
	_carro_plat(z1[0])
	_carro_plat(z1[1])

	_objeto(Vector2(700, 102), "media")
	_lampara(Vector2(120,  184))
	_lampara(Vector2(480,  184))
	_lampara(Vector2(880,  184))
	_lampara(Vector2(1150, 184))
	_lampara(Vector2(1550, 184))
	_lampara(Vector2(1900, 184))

	# ── Zona 2 — zona industrial (x 2000..4000) ───────────────────────────────
	_plataforma(Vector2(2150, 100), 200)
	_plataforma(Vector2(2400,  60), 180)
	_plataforma(Vector2(2650, 110), 200)
	_plataforma(Vector2(2900,  75), 180)
	_plataforma(Vector2(3150, 120), 200)
	_plataforma(Vector2(3400,  65), 160)
	_plataforma(Vector2(3650, 100), 180)
	_plataforma(Vector2(3900,  55), 200)

	_enemigo(Vector2(2100, 160))
	_enemigo_disp(Vector2(2400,  42))
	_enemigo(Vector2(2700, 160))
	_enemigo_disp(Vector2(2900,  57))
	_enemigo(Vector2(3200, 160))
	_enemigo_disp(Vector2(3400,  47))
	_enemigo(Vector2(3700, 160))
	_enemigo_disp(Vector2(3900,  37))

	_obstaculo(Vector2(2050, 184))
	_obstaculo(Vector2(2250, 184))
	_obstaculo(Vector2(2500, 184))
	_obstaculo(Vector2(2750, 184))
	_obstaculo(Vector2(3000, 184))
	_obstaculo(Vector2(3250, 184))
	_obstaculo(Vector2(3500, 184))
	_obstaculo(Vector2(3750, 184))
	_obstaculo(Vector2(3950, 184))

	var z2 := [Vector2(2150,100), Vector2(2400,60), Vector2(2650,110), Vector2(2900,75), Vector2(3150,120), Vector2(3400,65), Vector2(3650,100), Vector2(3900,55)]
	z2.shuffle()
	_carro_plat(z2[0])
	_carro_plat(z2[1])

	_objeto(Vector2(2650,  92), "media")
	_objeto(Vector2(3150, 102), "dificil")
	_lampara(Vector2(2120, 184))
	_lampara(Vector2(2550, 184))
	_lampara(Vector2(2950, 184))
	_lampara(Vector2(3350, 184))
	_lampara(Vector2(3700, 184))

	# ── Zona 3 — zona radioactiva (x 4000..6000) ─────────────────────────────
	_plataforma(Vector2(4100, 110), 180)
	_plataforma(Vector2(4350,  70), 200)
	_plataforma(Vector2(4600, 120), 160)
	_plataforma(Vector2(4850,  75), 200)
	_plataforma(Vector2(5100, 110), 180)
	_plataforma(Vector2(5350,  60), 200)
	_plataforma(Vector2(5600, 100), 160)
	_plataforma(Vector2(5850,  65), 180)

	_enemigo(Vector2(4050, 160))
	_enemigo_disp(Vector2(4350,  52))
	_enemigo(Vector2(4650, 160))
	_enemigo_disp(Vector2(4850,  57))
	_enemigo(Vector2(5150, 160))
	_enemigo_disp(Vector2(5350,  42))
	_enemigo(Vector2(5650, 160))
	_enemigo_disp(Vector2(5850,  47))

	_obstaculo(Vector2(4150, 184))
	_obstaculo(Vector2(4400, 184))
	_obstaculo(Vector2(4700, 184))
	_obstaculo(Vector2(4950, 184))
	_obstaculo(Vector2(5200, 184))
	_obstaculo(Vector2(5450, 184))
	_obstaculo(Vector2(5700, 184))
	_obstaculo(Vector2(5900, 184))

	var z3 := [Vector2(4100,110), Vector2(4350,70), Vector2(4600,120), Vector2(4850,75), Vector2(5100,110), Vector2(5350,60), Vector2(5600,100), Vector2(5850,65)]
	z3.shuffle()
	_carro_plat(z3[0])
	_carro_plat(z3[1])

	_objeto(Vector2(4600, 102), "dificil")
	_objeto(Vector2(5350,  42), "dificil")
	_lampara(Vector2(4200, 184))
	_lampara(Vector2(4750, 184))
	_lampara(Vector2(5250, 184))
	_lampara(Vector2(5600, 184))
	_lampara(Vector2(5950, 184))

	# ── Zona 4 — aproximación (x 6000..7000) ─────────────────────────────────
	_plataforma(Vector2(6150, 100), 200)
	_plataforma(Vector2(6400,  65), 180)
	_plataforma(Vector2(6650, 110), 200)

	_enemigo(Vector2(6100, 160))
	_enemigo_disp(Vector2(6400,  47))
	_enemigo(Vector2(6500, 160))
	_enemigo_disp(Vector2(6650,  92))
	_enemigo(Vector2(6800, 160))

	_obstaculo(Vector2(6050, 184))
	_obstaculo(Vector2(6250, 184))
	_obstaculo(Vector2(6500, 184))
	_obstaculo(Vector2(6750, 184))

	var z4 := [Vector2(6150,100), Vector2(6400,65), Vector2(6650,110)]
	z4.shuffle()
	_carro_plat(z4[0])

	_objeto(Vector2(6150, 168), "dificil")
	_lampara(Vector2(6100, 184))
	_lampara(Vector2(6400, 184))
	_lampara(Vector2(6720, 184))

	# ── Base enemiga final (x 7300) ──────────────────────────────────────────
	_base_meta(Vector2(7300, 152))
	_enemigo(Vector2(7130, 160))
	_enemigo(Vector2(7450, 160))
	_enemigo_disp(Vector2(7300, 90))
	_lampara(Vector2(7200, 184))
	_lampara(Vector2(7400, 184))

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
	e.vida = 5
	e.position = pos
	add_child(e)
	e.enemigo_muerto.connect(func(): _programar_respawn(pos, false, 5))

func _enemigo_disp(pos: Vector2) -> void:
	var e := ESCENA_ENEMIGO_DISP.instantiate()
	e.vida = 3
	e.position = pos
	add_child(e)
	e.enemigo_muerto.connect(func(): _programar_respawn(pos, true, 3))

func _carro_plat(plat_pos: Vector2) -> void:
	var regiones := [
		Rect2(  6, 6, 26, 24),
		Rect2( 38, 6, 26, 24),
		Rect2( 73, 6, 21, 24),
		Rect2(105, 6, 20, 24),
	]
	const ESCALA := 1.0
	var region: Rect2 = regiones[randi() % 4]
	var sw := region.size.x * ESCALA
	var sh := region.size.y * ESCALA

	var pos := Vector2(plat_pos.x, plat_pos.y - 10.0 - sh * 0.5)

	var body := StaticBody2D.new()
	body.position = pos
	body.add_to_group("carro_danio")
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
	var capa := CanvasLayer.new()
	capa.layer = 100
	get_tree().root.add_child(capa)
	var pantalla: Control = load("res://scenes/PantallaFinal.tscn").instantiate()
	capa.add_child(pantalla)
	if victoria:
		pantalla.configurar(true, "res://scenes/Nivel1.tscn")
	else:
		pantalla.configurar(false, "res://scenes/Nivel2.tscn")
