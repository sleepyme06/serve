extends Control

signal stamp_placed(stamp_name)

var selected_stamp = ""
var slot_count = 0
var can_place = true

var emoji_font = preload("res://assets/NotoEmoji-Regular.ttf")

func _get_emoji(stamp_name: String) -> String:
	match stamp_name:
		"heart":     return char(0x1F496)
		"star":      return char(0x1F31F)
		"lightning": return char(0x26A1)
		"crown":     return char(0x1F451)
		"flower":    return char(0x1F338)
	return "?"

func setup_slots(count):
	slot_count = count
	for child in $ColorRect/slotcont.get_children():
		child.queue_free()

	for i in range(count):
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(60, 60)

		var style = StyleBoxFlat.new()
		style.bg_color = Color("#1a0f3d")
		style.border_width_left = 3
		style.border_width_right = 3
		style.border_width_top = 3
		style.border_width_bottom = 3
		style.border_color = Color("#FFD700")
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		panel.add_theme_stylebox_override("panel", style)

		var label = Label.new()
		label.text = ""
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_override("font", emoji_font)
		label.add_theme_font_size_override("font_size", 28)
		panel.add_child(label)
		$ColorRect/slotcont.add_child(panel)

	await get_tree().process_frame
	var total_width = count * 60 + (count - 1) * 8
	var paper_width = $ColorRect.size.x
	$ColorRect/slotcont.position.x = (paper_width - total_width) / 2
	$ColorRect/slotcont.position.y = $ColorRect.size.y / 2 - 30

func set_selected_stamp(stamp_name):
	selected_stamp = stamp_name

func place_stamp():
	if selected_stamp == "":
		return
	emit_signal("stamp_placed", selected_stamp)
	selected_stamp = ""

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var paper_rect = $ColorRect.get_global_rect()
				if paper_rect.has_point(event.position):
					place_stamp()

func clear_slots():
	for slot in $ColorRect/slotcont.get_children():
		var children = slot.get_children()
		if children.size() > 0:
			children[0].text = ""

func fill_slot(index, stamp_name):
	var slots = $ColorRect/slotcont.get_children()
	if index < slots.size():
		var label = slots[index].get_children()[0]
		label.text = _get_emoji(stamp_name)
		label.add_theme_color_override("font_color", Color("#FF2D78"))

func show_pattern(_pattern): pass
func hide_pattern(): pass

func reset_paper():
	selected_stamp = ""
	for child in $ColorRect/slotcont.get_children():
		child.queue_free()
