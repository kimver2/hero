class_name BossCabalis
extends CharacterBody2D

signal health_changed(current: int, max_val: int)
signal boss_health_changed(current: int, max_val: int)
signal boss_defeated

const DarkProjectileScene = preload("res://scenes/effects/dark_projectile.tscn")

enum State { IDLE, CAST_COMETS, CLAW_SWIPE, VOID_NOVA, TELEPORT, DEAD }

@export var max_hp: int = 480
var current_hp: int = 480

var current_state: State = State.IDLE
var target_player: Node2D = null

var state_timer: float = 0.0
var is_phase_2: bool = false

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var hurtbox_area: Area2D = $Hurtbox
@onready var claw_hitbox: Area2D = $Visual/ClawHitbox

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	current_hp = max_hp
	emit_signal("boss_health_changed", current_hp, max_hp)
	
	claw_hitbox.monitoring = false
	claw_hitbox.area_entered.connect(_on_claw_hitbox_entered)
	
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
		
		State.CAST_COMETS, State.CLAW_SWIPE, State.VOID_NOVA:
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
	var dist = to_player.length()
	
	if current_hp <= max_hp * 0.5 and not is_phase_2:
		_enter_phase_2()
		return
	
	var r = randf()
	if is_phase_2:
		if r < 0.4:
			_cast_void_nova()
		elif r < 0.7:
			_cast_comets(6)
		else:
			_teleport()
	else:
		if dist < 80.0 and r < 0.6:
			_claw_swipe()
		elif r < 0.7:
			_cast_comets(4)
		else:
			_teleport()

func _enter_phase_2() -> void:
	is_phase_2 = true
	current_state = State.VOID_NOVA
	state_timer = 2.0
	
	AudioManager.play_sfx(AudioManager.sfx_roar, 0.9, 6.0)
	
	# 폭주 진동 연출
	var tween = create_tween().set_loops(6)
	tween.tween_property(visual, "position:x", 5.0, 0.04)
	tween.tween_property(visual, "position:x", -5.0, 0.04)
	visual.modulate = Color(3.5, 0.5, 2.5)
	
	await get_tree().create_timer(0.6).timeout
	visual.position.x = 0
	_cast_void_nova()

func _claw_swipe() -> void:
	current_state = State.CLAW_SWIPE
	state_timer = 1.1
	
	AudioManager.play_sfx(AudioManager.sfx_slash, 0.65, 3.0)
	var to_player = (target_player.global_position - global_position).normalized()
	_update_facing(to_player.x)
	
	var tween = create_tween()
	visual.modulate = Color(2.8, 0.5, 0.8)
	tween.tween_property(visual, "position:y", -10.0, 0.25)
	tween.tween_property(visual, "position:y", 0.0, 0.1)
	
	await tween.finished
	if current_state != State.CLAW_SWIPE or current_hp <= 0:
		return
	
	claw_hitbox.monitoring = true
	await get_tree().create_timer(0.25).timeout
	claw_hitbox.monitoring = false
	visual.modulate = Color(3.0, 0.5, 2.2) if is_phase_2 else Color(1, 1, 1)
	
	await get_tree().create_timer(0.4).timeout
	if current_state == State.CLAW_SWIPE:
		current_state = State.IDLE
		state_timer = 0.5

func _cast_comets(count: int) -> void:
	current_state = State.CAST_COMETS
	state_timer = 1.4
	
	AudioManager.play_sfx(AudioManager.sfx_skill, 1.2, 2.0)
	
	var tween = create_tween()
	visual.modulate = Color(2.5, 1.2, 3.0)
	tween.tween_property(visual, "position:y", -12.0, 0.35)
	tween.tween_property(visual, "position:y", 0.0, 0.15)
	
	await tween.finished
	if current_state != State.CAST_COMETS or current_hp <= 0:
		return
	
	visual.modulate = Color(3.0, 0.5, 2.2) if is_phase_2 else Color(1, 1, 1)
	
	var base_dir = (target_player.global_position - global_position).normalized()
	var base_angle = base_dir.angle()
	var spread = PI * 0.45
	
	for i in range(count):
		var offset = -spread / 2.0 + (spread / float(count - 1 if count > 1 else 1)) * float(i)
		var angle = base_angle + offset
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_comet(dir, 155.0, 18)
	
	await get_tree().create_timer(0.5).timeout
	if current_state == State.CAST_COMETS:
		current_state = State.IDLE
		state_timer = 0.6 if is_phase_2 else 0.9

