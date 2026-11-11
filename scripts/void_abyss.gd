class_name VoidAbyss
extends Node2D

@onready var player = $Player
@onready var elia = $EliaNPC
@onready var karad = $KaradNPC
@onready var boss = $BossCabalis
@onready var hud = $HUD
@onready var boss_hp_bar = $HUD/BossHPBar
@onready var dialog_box = $DialogBox
@onready var victory_screen = $VictoryScreen

var is_intro_done: bool = false
var elia_heal_timer: float = 7.0

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
	
	hud.update_quest("공허의 심연 진입", 0, 1)
	
	# 0.5초 후 최종 마신 대면 컷신
	await get_tree().create_timer(0.5).timeout
	_play_encounter_cutscene()

func _process(delta: float) -> void:
	if not is_intro_done or not is_instance_valid(boss) or not is_instance_valid(player):
		return
	
	# 엘리아의 성스러운 기도 (7초마다 플레이어 HP +25 및 SP +15 회복)
	elia_heal_timer -= delta
	if elia_heal_timer <= 0.0:
		elia_heal_timer = 7.0
		_cast_elia_healing()

func _cast_elia_healing() -> void:
	if player and player.current_hp > 0:
		player.current_hp = min(player.max_hp, player.current_hp + 25)
		player.current_sp = min(player.max_sp, player.current_sp + 15)
		player.emit_signal("health_changed", player.current_hp, player.max_hp)
		player.emit_signal("mana_changed", player.current_sp, player.max_sp)
		AudioManager.play_sfx(AudioManager.sfx_potion, 1.2, -4.0)
		
		# 엘리아 치유 빛무리 연출
		var tween = create_tween()
		player.visual_root.modulate = Color(1.5, 2.5, 1.5)
		tween.tween_property(player.visual_root, "modulate", Color(1, 1, 1), 0.4)

func _play_encounter_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var encounter_lines: Array[Dictionary] = [
		{
			"speaker": "카라드",
			"side": "left",
			"text": "이곳이 공허의 심연... 차원 너머에 웅크리고 있던 마신 카발리스의 본체인가!"
		},
		{
			"speaker": "마신 카발리스",
			"side": "right",
			"text": "크하하하... 어리석은 필멸자들아. 스스로 심연의 아가리로 뛰어들었구나!"
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "기사님...! 제 모든 신성력을 기사님의 검에 깃들게 하겠습니다. [성광섬멸참(O키)]으로 마신의 암흑을 가르세요!"
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "모두의 염원과 신녀의 기도를 이 검에 싣는다... 카발리스, 영원히 잠들어라!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_encounter_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(encounter_lines)

func _on_encounter_dialog_finished() -> void:
	if player:
		player.set_control_active(true)
	if boss_hp_bar:
		boss_hp_bar.init_boss("시원의 마신 카발리스", boss.max_hp)
	is_intro_done = true
	hud.update_quest("시원의 마신 카발리스 완전 격퇴", 0, 1)

func _on_boss_defeated() -> void:
	if boss_hp_bar:
		boss_hp_bar.visible = false
	
	await get_tree().create_timer(1.2).timeout
	_play_grand_ending_cutscene()

func _play_grand_ending_cutscene() -> void:
	if player:
		player.set_control_active(false)
	
	var ending_lines: Array[Dictionary] = [
		{
			"speaker": "마신 카발리스",
			"side": "right",
			"text": "크아아악-! 이럴 수가... 대륙의 봉인이... 성스러운 빛에 의해 영원히 닫힌단 말인가...!"
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "빛의 성령이여... 이 땅의 모든 상처를 보듬고, 암흑의 문을 영원히 닫으소서...!"
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "후우... 끝났군. 20년 전 나의 어리석은 죄업이... 오늘 너희들 덕분에 드디어 끝났다."
		},
		{
			"speaker": "카라드",
			"side": "right",
			"text": "고맙다 레온, 그리고 엘리아. 너희가 대륙의 진정한 구원자다."
		},
		{
			"speaker": "레온",
			"side": "left",
			"text": "아닙니다, 카라드 아저씨와 엘리아가 함께해 주었기에 해낼 수 있었습니다."
		},
		{
			"speaker": "엘리아",
			"side": "left",
			"text": "보세요... 차원의 어둠이 걷히고, 저 너머에 대륙의 눈부신 아침 햇살이 비추고 있어요...!"
		}
	]
	
	dialog_box.dialog_finished.connect(_on_ending_dialog_finished, CONNECT_ONE_SHOT)
	dialog_box.start_dialog(ending_lines)

func _on_ending_dialog_finished() -> void:
	hud.update_quest("대륙의 영웅 - 마신 카발리스 영구 봉인 완료!", 1, 1)
	if victory_screen:
		victory_screen.show_victory()
