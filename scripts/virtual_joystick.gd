class_name MobileVirtualJoystick
extends Control

@export var max_distance: float = 45.0
@export var deadzone: float = 6.0

var touch_index: int = -1
var center_pos: Vector2 = Vector2.ZERO
var current_vector: Vector2 = Vector2.ZERO

@onready var base: Control = $Base
@onready var handle: Control = $Base/Handle

func _ready() -> void:
	center_pos = base.global_position + (base.size / 2.0)
	_reset_handle()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			if event.position.x < get_viewport_rect().size.x * 0.45:
				touch_index = event.index
				center_pos = base.global_position + (base.size / 2.0)
				_update_joystick(event.position)
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_reset_handle()

	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_joystick(event.position)

func _update_joystick(touch_pos: Vector2) -> void:
	center_pos = base.global_position + (base.size / 2.0)
	var diff = touch_pos - center_pos
	var dist = diff.length()
	
	if dist > max_distance:
		diff = diff.normalized() * max_distance
	
	handle.global_position = center_pos + diff - (handle.size / 2.0)
	
	if dist < deadzone:
		current_vector = Vector2.ZERO
	else:
		current_vector = diff / max_distance
	
	_apply_input_actions(current_vector)

func _reset_handle() -> void:
	current_vector = Vector2.ZERO
	handle.position = (base.size - handle.size) / 2.0
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")

func _apply_input_actions(vec: Vector2) -> void:
	# 각 방향별 강도 0.0 ~ 1.0 전달
	_update_action("move_left", max(0.0, -vec.x))
	_update_action("move_right", max(0.0, vec.x))
	_update_action("move_up", max(0.0, -vec.y))
	_update_action("move_down", max(0.0, vec.y))

func _update_action(action: StringName, strength: float) -> void:
	if strength > 0.15:
		# 조금만 밀어도 안정적으로 인식되도록 강도 보정
		var mapped_strength = remap(strength, 0.15, 1.0, 0.5, 1.0)
		Input.action_press(action, mapped_strength)
	else:
		Input.action_release(action)
