class_name ForestSanctuary
extends Node2D

@onready var player = $Player
@onready var elia = $EliaNPC
@onready var karad = $KaradNPC
@onready var boss = $BossGuardian
@onready var hud = $HUD
@onready var boss_hp_bar = $HUD/BossHPBar
@onready var dialog_box = $DialogBox
@onready var exit_portal = $ExitPortal

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
	
	if exit_portal:
		exit_portal.set_active(false)
	
	hud.update_quest("고대 숲의 성소 탐색", 0, 1)
	
	# 0.5초 후 보스 대면 컷신
	await get_tree().create_timer(0.5).timeout
	_play_encounter_cutscene()

func _play_encounter_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var encounter_lines: Array[Dictionary] = [
		{
			"speaker": "카라드",
			"side": "right",
			"text": "이곳이 고대 정령의 성소인가... 하지만 대기가 붉은 암흑 마법으로 오염되어 있군."
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "머리가... 욱신거려요... 저기 잠들어 있던 숲의 수호수가 사교도의 암흑 주술에 침식당했어요!"
		},
		{
			"speaker": "타락한 수호수",
			"side": "right",
			"text": "크아아아아아아-!! (붉은 안광을 번뜩이며 포효한다!)"
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "조심해라! 녀석의 외피는 단단하다. 내 전수해 준 [파천검(I키)]으로 껍질을 부수고 돌진을 회피해라!"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "녀석을 제압해서 성스러운 정령으로 정화시키겠다! 전원 전투 개시!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_encounter_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(encounter_lines)

func _on_encounter_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	if boss_hp_bar:
		boss_hp_bar.init_boss("타락한 숲의 수호수", boss.max_hp)
	is_intro_done = true
	hud.update_quest("타락한 숲의 수호수 제압 및 정화", 0, 1)

func _on_boss_defeated() -> void:
	if boss_hp_bar:
		boss_hp_bar.visible = false
	
	await get_tree().create_timer(1.0).timeout
	_play_purification_cutscene()

func _play_purification_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var victory_lines: Array[Dictionary] = [
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "빛의 성령이여... 이 순결한 정령에게 깃든 암흑의 족쇄를 풀어주소서...!"
		},
		{
			"speaker": "정화된 수호수",
			"side": "right",
			"text": "...(수호수가 에메랄드빛 성스러운 빛무리가 되어 대지에 흩어지며 고대의 문장을 남긴다.)"
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "기억나요...! 제 머릿속에 잠들어 있던 기억... 대륙의 4대 결계 중 하나인 [생명의 문장]이에요!"
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "그래... 20년 전 내가 봉인을 건드렸던 혼돈의 마신 '카발리스'. 사교도 놈들이 그 봉인을 풀려 하고 있어."
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "더 이상 물러설 곳은 없다. 놈들의 본거지인 [황혼의 대성당]으로 진격할 시간이다!"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "모두 가자! 대륙에 다시 혼돈의 파멸이 찾아오게 두지 않겠다!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_victory_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(victory_lines)

func _on_victory_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	if exit_portal:
		exit_portal.set_active(true)
	hud.update_quest("성소 포털을 통해 [황혼의 대성당]으로 진입", 1, 1)
