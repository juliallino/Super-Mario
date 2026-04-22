extends Node

const GOOMBA_SCENE = preload("res://cenes/goomba.tscn")
const KOOPA_SCENE  = preload("res://cenes/koopa.tscn")


@onready var world = $World  

func _ready():
	spawn_enemy(GOOMBA_SCENE, Vector2(200, 500))
	spawn_enemy(KOOPA_SCENE,  Vector2(400, 500))

func spawn_enemy(scene, pos: Vector2):
	var enemy = scene.instantiate()
	enemy.position = pos
	world.add_child(enemy)  
