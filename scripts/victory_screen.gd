class_name VictoryScreen
extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/TitleLabel
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var desc_label: Label = $Panel/DescLabel
@onready var restart_button: Button = $Panel/ButtonContainer/RestartButton

func _ready() -> void:
	visible = false
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)

func show_victory() -> void:
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.2)
	AudioManager.play_sfx(AudioManager.sfx_potion, 0.8, 3.0)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/maps/test_field.tscn")
