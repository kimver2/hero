class_name CathedralOfTwilight
extends Node2D

@onready var player = $Player
@onready var elia = $EliaNPC
@onready var karad = $KaradNPC
@onready var boss = $BossMalakar
@onready var hud = $HUD
@onready var boss_hp_bar = $HUD/BossHPBar
@onready var dialog_box = $DialogBox
@onready var exit_portal = $ExitPortal
@onready var victory_screen = $VictoryScreen

var is_intro_done: bool = false

func _ready() -> void:
	if exit_portal:
		exit_portal.set_active(false)
	
	if player and hud:
		player.health_changed.connect(hud.update_hp)
		player.mana_changed.connect(hud.update_sp)
		player.potion_changed.connect(hud.update_potions)
	
	if elia:
		elia.set_state(EliaNPC.State.FOLLOWING)
	
	if karad:
		karad.start_following()
	
	if boss and boss_hp_bar:
		boss_hp_bar.setup("황혼의 대주교 말라카르", boss.max_hp)
		boss.boss_health_changed.connect(boss_hp_bar.update_hp)
		boss.boss_defeated.connect(_on_boss_defeated)
	
	hud.update_quest("황혼의 대성당 진입", 0, 1)
	
	# 0.5초 후 최종 보스 조우 컷신
	await get_tree().create_timer(0.5).timeout
	_play_encounter_cutscene()

func _play_encounter_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var encounter_lines: Array[Dictionary] = [
		{
			"speaker": "대주교 말라카르",
			"side": "right",
			"text": "크하하하! 기어코 이곳까지 찾아왔구나, 어리석은 어린 양들이여!"
		},
		{
			"speaker": "카라드",
			"side": "left",
			"text": "말라카르! 20년 전 내게 거짓 신탁을 내리고 마신의 봉인을 풀게 만든 흑막이 바로 네놈이었더냐?!"
		},
		{
			"speaker": "대주교 말라카르",
			"side": "right",
			"text": "그렇다, 배교자 카라드! 그리고 저 계집아이가 가져온 [생명의 문장]이야말로 카발리스 님의 부활을 완성할 마지막 제물이지!"
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "절대 당신 뜻대로 되지 않을 거예요! 성스러운 빛의 가호가 우리와 함께하고 있습니다!"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "카라드 아저씨의 속죄, 그리고 엘리아의 순결한 영혼을 더럽히지 못한다! 네놈의 야망은 여기서 끝이다!"
		},
		{
			"speaker": "대주교 말라카르",
			"side": "right",
			"text": "건방진 것들... 심연의 어둠 속에서 영원히 멸망하거라!!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_encounter_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(encounter_lines)

func _on_encounter_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	if boss_hp_bar:
		boss_hp_bar.setup("황혼의 대주교 말라카르", boss.max_hp)
	is_intro_done = true
	hud.update_quest("황혼의 대주교 말라카르 처단", 0, 1)

func _on_boss_defeated() -> void:
	if boss_hp_bar:
		boss_hp_bar.visible = false
	
	await get_tree().create_timer(1.2).timeout
	_play_ending_cutscene()

func _play_ending_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var ending_lines: Array[Dictionary] = [
		{
			"speaker": "대주교 말라카르",
			"side": "right",
			"text": "크아악...! 이대로 끝낼 수는 없다...! 내 심장과 영혼을 바쳐... 차원의 틈새를 찢어발기리라!"
		},
		{
			"speaker": "대주교 말라카르",
			"side": "right",
			"text": "위대한 혼돈의 마신 카발리스 님이시여... 나의 피를 마시고 강림하소서!! (대성당 제단이 무너지며 공허의 균열이 열린다!)"
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "안 돼...! 마신의 차원 균열이 대륙 전체를 삼키려 하고 있어요!"
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "놈이 기어코 최후의 발악을... 레온! 저 공허의 틈새로 뛰어들어 마신의 완전한 각성을 막아야 한다!"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "가자! 우리 셋의 영혼이 하나가 되는 한, 절대 굴복하지 않는다!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_ending_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(ending_lines)

func _on_ending_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	if exit_portal:
		exit_portal.set_active(true)
	hud.update_quest("공허의 균열 포털로 돌입하여 마신 카발리스 저지", 1, 1)
