extends CharacterBody2D

const GRAVEDAD      := 980.0
const VELOCIDAD_PAT := 60.0
const VELOCIDAD_PER := 120.0
const RANGO_DETEC   := 200.0
const RANGO_ATAQUE  := 18.0
const INTERVALO_ATK := 1.5

var vida  : int = 3
var danio : int = 1
var muerto: bool = false

var _vida_max      : int
var _barra_vida    : Node2D
var _barra_relleno : ColorRect

var _dir_patrulla := 1
var _tiempo_atk   := 0.0
var _jugador: Node2D = null

var _limite_izq: float = -INF
var _limite_der: float =  INF

@onready var animacion   : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox      : Area2D           = $Hitbox
@onready var detector    : Area2D           = $Detector
@onready var punto_a     : Marker2D         = $PuntoA
@onready var punto_b     : Marker2D         = $PuntoB

signal enemigo_muerto

func _ready() -> void:
	_vida_max = vida
	detector.body_entered.connect(_on_detector_body_entered)
	detector.body_exited.connect(_on_detector_body_exited)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	_crear_barra_vida()

func _physics_process(delta: float) -> void:
	if muerto:
		return

	if not is_on_floor():
		velocity.y += GRAVEDAD * delta

	_tiempo_atk += delta

	if _jugador:
		_perseguir_o_atacar()
	else:
		_patrullar()

	move_and_slide()

func _patrullar() -> void:
	velocity.x = VELOCIDAD_PAT * _dir_patrulla
	animacion.flip_h = _dir_patrulla < 0
	animacion.play("walk")

	var pos_x := global_position.x
	if _limite_izq > -INF or _limite_der < INF:
		if _dir_patrulla == 1 and pos_x >= _limite_der:
			_dir_patrulla = -1
		elif _dir_patrulla == -1 and pos_x <= _limite_izq:
			_dir_patrulla = 1
	elif punto_a and punto_b:
		if _dir_patrulla == 1 and pos_x >= punto_b.global_position.x:
			_dir_patrulla = -1
		elif _dir_patrulla == -1 and pos_x <= punto_a.global_position.x:
			_dir_patrulla = 1

func _perseguir_o_atacar() -> void:
	var dist := global_position.distance_to(_jugador.global_position)
	if dist <= RANGO_ATAQUE:
		velocity.x = 0
		animacion.play("idle")
		if _tiempo_atk >= INTERVALO_ATK:
			_atacar()
	else:
		var dir: float = signf(_jugador.global_position.x - global_position.x)
		velocity.x = VELOCIDAD_PER * dir
		animacion.flip_h = dir < 0
		animacion.play("walk")

func _atacar() -> void:
	_tiempo_atk = 0.0
	animacion.play("fire")
	if _jugador and _jugador.has_method("recibir_danio"):
		_jugador.recibir_danio(danio)

func recibir_danio(cantidad: int) -> void:
	if muerto:
		return
	vida -= cantidad
	_actualizar_barra()
	if vida <= 0:
		_morir()

func _morir() -> void:
	muerto = true
	velocity = Vector2.ZERO
	if is_instance_valid(_barra_vida):
		_barra_vida.visible = false
	animacion.play("death")
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	await animacion.animation_finished
	emit_signal("enemigo_muerto")
	queue_free()

func _crear_barra_vida() -> void:
	_barra_vida = Node2D.new()
	_barra_vida.position = Vector2(-10.0, -13.0)
	_barra_vida.z_index = 5
	add_child(_barra_vida)

	var fondo := ColorRect.new()
	fondo.size = Vector2(20.0, 3.0)
	fondo.color = Color(0.1, 0.1, 0.1, 0.85)
	_barra_vida.add_child(fondo)

	_barra_relleno = ColorRect.new()
	_barra_relleno.size = Vector2(20.0, 3.0)
	_barra_relleno.color = Color(0.2, 0.85, 0.2, 1.0)
	_barra_vida.add_child(_barra_relleno)

func _actualizar_barra() -> void:
	if not is_instance_valid(_barra_relleno):
		return
	var pct := clampf(float(vida) / float(_vida_max), 0.0, 1.0)
	_barra_relleno.size.x = 20.0 * pct
	if pct > 0.5:
		_barra_relleno.color = Color(0.2, 0.85, 0.2, 1.0)
	elif pct > 0.25:
		_barra_relleno.color = Color(0.9, 0.65, 0.0, 1.0)
	else:
		_barra_relleno.color = Color(0.9, 0.1, 0.1, 1.0)

func _on_detector_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		_jugador = body as Node2D

func _on_detector_body_exited(body: Node) -> void:
	if body == _jugador:
		_jugador = null

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("jugador") and body.has_method("recibir_danio"):
		if _tiempo_atk >= INTERVALO_ATK:
			body.recibir_danio(danio)
			_tiempo_atk = 0.0
