extends SceneTree
## Presentation video — ~30s cinematic showcasing the Capsim business simulation.
## 900 frames at 30 FPS = 30 seconds.

var _frame: int = 0
var _gm = null
var _main = null
var _gs = null

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

	# --- Title Screen (frames 1-120, 4 seconds) ---
	if _frame == 1:
		pass  # Title screen renders automatically

	# --- Start Game (frame 120) ---
	if _frame == 120:
		if _main and _main.has_method("_on_start_pressed"):
			_main._on_start_pressed()

	# --- Find game screen ---
	if _frame == 130 and _gs == null:
		_gs = _find_game_screen()

	# --- R&D Tab (frames 130-250, ~4 seconds) ---
	# Already showing by default

	# --- Marketing Tab (frames 250-370, ~4 seconds) ---
	if _frame == 250 and _gs and _gs.tab_container:
		_gs.tab_container.current_tab = 1

	# --- Production Tab (frames 370-460, ~3 seconds) ---
	if _frame == 370 and _gs and _gs.tab_container:
		_gs.tab_container.current_tab = 2

	# --- Finance Tab (frames 460-540, ~2.5 seconds) ---
	if _frame == 460 and _gs and _gs.tab_container:
		_gs.tab_container.current_tab = 3

	# --- Submit Round 1 (frame 540) ---
	if _frame == 540:
		if _gm and _gm.game_active:
			_gm.submit_decisions()

	# --- Show results popup (frames 540-620, ~2.5 seconds) ---

	# --- Close results, show Reports - Income Statement (frame 620) ---
	if _frame == 620 and _gs:
		_gs._on_close_results()
		_gs.tab_container.current_tab = 4

	# --- Switch to Market Share chart (frame 680) ---
	if _frame == 680 and _gs:
		var reports = _gs.tab_container.get_child(4)
		if reports and reports.has_method("_on_report_selected"):
			reports._on_report_selected("market")

	# --- Switch to Scoreboard (frame 740) ---
	if _frame == 740 and _gs:
		var reports = _gs.tab_container.get_child(4)
		if reports and reports.has_method("_on_report_selected"):
			reports._on_report_selected("scoreboard")

	# --- Submit Round 2 (frame 800) ---
	if _frame == 800:
		if _gm and _gm.game_active:
			_gm.submit_decisions()

	# --- Show results for round 2 (frames 800-870) ---

	# --- Close results, back to R&D showing updated data (frame 870) ---
	if _frame == 870 and _gs:
		_gs._on_close_results()
		_gs.tab_container.current_tab = 0

	# --- End (frame 900) ---
	if _frame >= 900:
		quit(0)

	return false

func _find_game_screen():
	if _main == null:
		return null
	for child in _main.get_children():
		if child.has_method("_on_close_results"):
			return child
	return null
