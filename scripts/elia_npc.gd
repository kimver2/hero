class_name EliaNPC
extends CharacterBody2D

enum State { TRAPPED, RESCUED, FOLLOWING }

@export var move_speed: float = 135.0
@export var follow_distance: float = 38.0

var current_state: State = State.TRAPPED
var target_player: Node2D = null

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var chains: Node2D = $Visual/Chains
@onready var interact_area: Area2D = $InteractArea
@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	prompt_label.visible = false
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func set_state(state: State) -> void:
	current_state = state
	match current_state:
		State.TRAPPED:
			chains.visible = true
			prompt_label.visible = false
		State.RESCUED:
			chains.visible = false
			# 쇠사슬이 풀리는 정화 빛 이펙트
			var tween = create_tween()
			visual.modulate = Color(2.5, 2.5, 1.5)
			tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.5)
		State.FOLLOWING:
			chains.visible = false
			prompt_label.visible = false
			var players = get_tree().get_nodes_in_group("player")
			if not players.is_empty():
				target_player = players[0]

func _physics_process(delta: float) -> void:
	if current_state != State.FOLLOWING:
		return
	
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			target_player = players[0]
		return
	
	var dist = global_position.distance_to(target_player.global_position)
	if dist > follow_distance:
		var dir = (target_player.global_position - global_position).normalized()
		velocity = dir * move_speed
		
		if dir.x < 0:
			visual.scale.x = -1.0
		elif dir.x > 0:
			visual.scale.x = 1.0
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if current_state == State.TRAPPED and body.is_in_group("player"):
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		prompt_label.visible = false
