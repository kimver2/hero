class_name BossPriest
extends CharacterBody2D

signal health_changed(current: int, max_val: int)
signal defeated

enum State { IDLE, CAST_PROJECTILES, TELEPORT, CAST_BURST, DEAD }

@export var max_hp: int = 120
var current_hp: int = 120
var current_state: State = State.IDLE

var target_player: Node2D = null
var action_timer: float = 1.5
var is_active: bool = false

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var hurtbox: Area2D = $Hurtbox

const DarkProjectileScene = preload("res://scenes/effects/dark_projectile.tscn")
const FloatingDamageScene = preload("res://scripts/floating_damage.gd")

func _ready() -> void:
	current_hp = max_hp
	hurtbox.add_to_group("hurtbox")
	emit_signal("health_changed", current_hp, max_hp)

func start_boss_battle() -> void:
	is_active = true
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		target_player = players[0]

func _physics_process(delta: float) -> void:
	if not is_active or current_state == State.DEAD:
		return
	
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			target_player = players[0]
		return
	
	var dir_to_player = (target_player.global_position - global_position).normalized()
	if dir_to_player.x < 0:
		visual.scale.x = -1.0
	elif dir_to_player.x > 0:
		visual.scale.x = 1.0
	
	# 플레이어가 너무 가까이 붙으면 긴급 순간이동 회피
	var dist = global_position.distance_to(target_player.global_position)
	if dist < 60.0 and current_state == State.IDLE:
		_teleport_away()
		return
	
	action_timer -= delta
	if action_timer <= 0.0 and current_state == State.IDLE:
		var rand_choice = randi() % 2
		if rand_choice == 0:
			_cast_projectiles(dir_to_player)
		else:
			_cast_burst()

func _cast_projectiles(dir: Vector2) -> void:
	current_state = State.CAST_PROJECTILES
	
	# 지팡이 충전 예고 (보라빛 플래시)
	var tween = create_tween()
	visual.modulate = Color(2.0, 0.4, 2.5)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.35)
	
	await get_tree().create_timer(0.35).timeout
	if current_state == State.DEAD:
		return
	
	# 마탄 3연발 발사 (0.15초 간격)
	for i in range(3):
		if current_state == State.DEAD or not is_instance_valid(target_player):
			break
		var current_dir = (target_player.global_position - global_position).normalized()
		_spawn_projectile(current_dir)
		await get_tree().create_timer(0.18).timeout
	
	action_timer = 2.0
	current_state = State.IDLE

func _cast_burst() -> void:
	current_state = State.CAST_BURST
	
	# 360도 광역 방출 예고
	var tween = create_tween()
	visual.modulate = Color(3.0, 0.2, 0.2)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.5)
	
	await get_tree().create_timer(0.5).timeout
	if current_state == State.DEAD:
		return
	
	# 8방향 마탄 발사
	for i in range(8):
		var angle = (PI * 2 / 8.0) * i
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_projectile(dir)
	
	action_timer = 2.4
	current_state = State.IDLE

func _teleport_away() -> void:
	current_state = State.TELEPORT
	
	# 사라짐 연출
	var tween = create_tween()
	tween.tween_property(visual, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(visual, "scale", Vector2(0.2, 2.0), 0.2)
	await tween.finished
	
	# 플레이어로부터 먼 위치로 이동 (제단 룸 내부)
	var offsets = [Vector2(-140, -60), Vector2(140, -60), Vector2(-120, 60), Vector2(120, 60)]
	var chosen_offset = offsets[randi() % offsets.size()]
	global_position = target_player.global_position + chosen_offset
	
	# 재등장 연출
	var appear_tween = create_tween()
	appear_tween.tween_property(visual, "modulate:a", 1.0, 0.25)
	appear_tween.parallel().tween_property(visual, "scale", Vector2.ONE, 0.25)
	await appear_tween.finished
	
	action_timer = 1.2
	current_state = State.IDLE

func _spawn_projectile(dir: Vector2) -> void:
	var proj = DarkProjectileScene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + dir * 18.0
	proj.setup(dir)

func take_damage(amount: int, knockback: Vector2, is_critical: bool = false) -> void:
	if current_state == State.DEAD:
		return
	
	current_hp -= amount
	emit_signal("health_changed", current_hp, max_hp)
	_spawn_damage_text(amount, is_critical)
	
	# 피격 시 살짝 넉백 및 플래시
	var tween = create_tween()
	visual.modulate = Color(2.5, 0.3, 0.3)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.12)
	
	if current_hp <= 0:
		_on_death()

func _spawn_damage_text(amount: int, is_critical: bool) -> void:
	var label = FloatingDamageScene.new()
	get_parent().add_child(label)
	label.global_position = global_position + Vector2(-10, -25)
	label.setup(amount, is_critical)

func _on_death() -> void:
	current_state = State.DEAD
	is_active = false
	hurtbox.set_deferred("monitoring", false)
	emit_signal("defeated")
	
	# 화려한 보스 격파 사망 연출
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color(3.0, 3.0, 3.0), 0.3)
	tween.parallel().tween_property(visual, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(visual, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.4)
	await tween.finished
	queue_free()
