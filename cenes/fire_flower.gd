extends Area2D

@export var bob_amplitude = 4.0
@export var bob_speed = 2.0

var start_y = 0.0
var tempo = 0.0
var coletada = false

func _ready():
	start_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta):
	tempo += delta * bob_speed
	position.y = start_y + sin(tempo) * bob_amplitude

func _on_body_entered(body):
	if coletada:
		return
	if body.has_method("pegar_flor_de_fogo"):
		coletada = true
		body.pegar_flor_de_fogo()
		queue_free()
