class_name BossGuardian
extends CharacterBody2D

signal boss_health_changed(current: int, max_val: int)
signal boss_defeated

enum State { IDLE, CHASE, ATTACK_SWIPE, ROAR, CHARGE, STUNNED, HURT, DEAD }

@export var max_hp: int = 260
var current_hp: int = 260

@export var move_speed: float = 75.0
@export var charge_speed: float = 240.0

var current_state: State = State.IDLE
var target_player: Node2D = null

var state_timer: float = 0.0
var attack_cooldown: float = 1.8
var next_action_cooldown: float = 2.0

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var hurtbox_area: Area2D = $Hurtbox
@onready var melee_hitbox: Area2D = $Visual/MeleeHitbox

var charge_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	current_hp = max_hp
	emit_signal("boss_health_changed", current_hp, max_hp)
	
	melee_hitbox.monitoring = false
	melee_hitbox.area_entered.connect(_on_melee_hitbox_entered)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]

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
		
		State.CHASE:
			var to_player = target_player.global_position - global_position
			var dist = to_player.length()
			
			if dist < 65.0:
				_start_swipe_attack()
			elif state_timer <= 0.0:
				_decide_next_action()
			else:
				velocity = to_player.normalized() * move_speed
				_update_facing(velocity.x)
				move_and_slide()
		
		State.CHARGE:
			velocity = charge_dir * charge_speed
			var collision = move_and_slide()
			if collision or state_timer <= 0.0:
				_end_charge()
		
		State.STUNNED:
			velocity = Vector2.ZERO
			if state_timer <= 0.0:
				current_state = State.IDLE
				state_timer = 0.8
		
		State.ATTACK_SWIPE, State.ROAR, State.HURT:
			velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
			move_and_slide()

func _update_facing(x_dir: float) -> void:
	if x_dir < -5.0:
		visual.scale.x = -1.0
	elif x_dir > 5.0:
		visual.scale.x = 1.0

func _decide_next_action() -> void:
	var to_player = target_player.global_position - global_position
	var dist = to_player.length()
	
	var rand_val = randf()
	if dist > 140.0:
		if rand_val < 0.65:
			_start_charge_attack(to_player.normalized())
		else:
			_start_roar_attack()
	elif dist < 60.0:
		if rand_val < 0.6:
			_start_swipe_attack()
		else:
			_start_roar_attack()
	else:
		current_state = State.CHASE
		state_timer = randf_range(1.5, 3.0)

func _start_swipe_attack() -> void:
	current_state = State.ATTACK_SWIPE
	state_timer = 1.0
	
	# 전방 준비 모션
	var tween = create_tween()
	var to_player = (target_player.global_position - global_position).normalized()
	_update_facing(to_player.x)
	
	visual.modulate = Color(2.0, 0.6, 0.6)
	tween.tween_property(visual, "position:y", -6.0, 0.25)
	
	await tween.finished
	if current_state != State.ATTACK_SWIPE or current_hp <= 0:
		return
	
	# 내려치기
	AudioManager.play_sfx(AudioManager.sfx_slash, 0.75, 2.0)
	melee_hitbox.monitoring = true
	var hit_tween = create_tween()
	hit_tween.tween_property(visual, "position:y", 0.0, 0.1)
	hit_tween.parallel().tween_property(visual, "modulate", Color(1, 1, 1), 0.2)
	
	await get_tree().create_timer(0.2).timeout
	melee_hitbox.monitoring = false
	
	await get_tree().create_timer(0.4).timeout
	if current_state == State.ATTACK_SWIPE:
		current_state = State.IDLE
		state_timer = 0.6

func _start_roar_attack() -> void:
	current_state = State.ROAR
	state_timer = 1.5
	
	AudioManager.play_sfx(AudioManager.sfx_roar, 1.0, 4.0)
	
	# 표효 진동 연출
	var tween = create_tween().set_loops(4)
	tween.tween_property(visual, "position:x", 3.0, 0.05)
	tween.tween_property(visual, "position:x", -3.0, 0.05)
	visual.modulate = Color(2.5, 0.5, 0.8)
	
	await get_tree().create_timer(0.45).timeout
	visual.position.x = 0.0
	visual.modulate = Color(1, 1, 1)
	
	# 8방향 충격파 투사체 발사
	_fire_shockwave_burst()
	
	await get_tree().create_timer(0.5).timeout
	if current_state == State.ROAR:
		current_state = State.IDLE
		state_timer = 0.7

