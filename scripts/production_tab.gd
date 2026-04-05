extends Control
## res://scripts/production_tab.gd
## Production department — schedule, capacity, automation per product.

const HEADER_COLOR = Color(0.102, 0.137, 0.494)
const LABEL_COLOR = Color(0.3, 0.3, 0.3)

var product_rows: Array = []

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.color = Color(0.96, 0.96, 0.97)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title = Label.new()
	title.text = "Production"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", HEADER_COLOR)
	title.position = Vector2(20, 10)
	add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Set production schedules, manage capacity, and invest in automation."
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", LABEL_COLOR)
	subtitle.position = Vector2(20, 36)
	add_child(subtitle)

	var gm = _get_game_manager()
	if gm == null or gm.companies.is_empty():
		return

	var headers = ["Product", "Segment", "Schedule", "1st Shift Cap", "2nd Shift", "Automation", "Inventory", "Labor Cost"]
	var col_x = [20, 120, 220, 350, 470, 580, 700, 810]

	var header_bg = ColorRect.new()
	header_bg.color = HEADER_COLOR
	header_bg.position = Vector2(10, 60)
	header_bg.size = Vector2(920, 30)
	add_child(header_bg)

	for i in range(headers.size()):
		var lbl = Label.new()
		lbl.text = headers[i]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.position = Vector2(col_x[i], 65)
		add_child(lbl)

	var company: Dictionary = gm.get_player_company()

	for i in range(company["products"].size()):
		var prod: Dictionary = company["products"][i]
		var y: float = 100 + i * 42

		var row_bg = ColorRect.new()
		row_bg.color = Color(0.97, 0.97, 0.97) if i % 2 == 0 else Color.WHITE
		row_bg.position = Vector2(10, y - 5)
		row_bg.size = Vector2(920, 38)
		add_child(row_bg)

		# Name
		var name_lbl = Label.new()
		name_lbl.text = prod["name"]
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color.BLACK)
		name_lbl.position = Vector2(col_x[0], y)
		add_child(name_lbl)

		# Segment
		var seg_lbl = Label.new()
		seg_lbl.text = prod["segment"]
		seg_lbl.add_theme_font_size_override("font_size", 12)
		seg_lbl.add_theme_color_override("font_color", LABEL_COLOR)
		seg_lbl.position = Vector2(col_x[1], y)
		add_child(seg_lbl)

		# Production schedule
		var sched_spin = SpinBox.new()
		sched_spin.min_value = 0
		sched_spin.max_value = 9999
		sched_spin.step = 50
		sched_spin.value = prod["production_schedule"]
		sched_spin.custom_minimum_size = Vector2(110, 30)
		sched_spin.position = Vector2(col_x[2], y - 4)
		sched_spin.value_changed.connect(_on_schedule_changed.bind(i))
		add_child(sched_spin)

		# 1st shift capacity (read-only)
		var cap_lbl = Label.new()
		cap_lbl.text = "%d" % prod["capacity"]
		cap_lbl.add_theme_font_size_override("font_size", 12)
		cap_lbl.position = Vector2(col_x[3], y)
		add_child(cap_lbl)

		# 2nd shift (overtime)
		var overtime: int = max(0, prod["production_schedule"] - prod["capacity"])
		var ot_lbl = Label.new()
		ot_lbl.text = "%d" % overtime
		ot_lbl.add_theme_font_size_override("font_size", 12)
		ot_lbl.add_theme_color_override("font_color", Color(0.8, 0.2, 0.0) if overtime > 0 else LABEL_COLOR)
		ot_lbl.position = Vector2(col_x[4], y)
		add_child(ot_lbl)

		# Automation
		var auto_spin = SpinBox.new()
		auto_spin.min_value = 1.0
		auto_spin.max_value = 10.0
		auto_spin.step = 0.5
		auto_spin.value = prod["automation"]
		auto_spin.custom_minimum_size = Vector2(90, 30)
		auto_spin.position = Vector2(col_x[5], y - 4)
		auto_spin.value_changed.connect(_on_automation_changed.bind(i))
		add_child(auto_spin)

		# Inventory
		var inv_lbl = Label.new()
		inv_lbl.text = "%d" % prod["inventory"]
		inv_lbl.add_theme_font_size_override("font_size", 12)
		inv_lbl.position = Vector2(col_x[6], y)
		add_child(inv_lbl)

		# Labor cost
		var labor_lbl = Label.new()
		labor_lbl.text = "$%.2f" % prod["labor_cost"]
		labor_lbl.add_theme_font_size_override("font_size", 12)
		labor_lbl.position = Vector2(col_x[7], y)
		add_child(labor_lbl)

		product_rows.append({
			"sched_spin": sched_spin, "auto_spin": auto_spin,
			"cap_lbl": cap_lbl, "ot_lbl": ot_lbl, "inv_lbl": inv_lbl, "labor_lbl": labor_lbl
		})

	# Capacity info
	var info_y: float = 280
	var info = Label.new()
	info.text = "Note: Production beyond 1st shift capacity uses overtime (2nd shift) at higher labor cost.\nBuying automation reduces labor cost per unit but requires capital investment."
	info.add_theme_font_size_override("font_size", 12)
	info.add_theme_color_override("font_color", LABEL_COLOR)
	info.position = Vector2(20, info_y)
	add_child(info)

func _on_schedule_changed(value: float, idx: int) -> void:
	var gm = _get_game_manager()
	if gm:
		gm.get_player_company()["products"][idx]["production_schedule"] = int(value)

func _on_automation_changed(value: float, idx: int) -> void:
	var gm = _get_game_manager()
	if gm:
		gm.get_player_company()["products"][idx]["automation"] = value

func refresh() -> void:
	for child in get_children():
		child.queue_free()
	product_rows.clear()
	_build_ui()

func _get_game_manager():
	var root = get_tree().root if get_tree() else null
	if root == null:
		return null
	for child in root.get_children():
		if child.name == "GameManager":
			return child
	return null
