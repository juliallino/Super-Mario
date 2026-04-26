extends CharacterBody2D
class_name Player

enum PlayerMode {
	SMALL,
	BIG,
	SHOOTING
}

const POINTS_LABEL_SCENE = preload("res://cenes/points_label.tscn")
const FIREBALL_SCENE = preload("res://cenes/fire_ball.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var area_collision_shape_2d = $Area2D/CollisionShape2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D
@onready var area_2d = $Area2D

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 300.0
@export var jump_velocity = -500.0
@export_group("")

@export_group("Stomping Enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 145
@export var stomp_y_velocity = -150
@export_group("")

@export_group("Fire Mario")
@export var shoot_cooldown_time = 0.4
@export_group("")

var is_jumping = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_mode = PlayerMode.SMALL
var is_dead = false

# Fire Mario
var shoot_cooldown = 0.0
var fireballs_on_screen = 0
var controle_ativo = true
func _ready():
	add_to_group("player")
	
func _physics_process(delta):
	if not controle_ativo:
		return
	if GameManager.estado != GameManager.GameState.JOGANDO:
		return

	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true

	# Pulo variável
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	# Movimento horizontal
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)

	# Tiro de fogo
	if player_mode == PlayerMode.SHOOTING:
		shoot_cooldown -= delta
		if Input.is_action_just_pressed("shoot") and shoot_cooldown <= 0 and fireballs_on_screen < 2:
			atirar()

	update_animation(direction)
	move_and_slide()

func update_animation(direction):
	var prefix = ""
	match player_mode:
		PlayerMode.SMALL:
			prefix = "small_"
		PlayerMode.BIG:
			prefix = "big_"
		PlayerMode.SHOOTING:
			prefix = "shooting_"

	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	if not is_on_floor():
		animated_sprite_2d.play(prefix + "jump")
	elif direction != 0:
		animated_sprite_2d.play(prefix + "run")
	else:
		animated_sprite_2d.play(prefix + "idle")

# ── Fire Mario ──────────────────────────────────────────────

func pegar_flor_de_fogo():
	player_mode = PlayerMode.SHOOTING
	atualizar_skin()

func perder_poder():
	player_mode = PlayerMode.SMALL
	atualizar_skin()

func atualizar_skin():
	if player_mode == PlayerMode.SHOOTING:
		# Deixa o sprite com tom avermelhado enquanto não houver spritesheet separado
		animated_sprite_2d.modulate = Color(1.0, 0.45, 0.1)
	else:
		animated_sprite_2d.modulate = Color(1, 1, 1)

func atirar():
	if FIREBALL_SCENE == null:
		push_error("fireball.tscn não encontrada em res://cenes/fireball.tscn")
		return

	var bola = FIREBALL_SCENE.instantiate()
	var direcao = -1.0 if animated_sprite_2d.flip_h else 1.0
	bola.global_position = global_position + Vector2(direcao * 20, -10)
	get_parent().add_child(bola)
	bola.lancar(Vector2(direcao, 0))
	fireballs_on_screen += 1
	bola.tree_exited.connect(func(): fireballs_on_screen -= 1)
	shoot_cooldown = shoot_cooldown_time


func _on_area_2d_area_entered(area):
	if area is Enemy:
		handle_enemy_collision(area)

func handle_enemy_collision(enemy: Enemy):
	if enemy == null or is_dead:
		return

	if is_instance_of(enemy, Koopa) and (enemy as Koopa).in_a_shell:
		var koopa = enemy as Koopa
		if koopa.horizontal_speed != 0:
			die()
		else:
			koopa.on_stomp(global_position)
	else:
		var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		if angle_of_collision > min_stomp_degree and max_stomp_degree > angle_of_collision:
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy)
		else:
			die()

func on_enemy_stomped():
	velocity.y = stomp_y_velocity

func spawn_points_label(enemy, pontos: int = 100):
		var points_label = POINTS_LABEL_SCENE.instantiate()
		points_label.position = enemy.position + Vector2(-20, -20)
		get_tree().root.add_child(points_label)
		points_label.definir_pontos(pontos)
		GameManager.pontos += pontos
		GameManager.pontos_changed.emit()

func die():
	if player_mode == PlayerMode.SHOOTING or player_mode == PlayerMode.BIG:
		perder_poder()
		return
	if is_dead: return
	is_dead = true
	animated_sprite_2d.play("small_death")
	set_physics_process(false)
	controle_ativo = false  
	GameManager.perder_vida()
	
	# Só recarrega se o jogo ainda não acabou
	if not GameManager.acabou:
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self, "position", position + Vector2(0, -48), 0.5)
		death_tween.chain().tween_property(self, "position", position + Vector2(0, 256), 1.0)
		death_tween.tween_callback(func(): get_tree().reload_current_scene())
		

func _on_death_zone_body_entered(body):
	if body == self and not is_dead:
		player_mode = PlayerMode.SMALL
		die()
