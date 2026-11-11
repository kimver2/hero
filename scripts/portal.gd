class_name ScenePortal
extends Area2D

@export_file("*.tscn") var target_scene_path: String = "res://scenes/maps/altar_room.tscn"
@export var is_active: bool = false

@onready var visual: Node2D = $Visual
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_active(is_active)

func set_active(active: bool) -> void:
	is_active = active
	monitoring = active
	visible = active
	if active:
		var tween = create_tween().set_loops()
		tween.tween_property(visual, "rotation_degrees", 360.0, 4.0).from(0.0)

func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	if body is CharacterBody2D and body.is_in_group("player"):
		_teleport_player()

func _teleport_player() -> void:
	# 화면 전환
	monitoring = false
	if not target_scene_path.is_empty():
		get_tree().change_scene_to_file(target_scene_path)
