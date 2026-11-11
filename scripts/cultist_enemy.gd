class_name CultistEnemy
extends CharacterBody2D

signal defeated

enum State { IDLE, CHASE, ATTACK, DEAD }

@export var max_hp: int = 50
@export var move_speed: float = 75.0
@export var detection_range: float = 200.0
@export var attack_range: float = 34.0
@export var attack_cooldown: float = 1.4

var current_hp: int = 50
var current_state: State = State.IDLE
var target_player: Node2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
var attack_cooldown_timer: float = 0.0
var is_attacking: bool = false

@onready var visual: Node2D = $Visual
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var hitbox: Area2D = $WeaponPivot/Hitbox
@onready var hurtbox: Area2D = $Hurtbox

const FloatingDamageScene = preload("res://scripts/floating_damage.gd")

func _ready() -> void:
	current_hp = max_hp
	hurtbox.add_to_group("hurtbox")
	hitbox.monitoring = false
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	
	# 플레이어 노드 탐색
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		target_player = players[0]

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta
	
	# 넉백 처리
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			target_player = players[0]
		return
	
	var dist_to_player = global_position.distance_to(target_player.global_position)
	var dir_to_player = (target_player.global_position - global_position).normalized()
	
	# 좌우 반전
	if dir_to_player.x < 0:
		visual.scale.x = -1.0
	elif dir_to_player.x > 0:
		visual.scale.x = 1.0
	
	weapon_pivot.rotation = dir_to_player.angle()
	
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			if dist_to_player <= detection_range:
				current_state = State.CHASE
		
		State.CHASE:
			if dist_to_player <= attack_range and attack_cooldown_timer <= 0.0:
				_perform_attack(dir_to_player)
			elif dist_to_player <= detection_range:
				velocity = dir_to_player * move_speed
				move_and_slide()
			else:
				current_state = State.IDLE
		
		State.ATTACK:
			# 공격 중에는 정지
			velocity = Vector2.ZERO

func _perform_attack(dir: Vector2) -> void:
	is_attacking = true
	current_state = State.ATTACK
	attack_cooldown_timer = attack_cooldown
	
	# 1. 공격 준비 경고 (빨간색 예고 플래시)
	var tween = create_tween()
	visual.modulate = Color(2.5, 0.5, 0.5)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.35)
	
	await get_tree().create_timer(0.35).timeout
	if current_state == State.DEAD:
		return
	
	# 2. 공격 실행 (단검 휘두르기)
	var blade_trail = $WeaponPivot/BladeTrail
	blade_trail.visible = true
	blade_trail.modulate = Color(1.0, 0.2, 0.2, 1.0)
	hitbox.monitoring = true
	
	# 공격 시 살짝 전방 돌진
	velocity = dir * 100.0
	move_and_slide()
	
	var slash_tween = create_tween()
	slash_tween.tween_property(blade_trail, "rotation_degrees", 60.0, 0.18)
	slash_tween.parallel().tween_property(blade_trail, "modulate:a", 0.0, 0.2)
	
	await get_tree().create_timer(0.18).timeout
	hitbox.monitoring = false
	
	await get_tree().create_timer(0.12).timeout
	blade_trail.visible = false
	blade_trail.rotation_degrees = -60.0
	is_attacking = false
	current_state = State.CHASE

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player = area.get_parent()
		if player and player.has_method("take_damage"):
			var knock_dir = (player.global_position - global_position).normalized()
			player.take_damage(14, knock_dir * 180.0)

func take_damage(amount: int, knockback: Vector2, is_critical: bool = false) -> void:
	if current_state == State.DEAD:
		return
	
	current_hp -= amount
	knockback_velocity = knockback
	_spawn_damage_text(amount, is_critical)
	
	# 피격 플래시
	var tween = create_tween()
	visual.modulate = Color(2.0, 0.2, 0.2)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.12)
	
	if current_hp <= 0:
		_on_death()

func _spawn_damage_text(amount: int, is_critical: bool) -> void:
	var label = FloatingDamageScene.new()
	get_parent().add_child(label)
	label.global_position = global_position + Vector2(-10, -20)
	label.setup(amount, is_critical)

func _on_death() -> void:
	current_state = State.DEAD
	hurtbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitoring", false)
	
	emit_signal("defeated")
	
	# 사망 연출 (회전하며 소멸)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(visual, "scale", Vector2.ZERO, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(visual, "modulate:a", 0.0, 0.35)
	await tween.finished
	queue_free()
