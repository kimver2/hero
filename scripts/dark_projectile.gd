class_name DarkProjectile
extends Area2D

@export var speed: float = 175.0
@export var damage: int = 12

var direction: Vector2 = Vector2.RIGHT

func setup(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	# 3초 후 자동 소멸
	get_tree().create_timer(3.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player = area.get_parent()
		if player and player.has_method("take_damage"):
			player.take_damage(damage, direction * 150.0)
			queue_free()
