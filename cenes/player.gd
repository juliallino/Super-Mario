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
@export var speed = 100.0
@export var jump_velocity = -350
@export_group("")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_pressed("jump") and velocity.y < 0:
		velocity.y *= 0.5

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, run_speed_damping * delta)

	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
	
	if direction > 0:
		$AnimatedSprite2D.animation = "right_walking"
	elif direction < 0:
		$AnimatedSprite2D.animation = "left_walking"
	else:
		$AnimatedSprite2D.animation = "stopped"

	move_and_slide()
