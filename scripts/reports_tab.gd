extends Control
## res://scripts/reports_tab.gd
## Reports — income statement, balance sheet, cash flow, market share, segment analysis.

const HEADER_COLOR = Color(0.102, 0.137, 0.494)
const LABEL_COLOR = Color(0.3, 0.3, 0.3)
const SUB_HEADER_COLOR = Color(0.15, 0.2, 0.55)

var current_report: String = "income"

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	# Report selector buttons
	var btn_y: float = 10.0
	var btn_x: float = 20.0
	var btn_names = ["Income Statement", "Balance Sheet", "Cash Flow", "Market Share", "Segment Analysis", "Scoreboard"]
	var btn_keys = ["income", "balance", "cashflow", "market", "segments", "scoreboard"]

	for i in range(btn_names.size()):
		var btn = Button.new()
		btn.text = btn_names[i]
		btn.custom_minimum_size = Vector2(130, 28)
		btn.position = Vector2(btn_x, btn_y)
		btn.pressed.connect(_on_report_selected.bind(btn_keys[i]))
		if btn_keys[i] == current_report:
			btn.add_theme_color_override("font_color", Color.WHITE)
			btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		add_child(btn)
		btn_x += 140

	var content_y: float = 50.0
	var gm = _get_game_manager()
	if gm == null:
		return
	var co: Dictionary = gm.get_player_company()

	match current_report:
		"income":
			_build_income_statement(co, content_y)
		"balance":
			_build_balance_sheet(co, content_y)
		"cashflow":
			_build_cash_flow(co, content_y)
		"market":
			_build_market_share(gm, content_y)
		"segments":
			_build_segment_analysis(gm, content_y)
		"scoreboard":
			_build_scoreboard(gm, content_y)

func _build_income_statement(co: Dictionary, start_y: float) -> void:
	var y: float = start_y
	_add_report_header("Income Statement — " + co["name"] + " — Round " + str(_get_game_manager().current_round), 20, y)
	y += 36

	var items = [
		["Revenue", "$%.2fM" % co["total_revenue"]],
		["Cost of Goods Sold", "($%.2fM)" % co["total_cogs"]],
		["", ""],
		["Gross Margin", "$%.2fM" % (co["total_revenue"] - co["total_cogs"])],
		["", ""],
		["SG&A (Promo + Sales)", "($%.2fM)" % co["sga"]],
		["Depreciation", "($%.2fM)" % co["total_depreciation"]],
		["", ""],
		["EBIT", "$%.2fM" % co["ebit"]],
		["", ""],
		["Interest (Short-term)", "($%.2fM)" % co["interest_short"]],
		["Interest (Long-term)", "($%.2fM)" % co["interest_long"]],
		["", ""],
		["Earnings Before Tax", "$%.2fM" % (co["ebit"] - co["interest_short"] - co["interest_long"])],
		["Taxes (35%)", "($%.2fM)" % max(0, (co["ebit"] - co["interest_short"] - co["interest_long"]) * 0.35)],
		["", ""],
		["Net Profit", "$%.2fM" % co["net_profit"]],
	]

	for item in items:
		if item[0] == "":
			y += 6
			var line = ColorRect.new()
			line.color = Color(0.8, 0.8, 0.8)
			line.position = Vector2(20, y)
			line.size = Vector2(500, 1)
			add_child(line)
			y += 6
		else:
			var is_total: bool = item[0] in ["Gross Margin", "EBIT", "Net Profit", "Earnings Before Tax"]
			_add_financial_row(item[0], item[1], 30, y, is_total)
			y += 22

	# Per-product revenue breakdown
	y += 20
	_add_report_header("Revenue by Product", 20, y)
	y += 34
	for prod in co["products"]:
		_add_financial_row(prod["name"] + " (%d units @ $%.2f)" % [prod["units_sold"], prod["price"]], "$%.2fM" % prod["revenue"], 30, y, false)
		y += 22

