extends Control
## res://scripts/game_screen_controller.gd
## Manages tab navigation, header, round flow, submit button.

const HEADER_COLOR = Color(0.102, 0.137, 0.494)
const HEADER_HEIGHT = 50.0
const TAB_BAR_HEIGHT = 36.0
const STATUS_BAR_HEIGHT = 32.0

var tab_container: TabContainer
var header_company_label: Label
var header_round_label: Label
var status_label: Label
var submit_btn: Button
var results_popup: Panel
var results_label: Label
var tab_scripts: Array = []

func _ready() -> void:
	_build_ui()
	var gm = _get_game_manager()
	if gm:
		gm.round_completed.connect(_on_round_completed)
		gm.game_ended.connect(_on_game_ended)
		gm.game_started.connect(_on_game_started)

func _on_game_started() -> void:
	_update_header()
	for tab in tab_scripts:
		if tab.has_method("refresh"):
			tab.refresh()

func _build_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT

	# Header bar
	var header = ColorRect.new()
	header.color = HEADER_COLOR
	header.position = Vector2(0, 0)
	header.size = Vector2(1280, HEADER_HEIGHT)
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = HEADER_HEIGHT
	add_child(header)

	# Logo / title
	var logo = Label.new()
	logo.text = "MARKETFORCE"
	logo.add_theme_font_size_override("font_size", 22)
	logo.add_theme_color_override("font_color", Color.WHITE)
	logo.position = Vector2(20, 10)
	add_child(logo)

	var sim_label = Label.new()
	sim_label.text = "Business Simulation"
	sim_label.add_theme_font_size_override("font_size", 11)
	sim_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
	sim_label.position = Vector2(105, 18)
	add_child(sim_label)

	# Company name
	header_company_label = Label.new()
	header_company_label.add_theme_font_size_override("font_size", 14)
	header_company_label.add_theme_color_override("font_color", Color.WHITE)
	header_company_label.position = Vector2(400, 14)
	add_child(header_company_label)

	# Round indicator
	header_round_label = Label.new()
	header_round_label.add_theme_font_size_override("font_size", 14)
	header_round_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.3))
	header_round_label.position = Vector2(700, 14)
	add_child(header_round_label)

	# Submit button in header
	submit_btn = Button.new()
	submit_btn.text = "  Submit Decisions  "
	submit_btn.custom_minimum_size = Vector2(160, 34)
	submit_btn.position = Vector2(1080, 8)
	submit_btn.pressed.connect(_on_submit_pressed)
	add_child(submit_btn)

	# Tab container
	tab_container = TabContainer.new()
	tab_container.position = Vector2(0, HEADER_HEIGHT)
	tab_container.size = Vector2(1280, 720 - HEADER_HEIGHT - STATUS_BAR_HEIGHT)
	tab_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	tab_container.offset_top = HEADER_HEIGHT
	tab_container.offset_bottom = -STATUS_BAR_HEIGHT
	add_child(tab_container)

	# Create tabs
	var rd_tab = Control.new()
	rd_tab.name = "R&D"
	rd_tab.set_script(load("res://scripts/rd_tab.gd"))
	tab_container.add_child(rd_tab)

	var mkt_tab = Control.new()
	mkt_tab.name = "Marketing"
	mkt_tab.set_script(load("res://scripts/marketing_tab.gd"))
	tab_container.add_child(mkt_tab)

	var prod_tab = Control.new()
	prod_tab.name = "Production"
	prod_tab.set_script(load("res://scripts/production_tab.gd"))
	tab_container.add_child(prod_tab)

	var fin_tab = Control.new()
	fin_tab.name = "Finance"
	fin_tab.set_script(load("res://scripts/finance_tab.gd"))
	tab_container.add_child(fin_tab)

	var reports_tab = Control.new()
	reports_tab.name = "Reports"
	reports_tab.set_script(load("res://scripts/reports_tab.gd"))
	tab_container.add_child(reports_tab)

	tab_scripts = [rd_tab, mkt_tab, prod_tab, fin_tab, reports_tab]

	# Status bar
	var status_bg = ColorRect.new()
	status_bg.color = Color(0.15, 0.15, 0.2)
	status_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	status_bg.offset_top = -STATUS_BAR_HEIGHT
	add_child(status_bg)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	status_label.offset_top = -STATUS_BAR_HEIGHT + 8
	status_label.offset_left = 20
	add_child(status_label)

	# Results popup (hidden)
	results_popup = Panel.new()
	results_popup.position = Vector2(240, 120)
	results_popup.size = Vector2(800, 480)
	results_popup.visible = false
	add_child(results_popup)

	var popup_bg = ColorRect.new()
	popup_bg.color = Color.WHITE
	popup_bg.position = Vector2(0, 0)
	popup_bg.size = Vector2(800, 480)
	results_popup.add_child(popup_bg)

	var popup_header = ColorRect.new()
	popup_header.color = HEADER_COLOR
	popup_header.position = Vector2(0, 0)
	popup_header.size = Vector2(800, 40)
	results_popup.add_child(popup_header)

	var popup_title = Label.new()
	popup_title.text = "Round Results"
	popup_title.add_theme_font_size_override("font_size", 16)
	popup_title.add_theme_color_override("font_color", Color.WHITE)
	popup_title.position = Vector2(20, 8)
	results_popup.add_child(popup_title)

	results_label = Label.new()
	results_label.position = Vector2(20, 50)
	results_label.size = Vector2(760, 370)
	results_label.add_theme_font_size_override("font_size", 13)
	results_label.add_theme_color_override("font_color", Color.BLACK)
	results_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	results_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	results_popup.add_child(results_label)

	var close_btn = Button.new()
	close_btn.text = "Continue"
	close_btn.custom_minimum_size = Vector2(120, 36)
	close_btn.position = Vector2(340, 435)
	close_btn.pressed.connect(_on_close_results)
	results_popup.add_child(close_btn)

	_update_header()

