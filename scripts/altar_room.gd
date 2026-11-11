class_name AltarRoom
extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var dialog_box = $DialogBox
@onready var boss = $BossPriest
@onready var elia = $EliaNPC
@onready var boss_hp_bar = $HUD/BossHPBar
@onready var exit_portal = $ExitPortal

var is_boss_started: bool = false
var is_boss_defeated: bool = false

func _ready() -> void:
	if player and hud:
		player.health_changed.connect(hud.update_hp)
		player.mana_changed.connect(hud.update_sp)
	
	if boss:
		boss.health_changed.connect(_on_boss_health_changed)
		boss.defeated.connect(_on_boss_defeated)
	
	if exit_portal:
		exit_portal.set_active(false)
	
	hud.update_quest("사교도 사제 처치 및 엘리아 구출", 0, 1)
	
	# 0.4초 후 보스 조우 컷신 시작
	await get_tree().create_timer(0.4).timeout
	_play_boss_intro_cutscene()

func _play_boss_intro_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var script_lines: Array[Dictionary] = [
		{
			"speaker": "사교도 사제 바로스",
			"side": "right",
			"text": "크큭... 풋내기 기사놈이 감히 성스러운 제단까지 발을 들이다니. 순수한 신관의 피는 곧 위대한 혼돈의 심장을 깨울 것이다!"
		},
		{
			"speaker": "엘리아",
			"side": "right",
			"text": "...도망치세요... 어서... 이 자는 어둠의 고대 마법을 다루는 자예요...!"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "어린 소녀를 제물로 바치려는 네놈들의 사악한 주술은 여기까지다. 칼을 뽑아라!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_intro_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(script_lines)

func _on_intro_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	
	if boss and boss_hp_bar:
		boss_hp_bar.setup("사교도 사제 바로스", boss.max_hp)
		boss.start_boss_battle()

func _on_boss_health_changed(current: int, max_val: int) -> void:
	if boss_hp_bar:
		boss_hp_bar.update_hp(current, max_val)

func _on_boss_defeated() -> void:
	is_boss_defeated = true
	hud.update_quest("사교도 사제 처치 및 엘리아 구출", 1, 1)
	
	await get_tree().create_timer(1.2).timeout
	_play_rescue_cutscene()

func _play_rescue_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	if elia:
		elia.set_state(EliaNPC.State.RESCUED)
	
	var rescue_lines: Array[Dictionary] = [
		{
			"speaker": "레온",
			"side": "left",
			"text": "하아... 하아... 사제를 쓰러뜨렸다. (챙강! 쇠사슬을 끊는다)"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "이제 안전해. 다친 곳은 없니? 넌 대체 누구야?"
		},
		{
			"speaker": "엘리아",
			"side": "right",
			"text": "구해주셔서... 감사합니다... 제 이름은 엘리아... 하지만... 제가 누구였는지, 왜 이런 곳에 있었는지는 기억나지 않아요..."
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "기억 상실인가... 하지만 네 몸에서 느껴지는 신성력은 예사롭지 않아. 일단 변방 주둔지로 가자. 내가 널 지켜줄게."
		},
		{
			"speaker": "엘리아",
			"side": "right",
			"text": "네, 기사님... 기사님을... 믿을게요. 함께 갈게요!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_rescue_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(rescue_lines)

func _on_rescue_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	
	if elia:
		elia.set_state(EliaNPC.State.FOLLOWING)
	
	if exit_portal:
		exit_portal.set_active(true)
