class_name CultistKnight
extends CharacterBody2D

signal defeated

enum State { IDLE, CHASE, SHIELD_CHARGE, ATTACK, DEAD }

@export var max_hp: int = 75
@export var move_speed: float = 65.0
@export var charge_speed: float = 220.0

var current_hp: int = 75
var current_state: State = State.IDLE
var target_player: Node2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
var attack_cooldown: float = 1.6
var attack_timer: float = 0.0

@onready var visual: Node2D = $Visual
@onready var hitbox: Area2D = $Visual/Hitbox
@onready var hurtbox: Area2D = $Hurtbox

const FloatingDamageScene = preload("res://scripts/floating_damage.gd")

func _ready() -> void:
	current_hp = max_hp
	hurtbox.add_to_group("hurtbox")
	hitbox.monitoring = false
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		target_player = players[0]

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	if attack_timer > 0.0:
		attack_timer -= delta
	
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)
		move_and_slide()
		return
	
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			target_player = players[0]
		return
	
	var dist = global_position.distance_to(target_player.global_position)
	var dir = (target_player.global_position - global_position).normalized()
	
	if dir.x < 0:
		visual.scale.x = -1.0
	elif dir.x > 0:
		visual.scale.x = 1.0
	
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			if dist <= 220.0:
				current_state = State.CHASE
		
		State.CHASE:
			if dist <= 120.0 and dist > 40.0 and attack_timer <= 0.0:
				_perform_shield_charge(dir)
			elif dist <= 38.0 and attack_timer <= 0.0:
				_perform_slash(dir)
			elif dist <= 220.0:
				velocity = dir * move_speed
				move_and_slide()
			else:
				current_state = State.IDLE

func _perform_shield_charge(dir: Vector2) -> void:
	current_state = State.SHIELD_CHARGE
	attack_timer = attack_cooldown
	
	# 돌진 준비 경고 (방패가 황금빛으로 번쩍임)
	var tween = create_tween()
	visual.modulate = Color(2.0, 1.8, 0.4)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.3)
	
	await get_tree().create_timer(0.3).timeout
	if current_state == State.DEAD:
		return
	
	hitbox.monitoring = true
	velocity = dir * charge_speed
	
	for i in range(12):
		if current_state == State.DEAD:
			break
		move_and_slide()
		await get_tree().create_timer(0.02).timeout
	
	hitbox.monitoring = false
	current_state = State.CHASE

func _perform_slash(dir: Vector2) -> void:
	current_state = State.ATTACK
	attack_timer = attack_cooldown
	
	hitbox.monitoring = true
	velocity = dir * 80.0
	move_and_slide()
	
	await get_tree().create_timer(0.2).timeout
	hitbox.monitoring = false
	current_state = State.CHASE

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player = area.get_parent()
		if player and player.has_method("take_damage"):
			var knock_dir = (player.global_position - global_position).normalized()
			player.take_damage(18, knock_dir * 200.0)

func take_damage(amount: int, knockback: Vector2, is_critical: bool = false) -> void:
	if current_state == State.DEAD:
		return
	
	# 방패 돌진 중에는 데미지 40% 감소
	if current_state == State.SHIELD_CHARGE:
		amount = int(amount * 0.6)
	
	current_hp -= amount
	knockback_velocity = knockback * 0.7 # 묵직해서 넉백 덜 받음
	_spawn_damage_text(amount, is_critical)
	
	var tween = create_tween()
	visual.modulate = Color(2.5, 0.3, 0.3)
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
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(visual, "scale", Vector2.ZERO, 0.35)
	tween.tween_property(visual, "modulate:a", 0.0, 0.35)
	await tween.finished
	queue_free()
