extends CharacterBody2D

class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode{
	SMALL,
	BIG,
	SHOOTING
}

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var area_collision_shape_2d = $Area2D/CollisionShape2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 300.0
@export var jump_velocity = -400.0
@export_group("")

var is_jumping = false
var player_mode = PlayerMode.SMALL

func _physics_process(delta):
	# CORREÇÃO DA GRAVIDADE: Usamos += para acumular a queda (aceleração)
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true

	# Pulo Variável (soltar o botão faz pular mais baixo)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	# Movimentação Horizontal
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
	
	# Atualiza as animações antes de mover
	update_animation(direction)
	
	move_and_slide()
	
func update_animation(direction):
	# 1. Define o prefixo baseado no modo atual
	var prefix = ""
	match player_mode:
		PlayerMode.SMALL:
			prefix = "small_"
		PlayerMode.BIG:
			prefix = "big_"
		PlayerMode.SHOOTING:
			prefix = "shooting_"

	# 2. Lógica para espelhar o sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	# 3. Lógica de estados de animação
	if not is_on_floor():
		# Se você tiver uma animação de queda separada, pode usar:
		# if velocity.y < 0: play("jump") else: play("fall")
		animated_sprite_2d.play(prefix + "jump")
	elif direction != 0:
		animated_sprite_2d.play(prefix + "run")
	else:
		animated_sprite_2d.play(prefix + "idle")