func _update_header() -> void:
	var gm = _get_game_manager()
	if gm == null or gm.companies.is_empty():
		return
	var co: Dictionary = gm.get_player_company()
	header_company_label.text = "Company: " + co["name"]
	header_round_label.text = "Round %d of %d" % [gm.current_round, gm.max_rounds]
	status_label.text = "Cash: $%.1fM  |  Revenue: $%.1fM  |  Net Profit: $%.1fM  |  Market Share: %.1f%%  |  Stock: $%.2f" % [
		co["cash"], co["total_revenue"], co["net_profit"], co["market_share"], co["stock_price"]
	]

func _on_submit_pressed() -> void:
	var gm = _get_game_manager()
	if gm and gm.game_active:
		gm.submit_decisions()

func _on_round_completed(round_num: int) -> void:
	_update_header()
	_show_results(round_num)

func _on_game_ended() -> void:
	_update_header()
	submit_btn.text = "  Game Over  "
	submit_btn.disabled = true
	_show_final_results()

func _show_results(round_num: int) -> void:
	var gm = _get_game_manager()
	var co: Dictionary = gm.get_player_company()
	var rankings = gm.get_rankings()

	var text: String = "Round %d Complete!\n\n" % round_num
	text += "Your Results (%s):\n" % co["name"]
	text += "  Revenue: $%.2fM\n" % co["total_revenue"]
	text += "  Net Profit: $%.2fM\n" % co["net_profit"]
	text += "  Market Share: %.1f%%\n" % co["market_share"]
	text += "  Stock Price: $%.2f\n\n" % co["stock_price"]
	text += "Rankings:\n"

	for i in range(rankings.size()):
		var r: Dictionary = rankings[i]
		var marker: String = " <<<" if r["name"] == co["name"] else ""
		text += "  %d. %s — Profit: $%.2fM, Share: %.1f%%%s\n" % [i + 1, r["name"], r["cumulative_profit"], r["market_share"], marker]

	results_label.text = text
	results_popup.visible = true

func _show_final_results() -> void:
	var gm = _get_game_manager()
	var rankings = gm.get_rankings()
	var co: Dictionary = gm.get_player_company()

	var text: String = "FINAL RESULTS — Game Over!\n\n"
	var player_rank: int = 0
	for i in range(rankings.size()):
		if rankings[i]["name"] == co["name"]:
			player_rank = i + 1

	text += "You finished #%d out of %d companies!\n\n" % [player_rank, rankings.size()]
	text += "Final Rankings:\n"
	for i in range(rankings.size()):
		var r: Dictionary = rankings[i]
		var marker: String = " <<<" if r["name"] == co["name"] else ""
		text += "  %d. %s — Cum. Profit: $%.2fM, Stock: $%.2f%s\n" % [i + 1, r["name"], r["cumulative_profit"], r["stock_price"], marker]

	results_label.text = text
	results_popup.visible = true

func _on_close_results() -> void:
	results_popup.visible = false
	# Refresh all tabs
	for tab in tab_scripts:
		if tab.has_method("refresh"):
			tab.refresh()

func _get_game_manager():
	var root = get_tree().root if get_tree() else null
	if root == null:
		return null
	for child in root.get_children():
		if child.name == "GameManager":
			return child
	return null
