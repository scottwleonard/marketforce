extends Control
## res://scripts/rd_tab.gd
## R&D department — product repositioning, MTBF, age display, perceptual map.

const HEADER_COLOR = Color(0.102, 0.137, 0.494)
const LABEL_COLOR = Color(0.3, 0.3, 0.3)

var product_rows: Array = []  # [{name_label, perf_spin, size_spin, mtbf_spin, age_label, cost_label}]

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	# White background
	var bg = ColorRect.new()
	bg.color = Color(0.96, 0.96, 0.97)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Section title
	var title = Label.new()
	title.text = "Research & Development"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", HEADER_COLOR)
	add_child(title)
	title.position = Vector2(20, 10)

	var subtitle = Label.new()
	subtitle.text = "Reposition your products by adjusting performance, size, and reliability specifications."
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", LABEL_COLOR)
	add_child(subtitle)
	subtitle.position = Vector2(20, 36)

	var gm = _get_game_manager()
	if gm == null or gm.companies.is_empty():
		return

	# Table header
	var headers = ["Product", "Segment", "Pfmn", "Size", "MTBF", "Age", "Mat Cost", "Revision"]
	var col_x = [20, 120, 220, 330, 440, 560, 640, 740]
	var header_bg = ColorRect.new()
	header_bg.color = HEADER_COLOR
	header_bg.position = Vector2(10, 60)
	header_bg.size = Vector2(830, 30)
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
		row_bg.size = Vector2(830, 38)
		add_child(row_bg)

		# Product name
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

		# Performance spinner
		var perf_spin = SpinBox.new()
		perf_spin.min_value = 0.0
		perf_spin.max_value = 20.0
		perf_spin.step = 0.1
		perf_spin.value = prod["rd_perf"]
		perf_spin.custom_minimum_size = Vector2(90, 30)
		perf_spin.position = Vector2(col_x[2], y - 4)
		perf_spin.value_changed.connect(_on_perf_changed.bind(i))
		add_child(perf_spin)

		# Size spinner
		var size_spin = SpinBox.new()
		size_spin.min_value = 0.0
		size_spin.max_value = 25.0
		size_spin.step = 0.1
		size_spin.value = prod["rd_size"]
		size_spin.custom_minimum_size = Vector2(90, 30)
		size_spin.position = Vector2(col_x[3], y - 4)
		size_spin.value_changed.connect(_on_size_changed.bind(i))
		add_child(size_spin)

		# MTBF spinner
		var mtbf_spin = SpinBox.new()
		mtbf_spin.min_value = 10000
		mtbf_spin.max_value = 30000
		mtbf_spin.step = 500
		mtbf_spin.value = prod["rd_mtbf"]
		mtbf_spin.custom_minimum_size = Vector2(100, 30)
		mtbf_spin.position = Vector2(col_x[4], y - 4)
		mtbf_spin.value_changed.connect(_on_mtbf_changed.bind(i))
		add_child(mtbf_spin)

		# Age (read-only)
		var age_lbl = Label.new()
		age_lbl.text = "%.1f yr" % prod["age"]
		age_lbl.add_theme_font_size_override("font_size", 12)
		age_lbl.position = Vector2(col_x[5], y)
		add_child(age_lbl)

		# Material cost (read-only)
		var cost_lbl = Label.new()
		cost_lbl.text = "$%.2f" % prod["material_cost"]
		cost_lbl.add_theme_font_size_override("font_size", 12)
		cost_lbl.position = Vector2(col_x[6], y)
		add_child(cost_lbl)

		# Revision status
		var rev_lbl = Label.new()
		var perf_diff: float = abs(prod["rd_perf"] - prod["performance"])
		var size_diff: float = abs(prod["rd_size"] - prod["size"])
		rev_lbl.text = "Revised" if perf_diff > 0.05 or size_diff > 0.05 else "No Change"
		rev_lbl.add_theme_font_size_override("font_size", 12)
		rev_lbl.add_theme_color_override("font_color", Color(0.0, 0.5, 0.0) if rev_lbl.text == "Revised" else LABEL_COLOR)
		rev_lbl.position = Vector2(col_x[7], y)
		add_child(rev_lbl)

		product_rows.append({
			"perf_spin": perf_spin, "size_spin": size_spin, "mtbf_spin": mtbf_spin,
			"age_lbl": age_lbl, "cost_lbl": cost_lbl, "rev_lbl": rev_lbl
		})

	# Perceptual map — positioned to the right of the table
	var map_label = Label.new()
	map_label.text = "Perceptual Map"
	map_label.add_theme_font_size_override("font_size", 14)
	map_label.add_theme_color_override("font_color", HEADER_COLOR)
	map_label.position = Vector2(860, 60)
	add_child(map_label)

	var pmap_script = load("res://scripts/perceptual_map.gd")
	var pmap = Control.new()
	pmap.set_script(pmap_script)
	pmap.position = Vector2(860, 82)
	pmap.size = Vector2(380, 350)
	add_child(pmap)

	# Populate map
	var all_products: Array = []
	for co in gm.companies:
		for prod in co["products"]:
			all_products.append({"name": prod["name"], "performance": prod["performance"], "size": prod["size"]})
	pmap.set_products(all_products)

	var seg_centers: Dictionary = {}
	for seg_name in gm.get_segment_names():
		seg_centers[seg_name] = gm.get_segment_ideal(seg_name)
	pmap.set_segment_centers(seg_centers)

func _on_perf_changed(value: float, product_idx: int) -> void:
	var gm = _get_game_manager()
	if gm:
		gm.get_player_company()["products"][product_idx]["rd_perf"] = value

func _on_size_changed(value: float, product_idx: int) -> void:
	var gm = _get_game_manager()
	if gm:
		gm.get_player_company()["products"][product_idx]["rd_size"] = value

func _on_mtbf_changed(value: float, product_idx: int) -> void:
	var gm = _get_game_manager()
	if gm:
		gm.get_player_company()["products"][product_idx]["rd_mtbf"] = int(value)

func refresh() -> void:
	# Clear and rebuild
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
