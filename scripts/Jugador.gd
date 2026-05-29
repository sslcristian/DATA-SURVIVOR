extends CharacterBody2D

const VELOCIDAD    := 200.0
const FUERZA_SALTO := -420.0
const GRAVEDAD     := 980.0

var danio   : int = 1
var defensa : int = 0
var atacando: bool = false
var muerto  : bool = false
var invulnerable: bool = false

var sistema_vida: SistemaVida

@onready var animacion   : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox      : Area2D           = $HitboxAtaque
@onready var area_inter  : Area2D           = $AreaInteraccion
@onready var timer_inv   : Timer            = $TimerInvulnerabilidad
@onready var timer_atk   : Timer            = $TimerAtaque

signal objeto_cercano(objeto)
signal jugador_muerto

func _ready() -> void:
	add_to_group("jugador")
	set_collision_mask_value(2, true)  # detecta carros (capa 2) además del mundo (capa 1)
	sistema_vida = SistemaVida.new()
	add_child(sistema_vida)
	sistema_vida.sin_vida.connect(_al_morir)
	hitbox.monitoring = true
	hitbox.body_entered.connect(_on_hitbox_ataque_body_entered)
	area_inter.body_entered.connect(_on_area_interaccion_body_entered)
	area_inter.body_exited.connect(_on_area_interaccion_body_exited)
	timer_atk.timeout.connect(_on_timer_ataque_timeout)
	timer_inv.timeout.connect(_on_timer_invulnerabilidad_timeout)

func _physics_process(delta: float) -> void:
	if muerto:
		return
	if not is_on_floor():
		velocity.y += GRAVEDAD * delta
	_manejar_ataque()
	_manejar_movimiento()
	_manejar_salto()
	move_and_slide()
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider().is_in_group("carro_danio"):
			recibir_danio(1)
			break

func _set_anim(nombre: StringName) -> void:
	if animacion.animation != nombre:
		animacion.play(nombre)

func _manejar_movimiento() -> void:
	var anim := animacion.animation
	if anim == &"death":
		return
	if atacando:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)
		return

	if Input.is_action_pressed("mover_derecha"):
		velocity.x = VELOCIDAD
		animacion.flip_h = false
		if is_on_floor():
			_set_anim(&"walk")
	elif Input.is_action_pressed("mover_izquierda"):
		velocity.x = -VELOCIDAD
		animacion.flip_h = true
		if is_on_floor():
			_set_anim(&"walk")
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)
		if is_on_floor():
			_set_anim(&"idle")

func _manejar_salto() -> void:
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = FUERZA_SALTO

func _manejar_ataque() -> void:
	if Input.is_action_just_pressed("atacar") and not atacando:
		atacando = true
		animacion.play("fire")
		_disparar()
		timer_atk.start()

func _disparar() -> void:
	var espacio := get_world_2d().direct_space_state
	var dir_x := -1.0 if animacion.flip_h else 1.0
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(dir_x * 500.0, 0.0)
	)
	query.exclude = [self]
	var hit := espacio.intersect_ray(query)
	if hit and hit.collider.is_in_group("enemigo"):
		hit.collider.recibir_danio(danio)
	_spawn_bala(dir_x, hit)

func _spawn_bala(dir_x: float, hit: Dictionary) -> void:
	var bala := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://assets/personaje/bullets+plasma.png")
	atlas.region = Rect2(0, 0, 8, 8)
	bala.texture = atlas
	bala.scale = Vector2(3.0, 3.0)
	bala.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bala.z_index = 2
	get_parent().add_child(bala)
	bala.global_position = global_position + Vector2(dir_x * 20.0, -4.0)
	var destino := bala.global_position + Vector2(dir_x * 500.0, 0.0) if hit.is_empty() \
		else (hit.position as Vector2)
	var tween := bala.create_tween()
	tween.tween_property(bala, "global_position", destino, 0.40)
	tween.tween_callback(bala.queue_free)

func recibir_danio(cantidad: int = 1) -> void:
	if invulnerable or muerto:
		return
	var danio_real: int = max(1, cantidad - defensa)
	sistema_vida.reducir_vida(danio_real)
	if sistema_vida.esta_vivo():
		invulnerable = true
		timer_inv.start()
		var tween := create_tween().set_loops(4)
		tween.tween_property(animacion, "modulate", Color(1.0, 0.15, 0.15, 0.5), 0.06)
		tween.tween_property(animacion, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.06)
	else:
		_al_morir()

func _al_morir() -> void:
	muerto = true
	animacion.play("death")
	emit_signal("jugador_muerto")

func _on_timer_ataque_timeout() -> void:
	atacando = false
	if is_on_floor() and animacion.animation == &"fire":
		animacion.play("idle")

func _on_timer_invulnerabilidad_timeout() -> void:
	invulnerable = false
	animacion.modulate = Color.WHITE

var _objeto_actual: Node = null

func _on_area_interaccion_body_entered(body: Node) -> void:
	if body.is_in_group("interactivo"):
		_objeto_actual = body
		emit_signal("objeto_cercano", body)

func _on_area_interaccion_body_exited(body: Node) -> void:
	if body == _objeto_actual:
		_objeto_actual = null

func interactuar() -> void:
	if _objeto_actual and _objeto_actual.has_method("activar"):
		_objeto_actual.activar()

func _on_hitbox_ataque_body_entered(body: Node) -> void:
	if not atacando:
		return
	if body.is_in_group("enemigo") and body.has_method("recibir_danio"):
		body.recibir_danio(danio)

func _input(event: InputEvent) -> void:
	if not muerto and event is InputEventKey:
		if event.is_action_pressed("interactuar"):
			interactuar()
