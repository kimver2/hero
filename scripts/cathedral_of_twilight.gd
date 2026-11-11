class_name CathedralOfTwilight
extends Node2D

@onready var player = $Player
@onready var elia = $EliaNPC
@onready var karad = $KaradNPC
@onready var boss = $BossMalakar
@onready var hud = $HUD
@onready var boss_hp_bar = $HUD/BossHPBar
@onready var dialog_box = $DialogBox
@onready var victory_screen = $VictoryScreen

var is_intro_done: bool = false

func _ready() -> void:
	if player and hud:
		player.health_changed.connect(hud.update_hp)
		player.mana_changed.connect(hud.update_sp)
		player.potion_changed.connect(hud.update_potions)
	
	if elia:
		elia.set_state(EliaNPC.State.FOLLOWING)
	
	if karad:
		karad.start_following()
	
	if boss and boss_hp_bar:
		boss_hp_bar.visible = false
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
		boss_hp_bar.init_boss("황혼의 대주교 말라카르", boss.max_hp)
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
			"text": "크아악...! 이럴 수가... 위대한 마신 카발리스 님이... 고작 인간 따위에게... 으아아아악-!"
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "영원한 안식의 빛이여... 흩어진 봉인의 족쇄를 엮어, 암흑을 심연으로 되돌리소서...!"
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "후우... 끝났군. 20년 동안 내 가슴을 짓누르던 끔찍한 족쇄가 마침내 풀렸다."
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "카라드 아저씨, 엘리아... 해냈어요. 대륙에 다시 평화가 찾아왔습니다."
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "고맙다 꼬마야... 아니, 레온. 네 아버지보다도 훨씬 훌륭한 진정한 기사가 되었구나."
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "기사님, 그리고 카라드 님... 영원히 이 여정을 잊지 못할 거예요. 우리 함께 새로운 아침을 맞이하러 가요!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_ending_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(ending_lines)

func _on_ending_dialog_finished() -> void:
	hud.update_quest("최종 결전 승리! 대륙의 혼돈 평정 완료", 1, 1)
	if victory_screen:
		victory_screen.show_victory()
