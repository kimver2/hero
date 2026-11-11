class_name KaradNPC
extends CharacterBody2D

@export var move_speed: float = 145.0
var target_player: Node2D = null
var is_following: bool = false

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D

func _ready() -> void:
	pass

func start_following() -> void:
	is_following = true
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		target_player = players[0]

func _physics_process(delta: float) -> void:
	if not is_following:
		return
	
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			target_player = players[0]
		return
	
	# 엘리아보다 조금 더 뒤에서 호위하며 따라다님
	var dist = global_position.distance_to(target_player.global_position)
	if dist > 65.0:
		var dir = (target_player.global_position - global_position).normalized()
		velocity = dir * move_speed
		
		if dir.x < 0:
			visual.scale.x = -1.0
		elif dir.x > 0:
			visual.scale.x = 1.0
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO
