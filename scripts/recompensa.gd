class_name Recompensa
extends RefCounted

enum Tipo { VIDA, DANIO, DEFENSA, LEGENDARIO }

var tipo: Tipo
var valor: int

func _init(p_tipo: Tipo, p_valor: int) -> void:
	tipo = p_tipo
	valor = p_valor

func aplicar(jugador: Node) -> void:
	match tipo:
		Tipo.VIDA:
			jugador.sistema_vida.recuperar_vida(valor)
		Tipo.DANIO:
			jugador.danio += valor
		Tipo.DEFENSA:
			jugador.defensa += valor
			jugador.actualizar_escudo()
		Tipo.LEGENDARIO:
			jugador.danio = 99
			jugador.sistema_vida.MAX_CORAZONES += 1
			jugador.sistema_vida.recuperar_vida(1)

func descripcion() -> String:
	match tipo:
		Tipo.VIDA:   return "+%d corazon(es)" % valor
		Tipo.DANIO:  return "+%d de daño" % valor
		Tipo.DEFENSA: return "+%d de defensa" % valor
		Tipo.LEGENDARIO: return "¡RECOMPENSA LEGENDARIA! Daño letal + 1 corazón extra"
	return ""
