extends CharacterBody2D

class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.


enum PlayerMode{
	SMALL,
	BIG,
	SHOOTING
}
signal points_scored(points: int)
const POINTS_LABEL_SCENE = preload("res://cenes/points_label.tscn")

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

var is_jumping = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_mode = PlayerMode.SMALL
var is_dead = false

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


func _on_area_2d_area_entered(area):
	if area is Enemy:
		handle_enemy_collision(area)

func handle_enemy_collision(enemy: Enemy):
	if enemy == null || is_dead:
		return
	
	if is_instance_of(enemy, Koopa) and (enemy as Koopa).in_a_shell:
		(enemy as Koopa).on_stomp(global_position)
	else:
		var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		if angle_of_collision > min_stomp_degree && max_stomp_degree > angle_of_collision:
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy)
		else:
			die()
			
func on_enemy_stomped():
	velocity.y = stomp_y_velocity

func spawn_points_label(enemy):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = enemy.position + Vector2(-20,-20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)

func die():
	if player_mode == PlayerMode.SMALL:
		is_dead = true
		animated_sprite_2d.play("small_death")
		set_physics_process(false)

		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self, "position", position + Vector2(0, -48), .5)
		death_tween.chain().tween_property(self, "position", position + Vector2(0, 256), 1)
		death_tween. tween_callback(func (): get_tree().reload_current_scene())

func _on_death_zone_body_entered(body):
	if body == self and not is_dead:
		die()


func _on_death_zone_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.


func _on_death_zone_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
