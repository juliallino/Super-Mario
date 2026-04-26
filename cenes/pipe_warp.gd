extends Area2D

@export var destino: NodePath
@export var direcao_entrada: Vector2 = Vector2(0, 1)

var teleportando = false
var jogador_dentro = false
var _jogador_ref = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if not body.has_method("pegar_flor_de_fogo"):
		return
	jogador_dentro = true
	_jogador_ref = body

func _on_body_exited(body):
	if not body.has_method("pegar_flor_de_fogo"):
		return
	jogador_dentro = false
	_jogador_ref = null

# Verifica o input a cada frame enquanto o jogador está na área
func _process(_delta):
	if not jogador_dentro:
		return
	if teleportando:
		return
	if destino == null or destino.is_empty():
		return
	if _jogador_ref == null:
		return

	# Só entra se o jogador estiver NO CHÃO e pressionar a direção
	if direcao_entrada == Vector2(0, 1):
		if Input.is_action_just_pressed("down") and _jogador_ref.is_on_floor():
			teleportando = true
			_fazer_teletransporte(_jogador_ref)

	elif direcao_entrada == Vector2(0, -1):
		if Input.is_action_just_pressed("jump") and _jogador_ref.is_on_floor():
			teleportando = true
			_fazer_teletransporte(_jogador_ref)

	elif direcao_entrada == Vector2(1, 0):
		if Input.is_action_just_pressed("right"):
			teleportando = true
			_fazer_teletransporte(_jogador_ref)

	elif direcao_entrada == Vector2(-1, 0):
		if Input.is_action_just_pressed("left"):
			teleportando = true
			_fazer_teletransporte(_jogador_ref)

func _fazer_teletransporte(jogador):
	jogador.controle_ativo = false
	jogador.velocity = Vector2.ZERO

	# Anima entrando no cano
	var tween = create_tween()
	tween.tween_property(jogador, "position", jogador.position + direcao_entrada * 40, 0.35)
	await tween.finished

	await fade_out()

	# Teletransporta
	var no_destino = get_node(destino)
	print("Destino: ", no_destino.name)
	print("Filhos do destino:")
	for filho in no_destino.get_children():
		print("  - ", filho.name)
	var saida = no_destino.get_node_or_null("SaidaMarcador")
	if saida:
		print("Saida global: ", saida.global_position)
		jogador.global_position = saida.global_position
	else:
		print("SaidaMarcador nao encontrado!")
		jogador.global_position = no_destino.global_position + Vector2(0, -80)

	await fade_in()

	# Espera um frame antes de reativar para evitar re-entrada imediata
	await get_tree().process_frame
	await get_tree().process_frame

	jogador.controle_ativo = true
	teleportando = false

func fade_out():
	var overlay = get_tree().get_first_node_in_group("fade_overlay")
	if overlay == null:
		return
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.25)
	await tween.finished

func fade_in():
	var overlay = get_tree().get_first_node_in_group("fade_overlay")
	if overlay == null:
		return
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.25)
	await tween.finished
