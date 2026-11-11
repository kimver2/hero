class_name DialogBox
extends CanvasLayer

signal dialog_finished

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameContainer/NameLabel
@onready var text_label: Label = $Panel/TextMargin/TextLabel
@onready var left_portrait: TextureRect = $LeftPortrait
@onready var right_portrait: TextureRect = $RightPortrait
@onready var next_indicator: Label = $Panel/NextIndicator

var dialog_queue: Array[Dictionary] = []
var current_line: Dictionary = {}
var is_typing: bool = false
var text_progress: float = 0.0
var full_text: String = ""
var typing_speed: float = 35.0 # 초당 글자 수

func _ready() -> void:
	visible = false
	next_indicator.visible = false

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
			next_indicator.visible = true
		else:
			text_label.text = full_text.substr(0, char_count)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("attack") or (event is InputEventScreenTouch and event.pressed):
		if is_typing:
			# 타이핑 중 클릭 시 전체 텍스트 즉시 출력 (스킵)
			text_label.text = full_text
			is_typing = false
			next_indicator.visible = true
		else:
			# 다음 대사로 진행
			_show_next_line()
		get_viewport().set_input_as_handled()

func _show_next_line() -> void:
	if dialog_queue.is_empty():
		visible = false
		emit_signal("dialog_finished")
		return
	
	current_line = dialog_queue.pop_front()
	var speaker = current_line.get("speaker", "???")
	full_text = current_line.get("text", "")
	var side = current_line.get("side", "left") # "left" or "right"
	
	name_label.text = " [ %s ] " % speaker
	text_label.text = ""
	text_progress = 0.0
	is_typing = true
	next_indicator.visible = false
	
	# 영웅서기 특유의 포트레이트 활성화/비활성화 연출
	if side == "left":
		left_portrait.visible = true
		left_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0) # 활성
		right_portrait.modulate = Color(0.4, 0.4, 0.4, 0.7) # 비활성 음영
	else:
		right_portrait.visible = true
		right_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)
		left_portrait.modulate = Color(0.4, 0.4, 0.4, 0.7)