func _build_balance_sheet(co: Dictionary, start_y: float) -> void:
	var y: float = start_y
	_add_report_header("Balance Sheet — " + co["name"], 20, y)
	y += 36

	_add_sub_header("Assets", 20, y)
	y += 28
	_add_financial_row("Cash", "$%.2fM" % co["cash"], 30, y, false)
	y += 22
	_add_financial_row("Accounts Receivable", "$%.2fM" % co["accounts_receivable"], 30, y, false)
	y += 22
	_add_financial_row("Inventory", "$%.2fM" % co["inventory_value"], 30, y, false)
	y += 22
	_add_financial_row("Plant & Equipment", "$%.2fM" % co["plant_value"], 30, y, false)
	y += 22
	_add_financial_row("Less: Accum. Depreciation", "($%.2fM)" % co["accumulated_depreciation"], 30, y, false)
	y += 28
	_add_financial_row("Total Assets", "$%.2fM" % co["total_assets"], 30, y, true)
	y += 36

	_add_sub_header("Liabilities & Equity", 20, y)
	y += 28
	_add_financial_row("Short-term Debt", "$%.2fM" % co["short_term_debt"], 30, y, false)
	y += 22
	_add_financial_row("Long-term Debt", "$%.2fM" % co["long_term_debt"], 30, y, false)
	y += 28
	var total_liab: float = co["short_term_debt"] + co["long_term_debt"]
	_add_financial_row("Total Liabilities", "$%.2fM" % total_liab, 30, y, true)
	y += 28
	_add_financial_row("Common Stock", "$%.2fM" % co["stock_issued"], 30, y, false)
	y += 22
	_add_financial_row("Retained Earnings", "$%.2fM" % co["retained_earnings"], 30, y, false)
	y += 28
	_add_financial_row("Total Equity", "$%.2fM" % co["equity"], 30, y, true)
	y += 28
	_add_financial_row("Total Liab. & Equity", "$%.2fM" % (total_liab + co["equity"]), 30, y, true)

func _build_cash_flow(co: Dictionary, start_y: float) -> void:
	var y: float = start_y
	_add_report_header("Cash Flow Statement — " + co["name"], 20, y)
	y += 36

	_add_sub_header("Operations", 20, y)
	y += 28
	_add_financial_row("Net Profit", "$%.2fM" % co["net_profit"], 30, y, false)
	y += 22
	_add_financial_row("Add: Depreciation", "$%.2fM" % co["total_depreciation"], 30, y, false)
	y += 28

	_add_sub_header("Financing", 20, y)
	y += 28
	_add_financial_row("Stock Issued", "$%.2fM" % co["stock_to_issue"], 30, y, false)
	y += 22
	_add_financial_row("Bonds Issued", "$%.2fM" % co["bonds_to_issue"], 30, y, false)
	y += 22
	_add_financial_row("Dividends Paid", "($%.2fM)" % co["dividends"], 30, y, false)
	y += 22
	if co["emergency_loan"] > 0:
		_add_financial_row("Emergency Loan", "$%.2fM" % co["emergency_loan"], 30, y, false)
		y += 22
	y += 10
	_add_financial_row("Cash Position", "$%.2fM" % co["cash"], 30, y, true)

func _build_market_share(gm, start_y: float) -> void:
	var y: float = start_y
	_add_report_header("Market Share — Round " + str(gm.current_round), 20, y)
	y += 36

	var chart_script = load("res://scripts/bar_chart.gd")
	var chart = Control.new()
	chart.set_script(chart_script)
	chart.position = Vector2(20, y)
	chart.size = Vector2(600, 280)
	add_child(chart)

	var names: Array = []
	var shares: Array = []
	for co in gm.companies:
		names.append(co["name"])
		shares.append(co["market_share"])
	chart.max_value_override = 100.0
	chart.set_chart_data("Market Share (%)", names, shares, "%")

	# Revenue chart
	var rev_chart = Control.new()
	rev_chart.set_script(chart_script)
	rev_chart.position = Vector2(640, y)
	rev_chart.size = Vector2(400, 280)
	add_child(rev_chart)

	var revenues: Array = []
	for co in gm.companies:
		revenues.append(co["total_revenue"])
	rev_chart.set_chart_data("Revenue ($M)", names, revenues, "M")

