class_name DialogBox
extends CanvasLayer

signal dialog_finished

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameContainer/NameLabel
@onready var text_label: Label = $Panel/TextMargin/TextLabel
@onready var left_portrait: TextureRect = $LeftPortrait
@onready var right_portrait: TextureRect = $RightPortrait
@onready var next_indicator: Label = $Panel/NextIndicator
@onready var touch_overlay: Control = $TouchOverlay

var dialog_queue: Array[Dictionary] = []
var current_line: Dictionary = {}
var is_typing: bool = false
var text_progress: float = 0.0
var full_text: String = ""
var typing_speed: float = 35.0 # 초당 글자 수
var indicator_tween: Tween = null

func _ready() -> void:
	visible = false
	next_indicator.visible = false
	next_indicator.text = "▼"
	# 화면 전체 터치 오버레이의 gui_input 연결 (화면 어디든, 안쪽이든 바깥이든 터치 인식)
	touch_overlay.gui_input.connect(_on_touch_overlay_gui_input)

func start_dialog(lines: Array[Dictionary]) -> void:
	dialog_queue = lines.duplicate()
	visible = true
	_show_next_line()

func _process(delta: float) -> void:
	if not visible:
		return
	
	if is_typing:
		text_progress += typing_speed * delta
		var char_count = int(text_progress)
		if char_count >= full_text.length():
			text_label.text = full_text
			is_typing = false
			_show_next_indicator()
		else:
			text_label.text = full_text.substr(0, char_count)

func _on_touch_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_advance_dialog()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance_dialog()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("attack"):
		_advance_dialog()
		get_viewport().set_input_as_handled()

func _advance_dialog() -> void:
	if is_typing:
		# 타이핑 중 터치 시 전체 텍스트 즉시 출력 (스킵)
		text_label.text = full_text
		is_typing = false
		_show_next_indicator()
	else:
		# 다음 대사로 진행
		_show_next_line()

func _show_next_indicator() -> void:
	next_indicator.visible = true
	if indicator_tween:
		indicator_tween.kill()
	indicator_tween = create_tween().set_loops()
	indicator_tween.tween_property(next_indicator, "modulate:a", 0.2, 0.4)
	indicator_tween.tween_property(next_indicator, "modulate:a", 1.0, 0.4)

const PORTRAIT_LEON = preload("res://assets/ui/portrait_leon.png")
const PORTRAIT_ELIA = preload("res://assets/ui/portrait_elia.png")
const PORTRAIT_KARAD = preload("res://assets/ui/portrait_karad.png")
const PORTRAIT_GUARDIAN = preload("res://assets/ui/portrait_guardian.png")

func _show_next_line() -> void:
	if dialog_queue.is_empty():
		visible = false
		if indicator_tween:
			indicator_tween.kill()
		emit_signal("dialog_finished")
		return
	
	current_line = dialog_queue.pop_front()
	var speaker = current_line.get("speaker", "???")
	full_text = current_line.get("text", "")
	var side = current_line.get("side", "left")
	
	name_label.text = " [ %s ] " % speaker
	text_label.text = ""
	text_progress = 0.0
	is_typing = true
	next_indicator.visible = false
	if indicator_tween:
		indicator_tween.kill()
	
	# 화자에 따른 초상화 텍스처 동적 매핑
	if side == "left":
		if "카라드" in speaker:
			left_portrait.texture = PORTRAIT_KARAD
		elif "엘리아" in speaker:
			left_portrait.texture = PORTRAIT_ELIA
		elif "수호수" in speaker:
			left_portrait.texture = PORTRAIT_GUARDIAN
		else:
			left_portrait.texture = PORTRAIT_LEON
		left_portrait.visible = true
		left_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)
		right_portrait.modulate = Color(0.4, 0.4, 0.4, 0.7)
	else:
		if "카라드" in speaker:
			right_portrait.texture = PORTRAIT_KARAD
		elif "레온" in speaker:
			right_portrait.texture = PORTRAIT_LEON
		elif "수호수" in speaker:
			right_portrait.texture = PORTRAIT_GUARDIAN
		else:
			right_portrait.texture = PORTRAIT_ELIA
		right_portrait.visible = true
		right_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)
		left_portrait.modulate = Color(0.4, 0.4, 0.4, 0.7)
