class_name BossMalakar
extends CharacterBody2D

signal health_changed(current: int, max_val: int)
signal boss_health_changed(current: int, max_val: int)
signal boss_defeated

const DarkProjectileScene = preload("res://scenes/effects/dark_projectile.tscn")

enum State { IDLE, CAST_ORBS, CAST_PILLARS, TELEPORT, PHASE2_BURST, DEAD }

@export var max_hp: int = 360
var current_hp: int = 360

var current_state: State = State.IDLE
var target_player: Node2D = null

var state_timer: float = 0.0
var is_phase_2: bool = false

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var hurtbox_area: Area2D = $Hurtbox

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	current_hp = max_hp
	emit_signal("boss_health_changed", current_hp, max_hp)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]
	
	state_timer = 1.0

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	if not target_player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]
		return
	
	state_timer -= delta
	
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			if state_timer <= 0.0:
				_decide_next_action()
		
		State.CAST_ORBS, State.CAST_PILLARS, State.PHASE2_BURST:
			velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
			move_and_slide()

func _update_facing(x_dir: float) -> void:
	if x_dir < -5.0:
		visual.scale.x = -1.0
	elif x_dir > 5.0:
		visual.scale.x = 1.0

func _decide_next_action() -> void:
	var to_player = target_player.global_position - global_position
	_update_facing(to_player.x)
	
	if current_hp <= max_hp * 0.5 and not is_phase_2:
		_enter_phase_2()
		return
	
	var r = randf()
	if is_phase_2:
		if r < 0.4:
			_cast_phase2_burst()
		elif r < 0.7:
			_cast_void_orbs(5)
		else:
			_teleport()
	else:
		if r < 0.5:
			_cast_void_orbs(3)
		elif r < 0.8:
			_cast_shadow_pillar()
		else:
			_teleport()

func _enter_phase_2() -> void:
	is_phase_2 = true
	current_state = State.PHASE2_BURST
	state_timer = 2.0
	
	AudioManager.play_sfx(AudioManager.sfx_roar, 1.2, 5.0)
	
	# 폭주 연출
	var tween = create_tween().set_loops(6)
	tween.tween_property(visual, "position:x", 4.0, 0.04)
	tween.tween_property(visual, "position:x", -4.0, 0.04)
	visual.modulate = Color(3.0, 0.5, 2.0)
	
	await get_tree().create_timer(0.6).timeout
	visual.position.x = 0
	_cast_phase2_burst()

func _cast_void_orbs(count: int) -> void:
	current_state = State.CAST_ORBS
	state_timer = 1.2
	
	AudioManager.play_sfx(AudioManager.sfx_skill, 1.4, 0.0)
	
	var tween = create_tween()
	visual.modulate = Color(2.5, 1.0, 2.5)
	tween.tween_property(visual, "position:y", -8.0, 0.3)
	tween.tween_property(visual, "position:y", 0.0, 0.1)
	
	await tween.finished
	if current_state != State.CAST_ORBS or current_hp <= 0:
		return
	
	visual.modulate = Color(2.5, 0.6, 1.8) if is_phase_2 else Color(1, 1, 1)
	
	var base_dir = (target_player.global_position - global_position).normalized()
	var base_angle = base_dir.angle()
	var spread = PI * 0.35
	
	for i in range(count):
		var offset = -spread / 2.0 + (spread / float(count - 1 if count > 1 else 1)) * float(i)
		var angle = base_angle + offset
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_projectile(dir, 140.0, 15)
	
	await get_tree().create_timer(0.5).timeout
	if current_state == State.CAST_ORBS:
		current_state = State.IDLE
		state_timer = 0.6 if is_phase_2 else 0.9

