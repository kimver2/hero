class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPContainer/HPBar
@onready var sp_bar: ProgressBar = $MarginContainer/VBoxContainer/SPContainer/SPBar
@onready var hp_label: Label = $MarginContainer/VBoxContainer/HPContainer/HPLabel
@onready var sp_label: Label = $MarginContainer/VBoxContainer/SPContainer/SPLabel
@onready var quest_tracker = $QuestTracker
@onready var potion_label: Label = $MarginContainer/VBoxContainer/PotionContainer/PotionLabel

func update_potions(count: int) -> void:
	if potion_label:
		potion_label.text = "%d 개" % count

func update_quest(title: String, current: int, total: int) -> void:
	if quest_tracker:
		quest_tracker.set_quest(title, current, total)

func update_hp(current: int, max_val: int) -> void:
	hp_bar.max_value = max_val
	hp_bar.value = current
	hp_label.text = "%d / %d" % [current, max_val]

func update_sp(current: int, max_val: int) -> void:
	sp_bar.max_value = max_val
	sp_bar.value = current
	sp_label.text = "%d / %d" % [current, max_val]
