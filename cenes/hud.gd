extends CanvasLayer

signal reinicia
signal volta

func _ready():
	GameManager.vidas_changed.connect(atualizar_vidas)
	GameManager.pontos_changed.connect(atualizar_pontos)
	GameManager.game_over.connect(mostrar_game_over)
	GameManager.vitoria.connect(mostrar_vitoria)

	$PainelDurante.show()
	$PainelFimDeJogo.hide()

	atualizar_vidas()
	atualizar_pontos()
func _process(delta):
	pass
func atualizar_pontos():
	$PainelDurante/Placar.text = str(GameManager.pontos)
		
func atualizar_vidas():
	var vidas = GameManager.vidas
	
	$PainelDurante/BoxContainer/Coracao1.visible = vidas >= 1
	$PainelDurante/BoxContainer/Coracao2.visible = vidas >= 2
	$PainelDurante/BoxContainer/Coracao3.visible = vidas >= 3
func mostrar_game_over():
	$PainelDurante.hide()
	$PainelFimDeJogo.show()
	$PainelFimDeJogo/Mensagem.text = "Game Over"

func mostrar_vitoria():
	$PainelDurante.hide()
	$PainelFimDeJogo.show()
	$PainelFimDeJogo/Mensagem.text = "Parabéns! Você venceu!"
	
func _on_reenicia_pressed():
	GameManager.vidas = 3
	GameManager.pontos = 0
	get_tree().reload_current_scene()


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://cenas/menu.tscn")
