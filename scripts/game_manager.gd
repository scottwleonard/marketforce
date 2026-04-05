extends Node
## res://scripts/game_manager.gd
## Autoload singleton — manages game state, companies, rounds, AI.

signal game_started
signal round_completed(round_num: int)
signal game_ended
signal decisions_submitted

const SimEngine = preload("res://scripts/simulation_engine.gd")

var companies: Array = []
var current_round: int = 0
var max_rounds: int = 8
var player_company_idx: int = 0
var num_companies: int = 6
var game_active: bool = false
var last_round_results: Dictionary = {}
var round_history: Array = []  # Array of per-round snapshots

func start_new_game(player_name: String = "Andrews") -> void:
	companies.clear()
	round_history.clear()
	current_round = 0
	game_active = true

	for i in range(num_companies):
		var co: Dictionary = SimEngine.create_initial_company(i)
		if i == player_company_idx:
			co["name"] = player_name
		companies.append(co)

	game_started.emit()

func get_player_company() -> Dictionary:
	return companies[player_company_idx]

func submit_decisions() -> void:
	# AI makes decisions for non-player companies
	for i in range(num_companies):
		if i != player_company_idx:
			SimEngine.make_ai_decisions(companies[i], current_round)

	decisions_submitted.emit()

	# Run simulation
	current_round += 1
	last_round_results = SimEngine.simulate_round(companies, current_round)

	# Save snapshot
	var snapshot: Dictionary = {
		"round": current_round,
		"companies": _deep_copy_companies(),
	}
	round_history.append(snapshot)

	if current_round >= max_rounds:
		game_active = false
		game_ended.emit()
	else:
		round_completed.emit(current_round)

func _deep_copy_companies() -> Array:
	var copy: Array = []
	for co in companies:
		var co_copy: Dictionary = co.duplicate(true)
		copy.append(co_copy)
	return copy

func get_segment_names() -> Array:
	return SimEngine.SEGMENT_ORDER.duplicate()

func get_segment_data(seg_name: String) -> Dictionary:
	return SimEngine.SEGMENTS[seg_name].duplicate()

func get_segment_ideal(seg_name: String) -> Dictionary:
	return SimEngine.get_segment_ideal(seg_name, current_round)

func get_all_products_in_segment(seg_name: String) -> Array:
	var results: Array = []
	for ci in range(companies.size()):
		var co: Dictionary = companies[ci]
		for pi in range(co["products"].size()):
			var prod: Dictionary = co["products"][pi]
			var score: float = SimEngine.calc_customer_score(prod, seg_name, current_round)
			if score > 0.01:
				results.append({
					"company": co["name"],
					"product": prod["name"],
					"score": score,
					"units_sold": prod["units_sold"],
					"price": prod["price"],
					"perf": prod["performance"],
					"size": prod["size"],
				})
	return results

func get_rankings() -> Array:
	var ranked: Array = []
	for co in companies:
		ranked.append({
			"name": co["name"],
			"market_share": co["market_share"],
			"revenue": co["total_revenue"],
			"profit": co["net_profit"],
			"cumulative_profit": co["cumulative_profit"],
			"stock_price": co["stock_price"],
			"roa": co["roa"],
		})
	ranked.sort_custom(func(a, b): return a["cumulative_profit"] > b["cumulative_profit"])
	return ranked
