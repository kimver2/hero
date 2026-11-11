class_name QuestTracker
extends Control

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var progress_label: Label = $Panel/MarginContainer/VBoxContainer/ProgressLabel

func set_quest(title: String, current: int, total: int) -> void:
	title_label.text = "[메인] " + title
	progress_label.text = "처치: %d / %d" % [current, total]
	
	if current >= total:
		progress_label.text = "★ 임무 완료! 제단으로 이동하세요"
		progress_label.modulate = Color(0.3, 1.0, 0.4)
		var tween = create_tween()
		tween.tween_property($Panel, "scale", Vector2(1.08, 1.08), 0.15)
		tween.tween_property($Panel, "scale", Vector2(1.0, 1.0), 0.15)
