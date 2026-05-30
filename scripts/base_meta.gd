extends StaticBody2D

signal alcanzada

var _activada := false

func _ready() -> void:
	$AreaDeteccion.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _activada:
		return
	if body.is_in_group("jugador"):
		_activada = true
		alcanzada.emit()
