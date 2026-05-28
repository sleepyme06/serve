extends Node2D

var current_level=1
var target_pattrens=[]
var placed_stamps=[]
var time_remaining=30
var hint_used=false
var game_active=false
var flash_time = 2.0
var is_flashing = false
var flash_timer = 0.0

func _ready():
	$gamesscene/stamp.stamp_selected.connect(_on_stamp_selected)
	$gamesscene/stamp.stamp_used.connect(_on_stamp_used)
	$gamesscene/paper.stamp_placed.connect(_on_stamp_placed)
	$gamesscene/hud.hint_requested.connect(_on_hint_requested)
	$gamesscene/hud.next_level_requested.connect(_on_next_level)
	$gamesscene/hud.retry_requested.connect(_on_retry)
	$gamesscene/hud.game_started.connect(_on_game_started)
	$gamesscene/stamp.visible = false
	$gamesscene/paper.visible = false
	
func _on_game_started():
	current_level = 1
	$gamesscene/stamp.visible = true
	$gamesscene/paper.visible = true
	start_level()
	
func _process(delta):
	if game_active and time_remaining > 0:
		time_remaining -= delta
		$gamesscene/hud.update_timer(time_remaining)
	elif game_active and time_remaining <= 0:
		time_remaining = 0
		game_active = false
		$gamesscene/hud.show_lose()
		print("skill issue")

func start_level():
	placed_stamps = []
	$gamesscene/paper.reset_paper()
	hint_used = false
	game_active = false
	$gamesscene/paper.set_process_input(false)
	
	var all_stamps = ["heart", "star", "lightning", "crown", "flower"]
	all_stamps.shuffle()
	
	if current_level == 1:
		time_remaining = 30
		flash_time = 2.0
		target_pattrens = all_stamps.slice(0, 2)
	elif current_level == 2:
		time_remaining = 25
		flash_time = 1.5
		target_pattrens = all_stamps.slice(0, 3)
	elif current_level == 3:
		time_remaining = 20
		flash_time = 1.0
		target_pattrens = all_stamps.slice(0, 4)
	elif current_level == 4:
		time_remaining = 15
		flash_time = 0.8
		target_pattrens = all_stamps.slice(0, 5)
	
	print("level " + str(current_level) + " started")
	print("target:" + str(target_pattrens))
	
	$gamesscene/paper.setup_slots(target_pattrens.size())
	$gamesscene/hud.update_timer(time_remaining)
	$gamesscene/hud.show_pattern_screen(target_pattrens)
	
	await get_tree().create_timer(flash_time).timeout
	
	$gamesscene/hud.hide_pattern_screen()
	$gamesscene/paper.set_process_input(true)
	game_active = true
	print("pattern hidden - go!")

func _on_stamp_selected(stamp_name):
	$gamesscene/paper.set_selected_stamp(stamp_name)
	print("selected: " + stamp_name)

func _on_stamp_used(stamp_name):
	if not game_active:
		return
	$gamesscene/paper.set_selected_stamp(stamp_name)
	$gamesscene/paper.place_stamp()
	print("instant stamp: " + stamp_name)
	
func _on_stamp_placed(stamp_name):
	if not game_active:
		return
	if placed_stamps.size() >= target_pattrens.size():
		return
	var slot_index = placed_stamps.size()
	placed_stamps.append(stamp_name)
	$gamesscene/paper.fill_slot(slot_index, stamp_name)
	print("placed: " + str(placed_stamps))
	if placed_stamps.size() == target_pattrens.size():
		check_pattrens()

func check_pattrens():
	if placed_stamps==target_pattrens:
		print("u ate the scrapebook")
		game_active=false
		await get_tree().create_timer(0.5).timeout
		$gamesscene/hud.show_win()
	else:
		placed_stamps=[]
		print("fahhhhhhhh")
		$gamesscene/paper.clear_slots()
		
func _on_hint_requested():
	if hint_used:
		return
	hint_used = true
	game_active = false
	var hint_duration = flash_time / 2.0
	$gamesscene/hud.show_pattern_screen(target_pattrens)
	await get_tree().create_timer(hint_duration).timeout
	$gamesscene/hud.hide_pattern_screen()
	game_active = true
	print("hint used - timer resumed")

func set_paper_active(active):
	$gamesscene/paper.set_process_input(active)

func _on_next_level():
	if current_level >= 4:
		current_level =1
		$gamesscene/hud.show_start()
	else:
		current_level+=1
		start_level()

func _on_retry():
	start_level()
