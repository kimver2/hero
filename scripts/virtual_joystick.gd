class_name MobileVirtualJoystick
extends Control

@export var max_distance: float = 60.0
@export var deadzone: float = 10.0

var touch_index: int = -1
var center_pos: Vector2 = Vector2.ZERO
var current_vector: Vector2 = Vector2.ZERO

@onready var base: Control = $Base
@onready var handle: Control = $Base/Handle

func _ready() -> void:
	center_pos = base.position + (base.size / 2.0)
	_reset_handle()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			var local_pos = event.position
			# 화면 좌측 절반에서 터치 발생 시 활성화
			if local_pos.x < get_viewport_rect().size.x * 0.5:
				touch_index = event.index
				base.global_position = event.position - (base.size / 2.0)
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
	# 가상 조이스틱 입력을 Godot의 기본 move 액션에 투영
	_set_action_strength("move_left", max(0.0, -vec.x))
	_set_action_strength("move_right", max(0.0, vec.x))
	_set_action_strength("move_up", max(0.0, -vec.y))
	_set_action_strength("move_down", max(0.0, vec.y))

func _set_action_strength(action: StringName, strength: float) -> void:
	if strength > 0.3:
		if not Input.is_action_pressed(action):
			Input.action_press(action, strength)
	else:
		if Input.is_action_pressed(action):
			Input.action_release(action)
