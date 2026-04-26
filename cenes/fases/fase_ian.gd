extends Node


func _ready():
	if GameManager.estado != GameManager.GameState.JOGANDO:
		GameManager.iniciar_jogo()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
