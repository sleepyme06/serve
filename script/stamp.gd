extends Control

signal stamp_selected(stamp_name)
signal stamp_used(stamp_name)

var emoji_font = preload("res://assets/NotoEmoji-Regular.ttf")

func _get_emoji(stamp_name: String) -> String:
	match stamp_name:
		"heart":     return char(0x1F496)  # 💖
		"star":      return char(0x1F31F)  # 🌟
		"lightning": return char(0x26A1)   # ⚡
		"crown":     return char(0x1F451)  # 👑
		"flower":    return char(0x1F338)  # 🌸
	return "?"

func _ready():
	$buttons/heart.text    = _get_emoji("heart")
	$buttons/star.text     = _get_emoji("star")
	$buttons/lighting.text = _get_emoji("lightning")
	$buttons/crown.text    = _get_emoji("crown")
	$buttons/flower.text   = _get_emoji("flower")

	for button in $buttons.get_children():
		button.add_theme_font_override("font", emoji_font)
		button.add_theme_font_size_override("font_size", 28)

	$buttons/heart.pressed.connect(_on_stamp_pressed.bind("heart"))
	$buttons/star.pressed.connect(_on_stamp_pressed.bind("star"))
	$buttons/lighting.pressed.connect(_on_stamp_pressed.bind("lightning"))
	$buttons/crown.pressed.connect(_on_stamp_pressed.bind("crown"))
	$buttons/flower.pressed.connect(_on_stamp_pressed.bind("flower"))

func _on_stamp_pressed(stamp_name):
	emit_signal("stamp_selected", stamp_name)
	emit_signal("stamp_used", stamp_name)
