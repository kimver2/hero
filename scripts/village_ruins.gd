class_name VillageRuins
extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var dialog_box = $DialogBox
@onready var elia = $EliaNPC
@onready var karad = $KaradNPC
@onready var exit_portal = $ExitPortal

var quest_title: String = "불타는 주둔지의 정예 기사 토벌"
var target_count: int = 2
var current_count: int = 0
var is_intro_done: bool = false

func _ready() -> void:
	if player and hud:
		player.health_changed.connect(hud.update_hp)
		player.mana_changed.connect(hud.update_sp)
		player.potion_changed.connect(hud.update_potions)
	
	if elia:
		elia.set_state(EliaNPC.State.FOLLOWING)
	
	if karad:
		karad.visible = false
	
	_connect_knights()
	
	# 0.4초 후 마을 도착 컷신
	await get_tree().create_timer(0.4).timeout
	_play_arrival_cutscene()

func _connect_knights() -> void:
	var knights = get_tree().get_nodes_in_group("knights")
	for k in knights:
		if k.has_signal("defeated"):
			k.defeated.connect(_on_knight_defeated)

func _play_arrival_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var arrival_lines: Array[Dictionary] = [
		{
			"speaker": "레온",
			"side": "left",
			"text": "이럴 수가... 마을 전체가 불타고 있어! 대체 무슨 일이 일어난 거지?!"
		},
		{
			"speaker": "엘리아",
			"side": "right",
			"text": "기사님... 저곳에 무장한 기사들이... 저 사악한 문양은 사교도들의 정예병들이에요!"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "엘리아, 내 뒤에 바짝 붙어 있어! 사교도 놈들을 모조리 쓸어버리겠다!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_arrival_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(arrival_lines)

func _on_arrival_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	is_intro_done = true
	hud.update_quest(quest_title, current_count, target_count)

func _on_knight_defeated() -> void:
	current_count += 1
	hud.update_quest(quest_title, current_count, target_count)
	
	if current_count >= target_count:
		await get_tree().create_timer(0.8).timeout
		_play_karad_appearance_cutscene()

func _play_karad_appearance_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	if karad:
		karad.visible = true
		karad.global_position = player.global_position + Vector2(60, -30)
		# 카라드 등장 검기 연출
		var tween = create_tween()
		karad.modulate = Color(2.5, 2.0, 1.0)
		tween.tween_property(karad, "modulate", Color(1, 1, 1), 0.4)
	
	var karad_lines: Array[Dictionary] = [
		{
			"speaker": "카라드",
			"side": "right",
			"text": "후우... 풋내기 꼬마 녀석 치고는 제법 칼을 쥐고 버텼군그래."
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "카라드 아저씨?! 주점에서 술만 마시던 아저씨가 어떻게 대검을...?"
		},
		{
			"speaker": "카라드 (엘리아를 멍하니 응시하며)",
			"side": "right",
			"text": "...잠깐, 꼬마야. 그 뒤에 있는 계집아이는 누구지? ...아니, 말도 안 돼... 20년 전 그 신관의 모습과 똑같잖아?!"
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "아저씨는... 저를... 아시나요? 제 과거를 아시는 건가요...?"
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "...쳇, 잊으려 했던 악몽이 기어코 다시 찾아온 건가. 레온, 네 아비의 올곧은 검술로는 놈들의 암흑 마법을 뚫을 수 없다."
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "내 비기 [파천검]의 요결을 네 검에 실어주마. 위급할 때 지면을 갈라 적들을 쓸어버려라! (I키 / 파천 버튼)"
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "나도 너희와 동행하겠다. 황혼의 사도단 놈들에게... 내 오랜 빚을 갚아야 할 때가 온 것 같군."
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "카라드 아저씨... 알겠습니다. 우리 셋이 함께 이 대륙의 혼돈을 막아냅시다!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_karad_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(karad_lines)

func _on_karad_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	
	if karad:
		karad.start_following()
	
	if exit_portal:
		exit_portal.set_active(true)
	
	hud.update_quest("성소 포털을 통해 고대 숲으로 진입", 1, 1)
