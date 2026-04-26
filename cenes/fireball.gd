extends Area2D

@export var speed = 350.0
@export var gravidade = 500.0

var vel = Vector2.ZERO
var ativo = true

func lancar(direcao: Vector2):
	vel = direcao.normalized() * speed
	if direcao.x < 0:
		scale.x = -1

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(3.0).timeout.connect(queue_free)

func _physics_process(delta):
	if not ativo:
		return
	vel.y += gravidade * delta
	position += vel * delta
	if position.y > 2000:
		queue_free()

func _on_body_entered(body):
	if not ativo:
		return
	if body.is_in_group("enemy"):
		matar_inimigo(body)
	elif body.is_in_group("ground"):
		if vel.y > 0:
			vel.y = -180.0
		else:
			queue_free()

func _on_area_entered(area):
	if not ativo:
		return
	if area.is_in_group("enemy"):
		matar_inimigo(area)

func matar_inimigo(inimigo):
	ativo = false
	if inimigo.has_method("die"):
		inimigo.die()
	else:
		inimigo.queue_free()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.spawn_points_label(inimigo, 200)
		
	queue_free()
