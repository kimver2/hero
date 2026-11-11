class_name TestField
extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var dialog_box = $DialogBox
@onready var portal = $Portal

var quest_title: String = "유적의 사교도 토벌"
var quest_target_count: int = 2
var quest_current_count: int = 0
var is_first_dialog_done: bool = false

func _ready() -> void:
	if player and hud:
		player.health_changed.connect(hud.update_hp)
		player.mana_changed.connect(hud.update_sp)
	
	if portal:
		portal.set_active(false)
	
	if dialog_box:
		dialog_box.dialog_finished.connect(_on_dialog_finished)
		await get_tree().create_timer(0.3).timeout
		_play_opening_scene()
	
	_connect_enemies()

func _connect_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("cultists")
	for enemy in enemies:
		if enemy.has_signal("defeated"):
			enemy.defeated.connect(_on_enemy_defeated)

func _play_opening_scene() -> void:
	if player:
		player.set_control_active(false)
	
	var opening_script: Array[Dictionary] = [
		{
			"speaker": "레온",
			"side": "left",
			"text": "아버지께서 물려주신 검을 차고 떠난 첫 순찰 임무... 그런데 이 변방 숲에 왜 이런 불길한 기운이 감도는 거지?"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "저 앞의 고대 유적 쪽에서 검은 로브를 입은 수상한 자들이 사람들을 습격하고 있어!"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "서둘러 사교도들을 처치하고 제단으로 가야겠다! (공격: Z / 회피: K / 질풍참: L)"
		}
	]
	
	dialog_box.start_dialog(opening_script)

func _on_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	
	if not is_first_dialog_done:
		is_first_dialog_done = true
		hud.update_quest(quest_title, quest_current_count, quest_target_count)
	elif quest_current_count >= quest_target_count:
		# 2차 컷신 종료 후 포탈 활성화 및 퀘스트 갱신
		if portal:
			portal.set_active(true)
		hud.update_quest("우측 포탈로 제단 진입", 0, 1)

func _on_enemy_defeated() -> void:
	quest_current_count += 1
	hud.update_quest(quest_title, quest_current_count, quest_target_count)
	
	if quest_current_count >= quest_target_count:
		await get_tree().create_timer(0.8).timeout
		_play_rescue_cutscene()

func _play_rescue_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var rescue_script: Array[Dictionary] = [
		{
			"speaker": "레온",
			"side": "left",
			"text": "후우... 사교도들을 모두 물리쳤다. 이제 제단 안쪽으로..."
		},
		{
			"speaker": "??? (소녀의 목소리)",
			"side": "right",
			"text": "...누군가... 계신가요...? 제발... 도와주세요..."
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "안쪽에서 가냘픈 목소리가 들려! 어린아이인가? 서둘러 가봐야겠어!"
		}
	]
	
	dialog_box.start_dialog(rescue_script)


