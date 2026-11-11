class_name Player
extends CharacterBody2D

signal health_changed(current: int, max_val: int)
signal mana_changed(current: int, max_val: int)
signal potion_changed(count: int)

enum State { IDLE, MOVE, ATTACK, DASH }

@export var move_speed: float = 140.0
@export var dash_speed: float = 300.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.7

@export var max_hp: int = 100
@export var max_sp: int = 50
@export var potion_count: int = 3

var current_hp: int = 100
var current_sp: int = 50

var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN

# 콤보 공격 관련 변수
var combo_step: int = 0
var combo_timer: float = 0.0
const COMBO_WINDOW: float = 0.55
var is_attack_in_progress: bool = false

# 대시 관련 변수
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.DOWN

@onready var visual_root: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var hitbox_area: Area2D = $WeaponPivot/HitboxArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("player")
	if has_node("Hurtbox"):
		$Hurtbox.add_to_group("player_hurtbox")
	current_hp = max_hp
	current_sp = max_sp
	hitbox_area.monitoring = false
	hitbox_area.area_entered.connect(_on_hitbox_area_entered)
	emit_signal("health_changed", current_hp, max_hp)
	emit_signal("mana_changed", current_sp, max_sp)
	emit_signal("potion_changed", potion_count)

# 피격 및 무적 관련
var is_invincible: bool = false
var invincibility_timer: float = 0.0
const INVINCIBILITY_DURATION: float = 0.6

func _process(delta: float) -> void:
	if invincibility_timer > 0.0:
		invincibility_timer -= delta
		if invincibility_timer <= 0.0:
			is_invincible = false
			visual_root.modulate.a = 1.0

	# 대시 쿨타임 감소
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	# 콤보 윈도우 감소
	if combo_step > 0 and not is_attack_in_progress:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_step = 0

var is_control_active: bool = true

func set_control_active(active: bool) -> void:
	is_control_active = active
	if not active:
		velocity = Vector2.ZERO
		current_state = State.IDLE

func _physics_process(delta: float) -> void:
	if not is_control_active:
		return

	match current_state:
		State.IDLE, State.MOVE:
			_handle_movement(delta)
			_handle_action_inputs()
		State.ATTACK:
			# 공격 중에는 이동 제한 또는 약간의 전진
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			move_and_slide()
		State.DASH:
			_process_dash(delta)

func _handle_movement(_delta: float) -> void:
	# 원형 데드존의 버그를 방지하기 위해 각 축의 입력을 직접 계산
	var raw_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var raw_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var input_vector = Vector2(raw_x, raw_y)
	
	if input_vector.length() > 0.15:
		velocity = input_vector.normalized() * move_speed
		facing_direction = input_vector.normalized()
		_update_facing(facing_direction)
		current_state = State.MOVE
	else:
		velocity = Vector2.ZERO
		current_state = State.IDLE
	
	move_and_slide()

func _update_facing(dir: Vector2) -> void:
	# 무기 피벗 각도 업데이트
	weapon_pivot.rotation = dir.angle()
	# 좌우 반전
	if dir.x < 0:
		visual_root.scale.x = -1.0
	elif dir.x > 0:
		visual_root.scale.x = 1.0

func _handle_action_inputs() -> void:
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
		_start_dash()
	elif Input.is_action_just_pressed("attack"):
		_perform_attack()
	elif Input.is_action_just_pressed("skill_1") and current_sp >= 15:
		_perform_skill_1()
	elif Input.is_action_just_pressed("skill_2") and current_sp >= 25:
		_perform_skill_2()
	elif Input.is_action_just_pressed("use_potion"):
		use_health_potion()

func use_health_potion() -> void:
	if potion_count > 0 and current_hp < max_hp:
		potion_count -= 1
		current_hp = min(max_hp, current_hp + 45)
		emit_signal("health_changed", current_hp, max_hp)
		emit_signal("potion_changed", potion_count)
		AudioManager.play_sfx(AudioManager.sfx_potion)
		# 녹색 치유 플래시
		var tween = create_tween()
		visual_root.modulate = Color(0.4, 2.0, 0.4)
		tween.tween_property(visual_root, "modulate", Color(1, 1, 1), 0.3)

func _perform_skill_2() -> void:
	# 파천검 (카라드 전수 오의: 강력한 지진 강타 광역기)
	current_sp -= 25
	emit_signal("mana_changed", current_sp, max_sp)
	AudioManager.play_sfx(AudioManager.sfx_skill)
	
	current_state = State.ATTACK
	is_attack_in_progress = true
	
	hitbox_area.set_meta("damage", 55)
	hitbox_area.set_meta("knockback_dir", facing_direction)
	hitbox_area.set_meta("knockback_force", 300.0)
	hitbox_area.set_meta("is_heavy", true)
	hitbox_area.monitoring = true
	
	# 도약 후 지면 강타
	var tween = create_tween()
	tween.tween_property(visual_root, "position:y", -14.0, 0.15)
	tween.tween_property(visual_root, "position:y", 0.0, 0.1)
	
	await tween.finished
	# 화면 흔들림 효과 또는 번쩍임
	visual_root.modulate = Color(2.5, 1.8, 0.5)
	var flash_tween = create_tween()
	flash_tween.tween_property(visual_root, "modulate", Color(1, 1, 1), 0.2)
	
	await get_tree().create_timer(0.2).timeout
	hitbox_area.monitoring = false
	is_attack_in_progress = false
	current_state = State.IDLE

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_invincible or current_state == State.DASH or current_hp <= 0:
		return
	
	current_hp = max(0, current_hp - amount)
	emit_signal("health_changed", current_hp, max_hp)
	
	# 피격 무적 및 깜빡임
	is_invincible = true
	invincibility_timer = INVINCIBILITY_DURATION
	
	# 넉백 적용
	if knockback != Vector2.ZERO:
		velocity = knockback
		move_and_slide()
	
	AudioManager.play_sfx(AudioManager.sfx_hit, 0.75)
	
	# 피격 시각 효과 (붉은 깜빡임)
	var tween = create_tween()
	visual_root.modulate = Color(2.0, 0.4, 0.4)
	tween.tween_property(visual_root, "modulate", Color(1, 1, 1, 0.5), 0.15)
	
	if current_hp <= 0:
		_on_player_death()