func _cast_shadow_pillar() -> void:
	current_state = State.CAST_PILLARS
	state_timer = 1.3
	
	AudioManager.play_sfx(AudioManager.sfx_skill, 0.9, 2.0)
	
	# 플레이어 위치 예측 장판
	var target_pos = target_player.global_position
	
	# 마법진 표시
	var circle = Polygon2D.new()
	circle.color = Color(1.0, 0.1, 0.3, 0.4)
	circle.polygon = PackedVector2Array([
		Vector2(-28, 0), Vector2(-20, -20), Vector2(0, -28), Vector2(20, -20),
		Vector2(28, 0), Vector2(20, 20), Vector2(0, 28), Vector2(-20, 20)
	])
	circle.global_position = target_pos
	get_parent().add_child(circle)
	
	var tween = create_tween()
	tween.tween_property(circle, "color:a", 0.8, 0.7)
	
	await tween.finished
	if not is_instance_valid(circle):
		return
	
	# 폭발 시 데미지 판정
	AudioManager.play_sfx(AudioManager.sfx_skill, 1.1, 4.0)
	var blast_poly = Polygon2D.new()
	blast_poly.color = Color(2.5, 0.2, 0.5, 0.9)
	blast_poly.polygon = circle.polygon
	blast_poly.global_position = target_pos
	get_parent().add_child(blast_poly)
	circle.queue_free()
	
	var blast_tween = create_tween()
	blast_tween.tween_property(blast_poly, "scale", Vector2(1.3, 1.3), 0.2)
	blast_tween.parallel().tween_property(blast_poly, "modulate:a", 0.0, 0.3)
	blast_tween.tween_callback(blast_poly.queue_free)
	
	# 거리 체크로 데미지 적용
	if target_player and is_instance_valid(target_player):
		if target_player.global_position.distance_to(target_pos) < 32.0:
			if target_player.has_method("take_damage"):
				target_player.take_damage(25, (target_player.global_position - target_pos).normalized() * 200.0)
	
	await get_tree().create_timer(0.4).timeout
	if current_state == State.CAST_PILLARS:
		current_state = State.IDLE
		state_timer = 0.8

func _cast_phase2_burst() -> void:
	current_state = State.PHASE2_BURST
	state_timer = 1.6
	
	AudioManager.play_sfx(AudioManager.sfx_roar, 1.4, 3.0)
	
	# 12방향 탄막 폭발
	var count = 12
	var angle_step = TAU / float(count)
	for i in range(count):
		var angle = i * angle_step
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_projectile(dir, 160.0, 18)
	
	await get_tree().create_timer(0.6).timeout
	if current_state == State.PHASE2_BURST:
		current_state = State.IDLE
		state_timer = 0.5

func _teleport() -> void:
	current_state = State.TELEPORT
	state_timer = 0.8
	
	AudioManager.play_sfx(AudioManager.sfx_slash, 0.5, -2.0)
	
	var tween = create_tween()
	tween.tween_property(visual, "modulate:a", 0.0, 0.25)
	
	await tween.finished
	if current_hp <= 0:
		return
	
	# 이동할 새로운 위치 결정
	var angle = randf() * TAU
	var dist = randf_range(110.0, 200.0)
	global_position = target_player.global_position + Vector2(cos(angle), sin(angle)) * dist
	# 경기장 범위 클램프
	global_position.x = clampf(global_position.x, -260.0, 260.0)
	global_position.y = clampf(global_position.y, -180.0, 180.0)
	
	var in_tween = create_tween()
	in_tween.tween_property(visual, "modulate:a", 1.0, 0.2)
	await in_tween.finished
	
	current_state = State.IDLE
	state_timer = 0.4

func _spawn_projectile(dir: Vector2, speed: float, dmg: int) -> void:
	var proj = DarkProjectileScene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + dir * 18.0
	proj.setup(dir, speed, dmg)

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO, is_heavy: bool = false) -> void:
	if current_hp <= 0:
		return
	
	var final_dmg = amount
	if is_heavy:
		final_dmg = int(amount * 1.35)
	
	current_hp = max(0, current_hp - final_dmg)
	emit_signal("boss_health_changed", current_hp, max_hp)
	
	# 플로팅 데미지 숫자
	var dmg_lbl = FloatingDamage.new()
	get_parent().add_child(dmg_lbl)
	dmg_lbl.global_position = global_position + Vector2(randf_range(-15, 15), -25)
	dmg_lbl.setup(final_dmg, is_heavy)
	
	# 피격 깜빡임
	var tween = create_tween()
	visual.modulate = Color(3.0, 0.2, 0.2)
	var reset_color = Color(2.5, 0.6, 1.8) if is_phase_2 else Color(1, 1, 1)
	tween.tween_property(visual, "modulate", reset_color, 0.15)
	
	if knockback != Vector2.ZERO:
		velocity = knockback * 0.2
		move_and_slide()
	
	if current_hp <= 0:
		_die()

func _die() -> void:
	current_state = State.DEAD
	AudioManager.play_sfx(AudioManager.sfx_roar, 0.5, 6.0)
	
	# 소멸 연출
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color(3.0, 0.1, 0.1), 0.5)
	tween.tween_property(visual, "modulate:a", 0.0, 1.5)
	
	await tween.finished
	emit_signal("boss_defeated")
	queue_free()
