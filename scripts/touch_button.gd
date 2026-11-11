class_name TouchButton
extends Button

@export var action_name: String = "attack"

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down() -> void:
	if not action_name.is_empty():
		Input.action_press(action_name)

func _on_button_up() -> void:
	if not action_name.is_empty():
		Input.action_release(action_name)
