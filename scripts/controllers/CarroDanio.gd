extends Area2D

const DANIO: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(DANIO)
