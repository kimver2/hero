class_name BossHPBar
extends Control

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var hp_bar: ProgressBar = $VBoxContainer/ProgressBar

func _ready() -> void:
	visible = false

func setup(boss_name: String, max_val: int) -> void:
	name_label.text = "★ " + boss_name + " ★"
	hp_bar.max_value = max_val
	hp_bar.value = max_val
	visible = true

func update_hp(current: int, max_val: int) -> void:
	hp_bar.max_value = max_val
	hp_bar.value = current
	if current <= 0:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 1.0)
		await tween.finished
		visible = false
