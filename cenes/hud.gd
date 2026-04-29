extends CanvasLayer

signal reinicia
signal volta

var fim_ativo = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  

	GameManager.vidas_changed.connect(atualizar_vidas)
	GameManager.pontos_changed.connect(atualizar_pontos)
	GameManager.tempo_changed.connect(atualizar_tempo)
	GameManager.game_over.connect(mostrar_game_over)
	GameManager.vitoria.connect(mostrar_vitoria)

	$PainelDurante.show()
	$PainelFimDeJogo.hide()

	atualizar_vidas()
	atualizar_pontos()
	atualizar_tempo()
	if not GameManager.tempo_rodando:
		GameManager.iniciar_jogo()

func atualizar_pontos():
	$PainelDurante/Placar.text = str(GameManager.pontos)

func atualizar_vidas():
	var vidas = GameManager.vidas
	$PainelDurante/BoxContainer/Coracao1.visible = vidas >= 1
	$PainelDurante/BoxContainer/Coracao2.visible = vidas >= 2
	$PainelDurante/BoxContainer/Coracao3.visible = vidas >= 3

func atualizar_tempo():
	var segundos = ceili(GameManager.tempo)
	$PainelDurante/Timer.text = str(segundos).lpad(3, "0")

	if segundos <= 60:
		$PainelDurante/Timer.modulate = Color(1, 0.2, 0.2)
	else:
		$PainelDurante/Timer.modulate = Color(1, 1, 1)

func mostrar_game_over():
	if fim_ativo:
		return
	fim_ativo = true

	$PainelDurante.hide()
	$PainelFimDeJogo.show()
	$PainelFimDeJogo/Mensagem.text = "Game Over"

func mostrar_vitoria():
	if fim_ativo:
		return
	fim_ativo = true

	$PainelDurante.hide()
	$PainelFimDeJogo.show()
	$PainelFimDeJogo/Mensagem.text = "Parabéns! Você venceu!"

func _on_reenicia_pressed():
	fim_ativo = false
	GameManager.iniciar_jogo()
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://cenes/menu.tscn")