func _cast_void_nova() -> void:
	current_state = State.VOID_NOVA
	state_timer = 1.8
	
	AudioManager.play_sfx(AudioManager.sfx_roar, 1.2, 4.0)
	
	# 16방향 공허의 초신성 폭발
	var count = 16
	var angle_step = TAU / float(count)
	for i in range(count):
		var angle = i * angle_step
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_comet(dir, 160.0, 20)
	
	await get_tree().create_timer(0.7).timeout
	if current_state == State.VOID_NOVA:
		current_state = State.IDLE
		state_timer = 0.6

func _teleport() -> void:
	current_state = State.TELEPORT
	state_timer = 0.8
	
	AudioManager.play_sfx(AudioManager.sfx_skill, 1.8, -3.0)
	var tween = create_tween()
	tween.tween_property(visual, "modulate:a", 0.0, 0.25)
	
	await tween.finished
	if current_hp <= 0:
		return
	
	var angle = randf() * TAU
	var dist = randf_range(110.0, 210.0)
	global_position = target_player.global_position + Vector2(cos(angle), sin(angle)) * dist
	global_position.x = clampf(global_position.x, -260.0, 260.0)
	global_position.y = clampf(global_position.y, -180.0, 180.0)
	
	var in_tween = create_tween()
	in_tween.tween_property(visual, "modulate:a", 1.0, 0.2)
	await in_tween.finished
	
	current_state = State.IDLE
	state_timer = 0.4

func _spawn_comet(dir: Vector2, speed: float, dmg: int) -> void:
	var proj = DarkProjectileScene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + dir * 20.0
	proj.setup(dir, speed, dmg)

func _on_claw_hitbox_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var p = area.get_parent()
		if p and p.has_method("take_damage"):
			var push_dir = (p.global_position - global_position).normalized()
			p.take_damage(22, push_dir * 250.0)

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO, is_heavy: bool = false) -> void:
	if current_hp <= 0:
		return
	
	# 레온의 성광섬멸참(Skill 3) 및 파천검 등 중타격은 마신의 암흑을 뚫고 1.5배 피해
	var final_dmg = amount
	if is_heavy:
		final_dmg = int(amount * 1.5)
	
	current_hp = max(0, current_hp - final_dmg)
	emit_signal("boss_health_changed", current_hp, max_hp)
	
	# 플로팅 데미지 숫자
	var dmg_lbl = FloatingDamage.new()
	get_parent().add_child(dmg_lbl)
	dmg_lbl.global_position = global_position + Vector2(randf_range(-15, 15), -30)
	dmg_lbl.setup(final_dmg, is_heavy)
	
	# 피격 깜빡임
	var tween = create_tween()
	visual.modulate = Color(3.5, 0.2, 0.2)
	var reset_color = Color(3.0, 0.5, 2.2) if is_phase_2 else Color(1, 1, 1)
	tween.tween_property(visual, "modulate", reset_color, 0.15)
	
	if knockback != Vector2.ZERO:
		velocity = knockback * 0.15
		move_and_slide()
	
	if current_hp <= 0:
		_die()

func _die() -> void:
	current_state = State.DEAD
	AudioManager.play_sfx(AudioManager.sfx_roar, 0.5, 8.0)
	
	# 차원의 빛으로 정화되는 연출
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color(2.0, 3.0, 3.5), 1.0)
	tween.tween_property(visual, "modulate:a", 0.0, 1.8)
	
	await tween.finished
	emit_signal("boss_defeated")
	queue_free()
