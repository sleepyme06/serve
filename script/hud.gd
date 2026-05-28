extends Control

signal hint_requested
signal timer_ended
signal next_level_requested
signal retry_requested
signal game_started

var emoji_font = preload("res://assets/NotoEmoji-Regular.ttf")

func _get_emoji(stamp_name: String) -> String:
	match stamp_name:
		"heart":     return char(0x1F496)
		"star":      return char(0x1F31F)
		"lightning": return char(0x26A1)
		"crown":     return char(0x1F451)
		"flower":    return char(0x1F338)
	return "?"

func _apply_emoji_font(label: Label):
	# Use SystemFont as base so regular text renders correctly,
	# then fall back to NotoEmoji only for emoji codepoints.
	var sys_font = SystemFont.new()
	sys_font.fallbacks = [emoji_font]
	label.add_theme_font_override("font", sys_font)

func _ready():
	$win.visible = false
	$loose.visible = false
	$pattern.visible = false
	$start.visible = true

	$start/Label.text = "SERVE " + char(0x1F485)          # 💅
	_apply_emoji_font($start/Label)

	$win/Label.text = "You ate that scrapbook up " + char(0x2728)  # ✨
	_apply_emoji_font($win/Label)

	$loose/Label.text = "Skill issue " + char(0x1F480)   # 💀
	_apply_emoji_font($loose/Label)

	$win/Button.pressed.connect(_on_next_pressed)
	$loose/Button.pressed.connect(_on_cook_pressed)
	$start/Button.pressed.connect(_on_start_pressed)

func show_start():
	$start.visible = true
	$win.visible = false
	$loose.visible = false
	get_tree().call_group("stamps", "hide")

func _on_start_pressed():
	$start.visible = false
	emit_signal("game_started")

func update_timer(time_left):
	$bg/timer.text = str(int(time_left))

func show_win():
	$win.visible = true
	$loose.visible = false

func show_lose():
	$win.visible = false
	$loose.visible = true

func _on_next_pressed():
	$win.visible = false
	emit_signal("next_level_requested")

func _on_cook_pressed():
	$loose.visible = false
	emit_signal("retry_requested")

func _on_hint_button_pressed():
	emit_signal("hint_requested")

func _on_hint_pressed() -> void:
	emit_signal("hint_requested")

func show_pattern_screen(pattern):
	$pattern.visible = true
	for child in $pattern/HBoxContainer.get_children():
		child.queue_free()
	for stamp in pattern:
		var label = Label.new()
		label.text = _get_emoji(stamp)
		label.add_theme_font_override("font", emoji_font)
		label.add_theme_font_size_override("font_size", 64)
		label.add_theme_color_override("font_color", Color("#FF2D78"))
		$pattern/HBoxContainer.add_child(label)

func hide_pattern_screen():
	$pattern.visible = false