func _build_segment_analysis(gm, start_y: float) -> void:
	var y: float = start_y
	_add_report_header("Segment Analysis — Round " + str(gm.current_round), 20, y)
	y += 36

	var SimEngine = load("res://scripts/simulation_engine.gd")
	for seg_name in SimEngine.SEGMENT_ORDER:
		var seg: Dictionary = SimEngine.SEGMENTS[seg_name]
		var ideal = gm.get_segment_ideal(seg_name)

		_add_sub_header(seg_name, 20, y)
		y += 28
		_add_financial_row("Ideal Position", "Pfmn: %.1f  Size: %.1f" % [ideal["performance"], ideal["size"]], 30, y, false)
		y += 20
		_add_financial_row("Price Range", "$%.0f - $%.0f" % [seg["price_min"], seg["price_max"]], 30, y, false)
		y += 20
		_add_financial_row("MTBF Range", "%d - %d" % [seg["mtbf_min"], seg["mtbf_max"]], 30, y, false)
		y += 20
		_add_financial_row("Growth Rate", "%.1f%%" % (seg["growth_rate"] * 100), 30, y, false)
		y += 26

func _build_scoreboard(gm, start_y: float) -> void:
	var y: float = start_y
	_add_report_header("Competitive Scoreboard — Round " + str(gm.current_round), 20, y)
	y += 36

	# Header
	var headers = ["Rank", "Company", "Cum. Profit", "Revenue", "Mkt Share", "Stock Price", "ROA"]
	var col_x = [20, 70, 200, 340, 460, 570, 680]

	var hdr_bg = ColorRect.new()
	hdr_bg.color = HEADER_COLOR
	hdr_bg.position = Vector2(10, y)
	hdr_bg.size = Vector2(780, 28)
	add_child(hdr_bg)

	for i in range(headers.size()):
		var lbl = Label.new()
		lbl.text = headers[i]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.position = Vector2(col_x[i], y + 5)
		add_child(lbl)
	y += 32

	var rankings = gm.get_rankings()
	for r in range(rankings.size()):
		var rank: Dictionary = rankings[r]
		var row_bg = ColorRect.new()
		row_bg.color = Color(0.97, 0.97, 0.97) if r % 2 == 0 else Color.WHITE
		if rank["name"] == gm.get_player_company()["name"]:
			row_bg.color = Color(0.85, 0.9, 1.0)
		row_bg.position = Vector2(10, y - 2)
		row_bg.size = Vector2(780, 28)
		add_child(row_bg)

		var vals = [
			str(r + 1),
			rank["name"],
			"$%.2fM" % rank["cumulative_profit"],
			"$%.2fM" % rank["revenue"],
			"%.1f%%" % rank["market_share"],
			"$%.2f" % rank["stock_price"],
			"%.1f%%" % rank["roa"],
		]
		for c in range(vals.size()):
			var lbl = Label.new()
			lbl.text = vals[c]
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.add_theme_color_override("font_color", Color.BLACK)
			lbl.position = Vector2(col_x[c], y)
			add_child(lbl)
		y += 28

func _add_report_header(text: String, x: float, y: float) -> void:
	var bg = ColorRect.new()
	bg.color = HEADER_COLOR
	bg.position = Vector2(x - 10, y)
	bg.size = Vector2(1000, 30)
	add_child(bg)
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.position = Vector2(x, y + 5)
	add_child(lbl)

func _add_sub_header(text: String, x: float, y: float) -> void:
	var bg = ColorRect.new()
	bg.color = SUB_HEADER_COLOR
	bg.position = Vector2(x - 5, y)
	bg.size = Vector2(500, 24)
	add_child(bg)
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.position = Vector2(x, y + 3)
	add_child(lbl)

func _add_financial_row(label_text: String, value_text: String, x: float, y: float, is_bold: bool) -> void:
	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 13 if is_bold else 12)
	lbl.add_theme_color_override("font_color", Color.BLACK if is_bold else LABEL_COLOR)
	lbl.position = Vector2(x, y)
	add_child(lbl)
	var val = Label.new()
	val.text = value_text
	val.add_theme_font_size_override("font_size", 13 if is_bold else 12)
	val.add_theme_color_override("font_color", Color.BLACK)
	val.position = Vector2(x + 300, y)
	add_child(val)

func _on_report_selected(report_key: String) -> void:
	current_report = report_key
	refresh()

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
