extends Area2D

class_name Enemy

const POINTS_LABEL_SCENE = preload("res://cenes/points_label.tscn")

@export var horizontal_speed: float = 20.0
@export var vertical_speed: float = 100.0
var can_turn = true
@onready var ray_floor = $RayCastFloor
@onready var ray_edge = $RayCastEdge
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

func _process(delta):
	position.x -= horizontal_speed * delta

	# gravidade
	if !ray_floor.is_colliding():
		position.y += vertical_speed * delta

	# borda
	if !ray_edge.is_colliding():
		if can_turn:
			turn()
			can_turn = false
	else:
		can_turn = true

	
func turn():
	horizontal_speed *= -1
	ray_edge.target_position.x *= -1
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	
func die():
	horizontal_speed = 0
	vertical_speed = 0
	animated_sprite_2d.play("dead")
	
func die_from_hit():
	set_collision_layer_value(3, false)
	set_collision_mask_value(3, false)

	rotation_degrees = 180
	horizontal_speed = 0
	vertical_speed = 0

	var die_tween = get_tree().create_tween()
	die_tween.tween_property(self, "position", position + Vector2(0, -25), .2)
	die_tween.chain().tween_property(self, "position", position + Vector2(0, 500), 4)
	
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = self.position + Vector2(-20,-20)
	get_tree().root.add_child(points_label)
	
func _on_area_entered(area):
	if area is Koopa and (area as Koopa).in_a_shell and (area as Koopa).horizontal_speed != 0:
		die_from_hit()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if global_position.x < -200 or global_position.x > 2000:
		queue_free()
