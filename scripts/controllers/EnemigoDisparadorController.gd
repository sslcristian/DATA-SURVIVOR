extends CharacterBody2D

const GRAVEDAD      := 980.0
const VELOCIDAD_PAT := 50.0
const VELOCIDAD_PER := 100.0
const RANGO_ATAQUE  := 200.0
const DISTANCIA_MIN := 120.0
const INTERVALO_ATK := 2.0
const ALTURA_VUELO  := 55.0
const BOB_AMPLITUD  := 8.0
const BOB_VELOCIDAD := 2.5

var modelo := EnemigoModel.new()

var vida: int = 2:
	get: return modelo.vida
	set(v): modelo.vida = v

var danio: int = 1:
	get: return modelo.danio
	set(v): modelo.danio = v

var muerto: bool = false

var _barra_vida    : Node2D
var _barra_relleno : ColorRect

var _dir_patrulla  := 1
var _tiempo_atk    := INTERVALO_ATK
var _jugador: Node2D = null
var _pos_inicial: Vector2
var _bob_tiempo: float = 0.0

var _limite_izq: float = -INF
var _limite_der: float =  INF

@onready var animacion : AnimatedSprite2D = $AnimatedSprite2D
@onready var detector  : Area2D           = $Detector
@onready var punto_a   : Marker2D         = $PuntoA
@onready var punto_b   : Marker2D         = $PuntoB

signal enemigo_muerto

func _ready() -> void:
	modelo.vida_max = modelo.vida
	_pos_inicial = global_position
	detector.body_entered.connect(_on_detector_body_entered)
	detector.body_exited.connect(_on_detector_body_exited)
	animacion.animation_finished.connect(_on_animation_finished)
	_crear_barra_vida()

func _physics_process(delta: float) -> void:
	if muerto:
		velocity.y += GRAVEDAD * delta
		move_and_slide()
		return

	_bob_tiempo += delta
	_tiempo_atk += delta

	if _jugador:
		_perseguir_o_atacar()
	else:
		_patrullar()
	move_and_slide()

func _patrullar() -> void:
	velocity.x = VELOCIDAD_PAT * _dir_patrulla
	animacion.flip_h = _dir_patrulla < 0
	if animacion.animation != &"idle":
		animacion.play("idle")

	var objetivo_y := _pos_inicial.y + sin(_bob_tiempo * BOB_VELOCIDAD) * BOB_AMPLITUD
	velocity.y = (objetivo_y - global_position.y) * 8.0

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
	animacion.flip_h = _jugador.global_position.x < global_position.x

	var objetivo_y := _jugador.global_position.y - ALTURA_VUELO + sin(_bob_tiempo * BOB_VELOCIDAD) * BOB_AMPLITUD
	velocity.y = clampf((objetivo_y - global_position.y) * 6.0, -VELOCIDAD_PER, VELOCIDAD_PER)

	if dist < DISTANCIA_MIN:
		var dir: float = signf(global_position.x - _jugador.global_position.x)
		velocity.x = VELOCIDAD_PAT * dir
		if animacion.animation != &"walk":
			animacion.play("walk")
	elif dist <= RANGO_ATAQUE:
		velocity.x = 0
		if animacion.animation != &"fire" and animacion.animation != &"idle":
			animacion.play("idle")
		if _tiempo_atk >= INTERVALO_ATK and animacion.animation != &"fire":
			_disparar()
	else:
		var dir: float = signf(_jugador.global_position.x - global_position.x)
		velocity.x = VELOCIDAD_PER * dir
		if animacion.animation != &"walk":
			animacion.play("walk")

func _disparar() -> void:
	_tiempo_atk = 0.0
	animacion.play("fire")
	var espacio := get_world_2d().direct_space_state
	var dir_x := -1.0 if animacion.flip_h else 1.0
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(dir_x * 400.0, 0.0)
	)
	query.exclude = [self]
	var hit := espacio.intersect_ray(query)
	if hit and hit.collider.is_in_group("jugador"):
		hit.collider.recibir_danio(danio)
	_spawn_laser(dir_x, hit)

func _spawn_laser(dir_x: float, hit: Dictionary) -> void:
	var laser := Sprite2D.new()
	laser.texture = preload("res://assets/enemigos/laser-flash.png")
	laser.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	laser.modulate = Color(1.0, 0.35, 0.1, 1.0)
	laser.scale = Vector2(0.4, 0.4)
	laser.z_index = 2
	get_parent().add_child(laser)
	laser.global_position = global_position + Vector2(dir_x * 18.0, -6.0)
	var destino := laser.global_position + Vector2(dir_x * 400.0, 0.0) if hit.is_empty() \
		else (hit.position as Vector2)
	var tween := laser.create_tween()
	tween.tween_property(laser, "global_position", destino, 0.25)
	tween.tween_callback(laser.queue_free)

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
	_barra_vida.position = Vector2(-10.0, -22.0)
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
	var pct := clampf(float(vida) / float(modelo.vida_max), 0.0, 1.0)
	_barra_relleno.size.x = 20.0 * pct
	if pct > 0.5:
		_barra_relleno.color = Color(0.2, 0.85, 0.2, 1.0)
	elif pct > 0.25:
		_barra_relleno.color = Color(0.9, 0.65, 0.0, 1.0)
	else:
		_barra_relleno.color = Color(0.9, 0.1, 0.1, 1.0)

func _on_animation_finished() -> void:
	if animacion.animation == &"fire" and not muerto:
		animacion.play("idle")

func _on_detector_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		_jugador = body as Node2D

func _on_detector_body_exited(body: Node) -> void:
	if body == _jugador:
		_jugador = null
