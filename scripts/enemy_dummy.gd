class_name EnemyDummy
extends CharacterBody2D

@export var max_hp: int = 100
var current_hp: int = 100
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var visual: Node2D = $Visual
@onready var sprite: Polygon2D = $Visual/BodySprite
@onready var hurtbox: Area2D = $Hurtbox

const FloatingDamageScene = preload("res://scripts/floating_damage.gd")

func _ready() -> void:
	current_hp = max_hp
	hurtbox.add_to_group("hurtbox")

func _physics_process(delta: float) -> void:
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 700.0 * delta)
		move_and_slide()

func take_damage(amount: int, knockback: Vector2, is_critical: bool = false) -> void:
	current_hp -= amount
	knockback_velocity = knockback
	
	# 데미지 플로팅 텍스트 소환
	_spawn_damage_text(amount, is_critical)
	
	# 피격 플래시 트윈
	var tween = create_tween()
	visual.modulate = Color(2.5, 0.4, 0.4) # 밝은 빨강 플래시
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.15)
	
	if current_hp <= 0:
		_on_death()

func _spawn_damage_text(amount: int, is_critical: bool) -> void:
	var label = FloatingDamageScene.new()
	get_parent().add_child(label)
	label.global_position = global_position + Vector2(-10, -20)
	label.setup(amount, is_critical)

func _on_death() -> void:
	# 더미이므로 잠시 사라졌다가 재생성
	hurtbox.set_deferred("monitoring", false)
	var tween = create_tween()
	tween.tween_property(visual, "scale", Vector2.ZERO, 0.2)
	await tween.finished
	
	await get_tree().create_timer(1.2).timeout
	current_hp = max_hp
	hurtbox.set_deferred("monitoring", true)
	var respawn_tween = create_tween()
	respawn_tween.tween_property(visual, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
