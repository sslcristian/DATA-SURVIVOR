class_name CombateController
extends Node

func procesar_combate(_atacante: Node, objetivo: Node, danio: int) -> void:
	if objetivo == null or not objetivo.has_method("recibir_danio"):
		return
	aplicar_danio(objetivo, danio)

func aplicar_danio(objetivo: Node, danio: int) -> void:
	objetivo.recibir_danio(danio)
