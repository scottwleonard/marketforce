extends Control
## res://scripts/marketing_tab.gd
## Marketing department — price, promotion budget, sales budget per product.

const HEADER_COLOR = Color(0.102, 0.137, 0.494)
const LABEL_COLOR = Color(0.3, 0.3, 0.3)

var product_rows: Array = []

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var title = Label.new()
	title.text = "Marketing"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", HEADER_COLOR)
	title.position = Vector2(20, 10)
	add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Set prices and allocate promotion and sales budgets for each product."
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", LABEL_COLOR)
	subtitle.position = Vector2(20, 36)
	add_child(subtitle)

	var headers = ["Product", "Segment", "Price ($)", "Promo Budget ($M)", "Sales Budget ($M)", "Awareness", "Accessibility", "Units Sold"]
	var col_x = [20, 120, 220, 340, 490, 640, 740, 850]

	var header_bg = ColorRect.new()
	header_bg.color = HEADER_COLOR
	header_bg.position = Vector2(10, 60)
	header_bg.size = Vector2(950, 30)
	add_child(header_bg)

	for i in range(headers.size()):
		var lbl = Label.new()
		lbl.text = headers[i]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.position = Vector2(col_x[i], 65)
		add_child(lbl)

	var gm = _get_game_manager()
	if gm == null:
		return
	var company: Dictionary = gm.get_player_company()

	for i in range(company["products"].size()):
		var prod: Dictionary = company["products"][i]
		var y: float = 100 + i * 42

		var row_bg = ColorRect.new()
		row_bg.color = Color(0.97, 0.97, 0.97) if i % 2 == 0 else Color.WHITE
		row_bg.position = Vector2(10, y - 5)
		row_bg.size = Vector2(950, 38)
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

		# Price
		var price_spin = SpinBox.new()
		price_spin.min_value = 5.0
		price_spin.max_value = 50.0
		price_spin.step = 0.50
		price_spin.value = prod["price"]
		price_spin.custom_minimum_size = Vector2(100, 30)
		price_spin.position = Vector2(col_x[2], y - 4)
		price_spin.value_changed.connect(_on_price_changed.bind(i))
		add_child(price_spin)

		# Promo budget
		var promo_spin = SpinBox.new()
		promo_spin.min_value = 0.0
		promo_spin.max_value = 5.0
		promo_spin.step = 0.1
		promo_spin.value = prod["promo_budget"]
		promo_spin.custom_minimum_size = Vector2(100, 30)
		promo_spin.position = Vector2(col_x[3], y - 4)
		promo_spin.value_changed.connect(_on_promo_changed.bind(i))
		add_child(promo_spin)

		# Sales budget
		var sales_spin = SpinBox.new()
		sales_spin.min_value = 0.0
		sales_spin.max_value = 5.0
		sales_spin.step = 0.1
		sales_spin.value = prod["sales_budget"]
		sales_spin.custom_minimum_size = Vector2(100, 30)
		sales_spin.position = Vector2(col_x[4], y - 4)
		sales_spin.value_changed.connect(_on_sales_changed.bind(i))
		add_child(sales_spin)

		# Awareness (read-only)
		var aware_lbl = Label.new()
		aware_lbl.text = "%.0f%%" % (prod["awareness"] * 100)
		aware_lbl.add_theme_font_size_override("font_size", 12)
		aware_lbl.position = Vector2(col_x[5], y)
		add_child(aware_lbl)

		# Accessibility (read-only)
		var access_lbl = Label.new()
		access_lbl.text = "%.0f%%" % (prod["accessibility"] * 100)
		access_lbl.add_theme_font_size_override("font_size", 12)
		access_lbl.position = Vector2(col_x[6], y)
		add_child(access_lbl)

		# Units sold (read-only)
		var sold_lbl = Label.new()
		sold_lbl.text = "%d" % prod["units_sold"]
		sold_lbl.add_theme_font_size_override("font_size", 12)
		sold_lbl.position = Vector2(col_x[7], y)
		add_child(sold_lbl)

		product_rows.append({
			"price_spin": price_spin, "promo_spin": promo_spin, "sales_spin": sales_spin,
			"aware_lbl": aware_lbl, "access_lbl": access_lbl, "sold_lbl": sold_lbl
		})

	# Segment price ranges info
	var info_y: float = 280
	var info_title = Label.new()
	info_title.text = "Segment Price Ranges"
	info_title.add_theme_font_size_override("font_size", 14)
	info_title.add_theme_color_override("font_color", HEADER_COLOR)
	info_title.position = Vector2(20, info_y)
	add_child(info_title)

	var SimEngine = load("res://scripts/simulation_engine.gd")
	var seg_y: float = info_y + 24
	for seg_name in SimEngine.SEGMENT_ORDER:
		var seg: Dictionary = SimEngine.SEGMENTS[seg_name]
		var lbl = Label.new()
		lbl.text = "%s: $%.0f - $%.0f" % [seg_name, seg["price_min"], seg["price_max"]]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", LABEL_COLOR)
		lbl.position = Vector2(30, seg_y)
		add_child(lbl)
		seg_y += 20

func _on_price_changed(value: float, idx: int) -> void:
	var gm = _get_game_manager()
	if gm:
		gm.get_player_company()["products"][idx]["price"] = value

func _on_promo_changed(value: float, idx: int) -> void:
	var gm = _get_game_manager()
	if gm:
		gm.get_player_company()["products"][idx]["promo_budget"] = value

func _on_sales_changed(value: float, idx: int) -> void:
	var gm = _get_game_manager()
	if gm:
		gm.get_player_company()["products"][idx]["sales_budget"] = value

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
