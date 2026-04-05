extends SceneTree
## Test harness — captures title screen, game screen with multiple tabs, results popup.

var _frame: int = 0
var _gm = null
var _main = null

func _initialize() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	_main = main_scene.instantiate()
	root.add_child(_main)

func _process(_delta: float) -> bool:
	_frame += 1

	# Find GameManager
	if _gm == null:
		for child in root.get_children():
			if child.name == "GameManager":
				_gm = child
				break

	if _frame == 8:
		print("Frame 8: Title screen captured")

	if _frame == 12:
		# Simulate clicking "Start Simulation" — call the method directly
		if _main.has_method("_on_start_pressed"):
			_main._on_start_pressed()
			print("Frame 12: Game started")

	if _frame == 20:
		# R&D tab visible (default) — capture it
		print("Frame 20: R&D tab visible")

	if _frame == 25:
		# Switch to Marketing tab
		var gs = _find_game_screen()
		if gs and gs.tab_container:
			gs.tab_container.current_tab = 1
			print("Frame 25: Marketing tab")

	if _frame == 30:
		# Switch to Production tab
		var gs = _find_game_screen()
		if gs and gs.tab_container:
			gs.tab_container.current_tab = 2
			print("Frame 30: Production tab")

	if _frame == 35:
		# Switch to Finance tab
		var gs = _find_game_screen()
		if gs and gs.tab_container:
			gs.tab_container.current_tab = 3
			print("Frame 35: Finance tab")

	if _frame == 40:
		# Switch to Reports tab
		var gs = _find_game_screen()
		if gs and gs.tab_container:
			gs.tab_container.current_tab = 4
			print("Frame 40: Reports tab")

	if _frame == 45:
		# Submit decisions — round 1
		if _gm and _gm.game_active:
			_gm.submit_decisions()
			print("Frame 45: Round 1 submitted")

	if _frame == 50:
		# Results popup should be showing — capture it
		print("Frame 50: Results popup")

	if _frame == 55:
		# Close results and show updated R&D
		var gs = _find_game_screen()
		if gs:
			gs._on_close_results()
			gs.tab_container.current_tab = 0
			print("Frame 55: Post-round R&D")

	if _frame == 60:
		# Show reports - scoreboard
		var gs = _find_game_screen()
		if gs and gs.tab_container:
			gs.tab_container.current_tab = 4
			# Switch to scoreboard sub-report
			var reports = gs.tab_container.get_child(4)
			if reports and reports.has_method("_on_report_selected"):
				reports._on_report_selected("scoreboard")
			print("Frame 60: Scoreboard")

	if _frame == 65:
		# Show market share chart
		var gs = _find_game_screen()
		if gs and gs.tab_container:
			var reports = gs.tab_container.get_child(4)
			if reports and reports.has_method("_on_report_selected"):
				reports._on_report_selected("market")
			print("Frame 65: Market share")

	if _frame == 70:
		# Submit round 2
		if _gm and _gm.game_active:
			_gm.submit_decisions()
			print("Frame 70: Round 2 submitted")

	if _frame == 75:
		# Close results
		var gs = _find_game_screen()
		if gs:
			gs._on_close_results()
			# Show income statement
			var reports = gs.tab_container.get_child(4)
			if reports and reports.has_method("_on_report_selected"):
				reports._on_report_selected("income")
			print("Frame 75: Income statement")

	if _frame >= 80:
		print("Capture complete")
		quit(0)

	return false

func _find_game_screen():
	if _main == null:
		return null
	for child in _main.get_children():
		if child.has_method("_on_close_results"):
			return child
	return null
