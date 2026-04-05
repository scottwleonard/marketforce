extends Control
## res://scripts/finance_tab.gd
## Finance department — stock, bonds, dividends, debt overview.

const HEADER_COLOR = Color(0.102, 0.137, 0.494)
const LABEL_COLOR = Color(0.3, 0.3, 0.3)

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var title = Label.new()
	title.text = "Finance"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", HEADER_COLOR)
	title.position = Vector2(20, 10)
	add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Manage your company's capital structure through stock, bonds, and dividend decisions."
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", LABEL_COLOR)
	subtitle.position = Vector2(20, 36)
	add_child(subtitle)

	var gm = _get_game_manager()
	if gm == null:
		return
	var co: Dictionary = gm.get_player_company()

	# Current financial position (left column)
	var section_x: float = 20.0
	var section_y: float = 70.0
	_add_section_header("Current Position", section_x, section_y)
	section_y += 30
	_add_info_row("Cash on Hand:", "$%.1fM" % co["cash"], section_x, section_y)
	section_y += 22
	_add_info_row("Stock Price:", "$%.2f" % co["stock_price"], section_x, section_y)
	section_y += 22
	_add_info_row("Market Cap:", "$%.1fM" % co["market_cap"], section_x, section_y)
	section_y += 22
	_add_info_row("Total Equity:", "$%.1fM" % co["equity"], section_x, section_y)
	section_y += 22
	_add_info_row("Long-term Debt:", "$%.1fM" % co["long_term_debt"], section_x, section_y)
	section_y += 22
	_add_info_row("Short-term Debt:", "$%.1fM" % co["short_term_debt"], section_x, section_y)
	section_y += 22
	if co["emergency_loan"] > 0:
		_add_info_row("Emergency Loan:", "$%.1fM" % co["emergency_loan"], section_x, section_y, Color(0.8, 0.0, 0.0))
		section_y += 22

	# Stock decisions (middle column)
	var stock_x: float = 350.0
	var stock_y: float = 70.0
	_add_section_header("Stock", stock_x, stock_y)
	stock_y += 34

	var issue_lbl = Label.new()
	issue_lbl.text = "Issue Stock ($M):"
	issue_lbl.add_theme_font_size_override("font_size", 13)
	issue_lbl.position = Vector2(stock_x, stock_y)
	add_child(issue_lbl)

	var issue_spin = SpinBox.new()
	issue_spin.min_value = 0.0
	issue_spin.max_value = 50.0
	issue_spin.step = 1.0
	issue_spin.value = co["stock_to_issue"]
	issue_spin.custom_minimum_size = Vector2(120, 30)
	issue_spin.position = Vector2(stock_x + 150, stock_y - 4)
	issue_spin.value_changed.connect(func(v): co["stock_to_issue"] = v)
	add_child(issue_spin)
	stock_y += 38

	var retire_lbl = Label.new()
	retire_lbl.text = "Retire Stock ($M):"
	retire_lbl.add_theme_font_size_override("font_size", 13)
	retire_lbl.position = Vector2(stock_x, stock_y)
	add_child(retire_lbl)

	var retire_spin = SpinBox.new()
	retire_spin.min_value = 0.0
	retire_spin.max_value = 50.0
	retire_spin.step = 1.0
	retire_spin.value = co["stock_to_retire"]
	retire_spin.custom_minimum_size = Vector2(120, 30)
	retire_spin.position = Vector2(stock_x + 150, stock_y - 4)
	retire_spin.value_changed.connect(func(v): co["stock_to_retire"] = v)
	add_child(retire_spin)
	stock_y += 50

	# Bond decisions
	_add_section_header("Bonds", stock_x, stock_y)
	stock_y += 34

	var bond_issue_lbl = Label.new()
	bond_issue_lbl.text = "Issue Bonds ($M):"
	bond_issue_lbl.add_theme_font_size_override("font_size", 13)
	bond_issue_lbl.position = Vector2(stock_x, stock_y)
	add_child(bond_issue_lbl)

	var bond_issue_spin = SpinBox.new()
	bond_issue_spin.min_value = 0.0
	bond_issue_spin.max_value = 100.0
	bond_issue_spin.step = 1.0
	bond_issue_spin.value = co["bonds_to_issue"]
	bond_issue_spin.custom_minimum_size = Vector2(120, 30)
	bond_issue_spin.position = Vector2(stock_x + 150, stock_y - 4)
	bond_issue_spin.value_changed.connect(func(v): co["bonds_to_issue"] = v)
	add_child(bond_issue_spin)
	stock_y += 38

	var bond_retire_lbl = Label.new()
	bond_retire_lbl.text = "Retire Bonds ($M):"
	bond_retire_lbl.add_theme_font_size_override("font_size", 13)
	bond_retire_lbl.position = Vector2(stock_x, stock_y)
	add_child(bond_retire_lbl)

	var bond_retire_spin = SpinBox.new()
	bond_retire_spin.min_value = 0.0
	bond_retire_spin.max_value = 100.0
	bond_retire_spin.step = 1.0
	bond_retire_spin.value = co["bonds_to_retire"]
	bond_retire_spin.custom_minimum_size = Vector2(120, 30)
	bond_retire_spin.position = Vector2(stock_x + 150, stock_y - 4)
	bond_retire_spin.value_changed.connect(func(v): co["bonds_to_retire"] = v)
	add_child(bond_retire_spin)
	stock_y += 50

	# Dividends
	_add_section_header("Dividends", stock_x, stock_y)
	stock_y += 34

	var div_lbl = Label.new()
	div_lbl.text = "Dividend/Share ($):"
	div_lbl.add_theme_font_size_override("font_size", 13)
	div_lbl.position = Vector2(stock_x, stock_y)
	add_child(div_lbl)

	var div_spin = SpinBox.new()
	div_spin.min_value = 0.0
	div_spin.max_value = 10.0
	div_spin.step = 0.5
	div_spin.value = co["dividends"]
	div_spin.custom_minimum_size = Vector2(120, 30)
	div_spin.position = Vector2(stock_x + 150, stock_y - 4)
	div_spin.value_changed.connect(func(v): co["dividends"] = v)
	add_child(div_spin)

	# Interest rates info (right column)
	var info_x: float = 700.0
	var info_y: float = 70.0
	_add_section_header("Interest Rates", info_x, info_y)
	info_y += 30
	_add_info_row("Short-term:", "10.0%", info_x, info_y)
	info_y += 22
	_add_info_row("Long-term:", "6.5%", info_x, info_y)
	info_y += 22
	_add_info_row("Tax Rate:", "35.0%", info_x, info_y)
	info_y += 40
	_add_section_header("Interest Expense", info_x, info_y)
	info_y += 30
	_add_info_row("Short-term:", "$%.2fM" % co["interest_short"], info_x, info_y)
	info_y += 22
	_add_info_row("Long-term:", "$%.2fM" % co["interest_long"], info_x, info_y)

func _add_section_header(text: String, x: float, y: float) -> void:
	var bg = ColorRect.new()
	bg.color = HEADER_COLOR
	bg.position = Vector2(x - 5, y)
	bg.size = Vector2(280, 26)
	add_child(bg)
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.position = Vector2(x, y + 3)
	add_child(lbl)

func _add_info_row(label_text: String, value_text: String, x: float, y: float, color: Color = Color.BLACK) -> void:
	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", LABEL_COLOR)
	lbl.position = Vector2(x, y)
	add_child(lbl)
	var val = Label.new()
	val.text = value_text
	val.add_theme_font_size_override("font_size", 12)
	val.add_theme_color_override("font_color", color)
	val.position = Vector2(x + 150, y)
	add_child(val)

func refresh() -> void:
	for child in get_children():
		child.queue_free()
	_build_ui()

func _get_game_manager():
	var root = get_tree().root if get_tree() else null
	if root == null:
		return null
	for child in root.get_children():
		if child.name == "GameManager":
			return child
	return null