func _fire_shockwave_burst() -> void:
	AudioManager.play_sfx(AudioManager.sfx_skill, 1.2, 0.0)
	var count = 8
	var angle_step = TAU / float(count)
	for i in range(count):
		var angle = i * angle_step
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_shockwave(dir)

func _spawn_shockwave(dir: Vector2) -> void:
	var proj = Area2D.new()
	proj.collision_layer = 0
	proj.collision_mask = 2 # player layer
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 7.0
	col.shape = shape
	proj.add_child(col)
	
	var poly = Polygon2D.new()
	poly.color = Color(1.0, 0.2, 0.4, 0.9)
	poly.polygon = PackedVector2Array([
		Vector2(-6, -6), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)
	])
	proj.add_child(poly)
	
	proj.global_position = global_position
	get_parent().add_child(proj)
	
	proj.body_entered.connect(func(body):
		if body is CharacterBody2D and body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(16, dir * 180.0)
			if is_instance_valid(proj):
				proj.queue_free()
	)
	
	var speed = 150.0
	var timer = 1.4
	var t = 0.0
	while t < timer and is_instance_valid(proj):
		var dt = await get_tree().process_frame
		t += dt
		if is_instance_valid(proj):
			proj.global_position += dir * speed * dt
	
	if is_instance_valid(proj):
		proj.queue_free()

func _start_charge_attack(dir: Vector2) -> void:
	current_state = State.CHARGE
	charge_dir = dir
	state_timer = 1.2
	
	AudioManager.play_sfx(AudioManager.sfx_roar, 1.3, 1.0)
	_update_facing(dir.x)
	visual.modulate = Color(2.5, 1.5, 0.5)
	melee_hitbox.monitoring = true

func _end_charge() -> void:
	melee_hitbox.monitoring = false
	visual.modulate = Color(1, 1, 1)
	current_state = State.STUNNED
	state_timer = 1.0
	AudioManager.play_sfx(AudioManager.sfx_hit, 0.7, 3.0)

func _on_melee_hitbox_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var p = area.get_parent()
		if p and p.has_method("take_damage"):
			var dmg = 24 if current_state == State.CHARGE else 16
			var push_dir = charge_dir if current_state == State.CHARGE else (p.global_position - global_position).normalized()
			p.take_damage(dmg, push_dir * 220.0)

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO, is_heavy: bool = false) -> void:
	if current_hp <= 0:
		return
	
	# 파천검 등 묵직한 중타격은 수호수의 단단한 껍질을 뚫고 1.5배 피해
	var final_dmg = amount
	if is_heavy:
		final_dmg = int(amount * 1.5)
	
	current_hp = max(0, current_hp - final_dmg)
	emit_signal("boss_health_changed", current_hp, max_hp)
	
	# Floating damage number
	_spawn_damage_number(final_dmg, is_heavy)
	
	# 피격 깜빡임
	var tween = create_tween()
	visual.modulate = Color(3.0, 0.3, 0.3)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.15)
	
	# 보스는 쉽게 밀리지 않음 (슈퍼아머: 중타격 시에만 소량 넉백)
	if is_heavy and knockback != Vector2.ZERO:
		velocity = knockback * 0.25
		move_and_slide()
	
	if current_hp <= 0:
		_die()

func _spawn_damage_number(dmg: int, is_crit: bool) -> void:
	var dmg_lbl = FloatingDamage.new()
	get_parent().add_child(dmg_lbl)
	dmg_lbl.global_position = global_position + Vector2(randf_range(-15, 15), -25)
	dmg_lbl.setup(dmg, is_crit)

func _die() -> void:
	current_state = State.DEAD
	melee_hitbox.monitoring = false
	AudioManager.play_sfx(AudioManager.sfx_roar, 0.6, 5.0)
	
	# 정화되는 연출: 어두운 보라색에서 성스러운 에메랄드/금빛으로 변화
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color(1.5, 2.5, 1.8), 0.8)
	tween.tween_property(visual, "modulate:a", 0.0, 1.2)
	
	await tween.finished
	emit_signal("boss_defeated")
	queue_free()
