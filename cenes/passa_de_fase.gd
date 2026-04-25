extends Area2D

@export var next_scene: String
var player_on_top: Player = null

func _on_body_entered(body):
	if body is Player:
		player_on_top = body

func _on_body_exited(body):
	if body is Player:
		player_on_top = null

func _physics_process(delta):
	if player_on_top:
		if Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_right") and player_on_top.is_on_floor():
			enter_pipe()

func enter_pipe():
	get_tree().change_scene_to_file(next_scene)
