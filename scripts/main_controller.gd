extends Control
## res://scripts/main_controller.gd
## Main scene controller — title screen and game flow.

const HEADER_COLOR = Color(0.102, 0.137, 0.494)
const ACCENT_COLOR = Color(0.2, 0.4, 0.8)

var title_screen: Control
var game_screen: Control
var name_input: LineEdit

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_build_title_screen()

func _build_title_screen() -> void:
	title_screen = Control.new()
	title_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(title_screen)

	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.95, 0.96, 0.98)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_screen.add_child(bg)

	# Header
	var header = ColorRect.new()
	header.color = HEADER_COLOR
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 120
	title_screen.add_child(header)

	# Title
	var title = Label.new()
	title.text = "MARKETFORCE"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 20
	title.offset_bottom = 80
	title_screen.add_child(title)

	var tagline = Label.new()
	tagline.text = "Business Strategy Simulation"
	tagline.add_theme_font_size_override("font_size", 16)
	tagline.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tagline.offset_top = 78
	tagline.offset_bottom = 110
	title_screen.add_child(tagline)

	# Center panel
	var panel = PanelContainer.new()
	panel.position = Vector2(390, 180)
	panel.custom_minimum_size = Vector2(500, 380)
	title_screen.add_child(panel)

	var panel_bg = ColorRect.new()
	panel_bg.color = Color.WHITE
	panel_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(panel_bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 40
	vbox.offset_right = -40
	vbox.offset_top = 30
	vbox.offset_bottom = -30
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var new_game_label = Label.new()
	new_game_label.text = "New Simulation"
	new_game_label.add_theme_font_size_override("font_size", 22)
	new_game_label.add_theme_color_override("font_color", HEADER_COLOR)
	new_game_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(new_game_label)

	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Company name
	var name_label = Label.new()
	name_label.text = "Company Name:"
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	vbox.add_child(name_label)

	name_input = LineEdit.new()
	name_input.text = "Andrews"
	name_input.custom_minimum_size = Vector2(0, 36)
	name_input.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_input)

	# Info
	var info_label = Label.new()
	info_label.text = "8-round competitive simulation\n6 companies (you + 5 AI competitors)\n4 products per company\n5 market segments"
	info_label.add_theme_font_size_override("font_size", 12)
	info_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(info_label)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Start button
	var start_btn = Button.new()
	start_btn.text = "Start Simulation"
	start_btn.custom_minimum_size = Vector2(0, 44)
	start_btn.add_theme_font_size_override("font_size", 16)
	start_btn.pressed.connect(_on_start_pressed)
	vbox.add_child(start_btn)

	# Footer
	var footer = Label.new()
	footer.text = "Compete against AI-managed companies across R&D, Marketing, Production, and Finance."
	footer.add_theme_font_size_override("font_size", 11)
	footer.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -40
	title_screen.add_child(footer)

func _on_start_pressed() -> void:
	var company_name: String = name_input.text.strip_edges()
	if company_name.is_empty():
		company_name = "Andrews"

	# Hide title screen
	title_screen.visible = false

	# Create game screen
	game_screen = Control.new()
	game_screen.set_script(load("res://scripts/game_screen_controller.gd"))
	game_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(game_screen)

	# Start the game
	var gm = _get_game_manager()
	if gm:
		gm.start_new_game(company_name)

func _on_game_ended() -> void:
	pass  # Game over handled by game_screen_controller

func _get_game_manager():
	var root = get_tree().root if get_tree() else null
	if root == null:
		return null
	for child in root.get_children():
		if child.name == "GameManager":
			return child
	return null
