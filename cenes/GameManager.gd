extends Node

enum GameState {
	JOGANDO,
	GAME_OVER,
	VITORIA
}

var estado = GameState.JOGANDO

var vidas = 3
var pontos = 0
var tempo = 300.0
var tempo_rodando = false
var acabou = false

signal vidas_changed
signal pontos_changed
signal tempo_changed
signal game_over
signal vitoria

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	if not tempo_rodando or acabou:
		return

	tempo -= delta
	
	if tempo <= 0:
		tempo = 0
		tempo_changed.emit()
		perder_vida()
	else:
		tempo_changed.emit()

func iniciar_jogo():
	estado = GameState.JOGANDO
	acabou = false
	vidas = 3
	pontos = 0
	tempo = 300.0
	tempo_rodando = true

	get_tree().paused = false

	vidas_changed.emit()
	pontos_changed.emit()
	tempo_changed.emit()

func parar_jogo():
	tempo_rodando = false
	get_tree().paused = true

func perder_vida():
	if acabou: return
	vidas -= 1
	vidas_changed.emit()
	if vidas <= 0:
		acabou = true
		estado = GameState.GAME_OVER
		parar_jogo()
		game_over.emit()
	else:
		tempo = 300.0
		tempo_rodando = true  
		tempo_changed.emit()
		
func vencer():
	if acabou:
		return

	acabou = true
	estado = GameState.VITORIA
	parar_jogo()
	vitoria.emit()