func _on_player_death() -> void:
	set_control_active(false)
	var tween = create_tween()
	tween.tween_property(visual_root, "modulate:a", 0.0, 0.8)
	await tween.finished
	# 리스폰 처리 (HP 회복 후 부활)
	await get_tree().create_timer(1.0).timeout
	current_hp = max_hp
	emit_signal("health_changed", current_hp, max_hp)
	visual_root.modulate = Color(1, 1, 1, 1)
	set_control_active(true)

func _start_dash() -> void:
	current_state = State.DASH
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector != Vector2.ZERO:
		dash_direction = input_vector.normalized()
	else:
		dash_direction = facing_direction
	
	# 대시 중 잔상 또는 무적 시각 효과
	var tween = create_tween()
	tween.tween_property(visual_root, "modulate:a", 0.4, 0.05)

func _process_dash(delta: float) -> void:
	velocity = dash_direction * dash_speed
	move_and_slide()
	
	dash_timer -= delta
	if dash_timer <= 0.0:
		visual_root.modulate.a = 1.0
		current_state = State.IDLE

func _perform_attack() -> void:
	if is_attack_in_progress:
		return
	
	is_attack_in_progress = true
	current_state = State.ATTACK
	
	combo_step = (combo_step % 3) + 1
	combo_timer = COMBO_WINDOW
	
	var damage = 10
	var knockback_force = 120.0
	var attack_anim_time = 0.22
	
	match combo_step:
		1:
			damage = 10
			knockback_force = 100.0
			attack_anim_time = 0.2
		2:
			damage = 15
			knockback_force = 140.0
			attack_anim_time = 0.22
		3:
			damage = 28
			knockback_force = 240.0
			attack_anim_time = 0.35 # 마지막 3타는 강력한 묵직함
	
	# 공격 시 살짝 전방으로 스텝
	velocity = facing_direction * 70.0
	AudioManager.play_sfx(AudioManager.sfx_slash, 0.9 + combo_step * 0.15)
	
	# 히트박스 데미지/넉백 정보 갱신 및 활성화
	hitbox_area.set_meta("damage", damage)
	hitbox_area.set_meta("knockback_dir", facing_direction)
	hitbox_area.set_meta("knockback_force", knockback_force)
	hitbox_area.set_meta("is_heavy", combo_step == 3)
	
	hitbox_area.monitoring = true
	
	# 공격 애니메이션 트윈 (검 궤적 시각 효과)
	var sword_trail = $WeaponPivot/SwordTrail
	sword_trail.visible = true
	sword_trail.modulate = Color(1, 1, 1, 1)
	
	var tween = create_tween()
	tween.tween_property(sword_trail, "rotation_degrees", 70.0 if combo_step % 2 == 1 else -70.0, attack_anim_time * 0.7)
	tween.parallel().tween_property(sword_trail, "modulate:a", 0.0, attack_anim_time)
	
	await get_tree().create_timer(attack_anim_time * 0.6).timeout
	hitbox_area.monitoring = false
	
	await get_tree().create_timer(attack_anim_time * 0.4).timeout
	sword_trail.visible = false
	sword_trail.rotation_degrees = -70.0 if combo_step % 2 == 1 else 70.0
	is_attack_in_progress = false
	current_state = State.IDLE

func _perform_skill_1() -> void:
	# 질풍참 (SP 소모 돌진 광역기)
	current_sp -= 15
	emit_signal("mana_changed", current_sp, max_sp)
	
	current_state = State.ATTACK
	is_attack_in_progress = true
	
	hitbox_area.set_meta("damage", 40)
	hitbox_area.set_meta("knockback_dir", facing_direction)
	hitbox_area.set_meta("knockback_force", 200.0)
	hitbox_area.set_meta("is_heavy", true)
	hitbox_area.monitoring = true
	
	# 전방으로 빠르게 관통 돌진
	velocity = facing_direction * 350.0
	move_and_slide()
	AudioManager.play_sfx(AudioManager.sfx_slash, 1.4)
	
	var tween = create_tween()
	tween.tween_property(visual_root, "modulate", Color(0.4, 0.8, 1.0), 0.1)
	tween.tween_property(visual_root, "modulate", Color(1.0, 1.0, 1.0), 0.2)
	
	await get_tree().create_timer(0.25).timeout
	hitbox_area.monitoring = false
	is_attack_in_progress = false
	current_state = State.IDLE

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		var enemy = area.get_parent()
		if enemy and enemy.has_method("take_damage"):
			var dmg = hitbox_area.get_meta("damage", 10)
			var k_dir = hitbox_area.get_meta("knockback_dir", facing_direction)
			var k_force = hitbox_area.get_meta("knockback_force", 120.0)
			var is_heavy = hitbox_area.get_meta("is_heavy", false)
			AudioManager.play_sfx(AudioManager.sfx_hit, randf_range(0.95, 1.15))
			enemy.take_damage(dmg, k_dir * k_force, is_heavy)
