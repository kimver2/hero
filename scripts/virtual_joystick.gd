class_name MobileVirtualJoystick
extends Control

@export var max_distance: float = 48.0
@export var deadzone: float = 8.0

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
			# 화면 좌측 절반에서 터치 발생 시 조작 시작
			if event.position.x < get_viewport_rect().size.x * 0.45:
				touch_index = event.index
				center_pos = base.global_position + (base.size / 2.0)
				_update_joystick(event.position)
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_reset_handle()
			_apply_input_actions(Vector2.ZERO)

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

func _apply_input_actions(vec: Vector2) -> void:
	# 4방향 / 8방향을 확실한 강도로 즉시 전달 (deadzone 0.25 기준)
	_set_action("move_left", vec.x < -0.25)
	_set_action("move_right", vec.x > 0.25)
	_set_action("move_up", vec.y < -0.25)
	_set_action("move_down", vec.y > 0.25)

func _set_action(action: StringName, is_active: bool) -> void:
	if is_active:
		Input.action_press(action, 1.0)
	else:
		Input.action_release(action)
