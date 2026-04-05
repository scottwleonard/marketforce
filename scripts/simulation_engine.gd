extends RefCounted
## res://scripts/simulation_engine.gd
## Pure calculation engine for the business simulation.
## No UI, no signals — just data in, data out.

# --- Data Structures ---

# Market segment definitions
const SEGMENTS = {
	"Traditional": {
		"ideal_perf": 5.0, "ideal_size": 15.0,
		"perf_drift": 0.7, "size_drift": -0.7,
		"price_min": 20.0, "price_max": 30.0,
		"ideal_age": 2.0, "age_weight": 0.47,
		"mtbf_min": 14000, "mtbf_max": 19000,
		"importance_price": 0.23, "importance_pos": 0.21,
		"importance_age": 0.47, "importance_mtbf": 0.09,
		"demand_base": 8000, "growth_rate": 0.093
	},
	"Low End": {
		"ideal_perf": 1.7, "ideal_size": 18.3,
		"perf_drift": 0.5, "size_drift": -0.5,
		"price_min": 15.0, "price_max": 25.0,
		"ideal_age": 7.0, "age_weight": 0.24,
		"mtbf_min": 12000, "mtbf_max": 17000,
		"importance_price": 0.53, "importance_pos": 0.16,
		"importance_age": 0.24, "importance_mtbf": 0.07,
		"demand_base": 11000, "growth_rate": 0.115
	},
	"High End": {
		"ideal_perf": 8.9, "ideal_size": 11.1,
		"perf_drift": 0.9, "size_drift": -0.9,
		"price_min": 30.0, "price_max": 40.0,
		"ideal_age": 0.0, "age_weight": 0.29,
		"mtbf_min": 20000, "mtbf_max": 25000,
		"importance_price": 0.09, "importance_pos": 0.29,
		"importance_age": 0.29, "importance_mtbf": 0.33,
		"demand_base": 4000, "growth_rate": 0.163
	},
	"Performance": {
		"ideal_perf": 9.4, "ideal_size": 16.0,
		"perf_drift": 1.0, "size_drift": -0.7,
		"price_min": 25.0, "price_max": 35.0,
		"ideal_age": 1.0, "age_weight": 0.19,
		"mtbf_min": 22000, "mtbf_max": 27000,
		"importance_price": 0.19, "importance_pos": 0.29,
		"importance_age": 0.19, "importance_mtbf": 0.33,
		"demand_base": 3500, "growth_rate": 0.198
	},
	"Size": {
		"ideal_perf": 4.0, "ideal_size": 10.6,
		"perf_drift": 0.6, "size_drift": -1.0,
		"price_min": 25.0, "price_max": 35.0,
		"ideal_age": 1.5, "age_weight": 0.19,
		"mtbf_min": 16000, "mtbf_max": 21000,
		"importance_price": 0.09, "importance_pos": 0.29,
		"importance_age": 0.19, "importance_mtbf": 0.43,
		"demand_base": 3000, "growth_rate": 0.183
	}
}

const SEGMENT_ORDER = ["Traditional", "Low End", "High End", "Performance", "Size"]

# Product names per company
const COMPANY_PREFIXES = ["A", "B", "C", "D", "E", "F"]
const PRODUCT_SUFFIXES = ["ble", "id", "aft", "end"]

const TAX_RATE = 0.35
const DEPRECIATION_YEARS = 15.0
const AUTOMATION_COST_PER_POINT = 4.0  # $4M per automation point per unit capacity
const CAPACITY_COST_PER_UNIT = 0.006  # $6K per unit of capacity

static func create_initial_product(company_idx: int, product_idx: int, round_num: int) -> Dictionary:
	var prefix: String = COMPANY_PREFIXES[company_idx]
	var suffix: String = PRODUCT_SUFFIXES[product_idx]
	var name_str: String = prefix + suffix

	# Each product starts targeting a different segment
	var seg_name: String = SEGMENT_ORDER[product_idx] if product_idx < 4 else SEGMENT_ORDER[0]
	var seg: Dictionary = SEGMENTS[seg_name]

	var perf: float = seg["ideal_perf"] + randf_range(-0.3, 0.3)
	var sz: float = seg["ideal_size"] + randf_range(-0.3, 0.3)
	var mtbf: int = int((seg["mtbf_min"] + seg["mtbf_max"]) / 2.0)
	var age: float = randf_range(1.0, 3.0)
	var price: float = (seg["price_min"] + seg["price_max"]) / 2.0

	return {
		"name": name_str,
		"segment": seg_name,
		"performance": perf,
		"size": sz,
		"mtbf": mtbf,
		"age": age,
		"revision_date": 0.0,
		"material_cost": _calc_material_cost(perf, sz, mtbf),
		"labor_cost": 7.0,
		"price": price,
		"promo_budget": 1.5,
		"sales_budget": 1.5,
		"production_schedule": 1200,
		"capacity": 1800,
		"automation": 4.0,
		"awareness": 0.5 if company_idx == 0 else randf_range(0.3, 0.6),
		"accessibility": 0.4 if company_idx == 0 else randf_range(0.2, 0.5),
		"units_sold": 0,
		"revenue": 0.0,
		"inventory": 200,
		# R&D pending changes
		"rd_perf": perf,
		"rd_size": sz,
		"rd_mtbf": mtbf,
	}

static func _calc_material_cost(perf: float, sz: float, mtbf: int) -> float:
	# Higher performance and lower size = higher cost, higher MTBF = higher cost
	var base: float = 5.0
	base += (perf - 3.0) * 0.4
	base += (20.0 - sz) * 0.2
	base += (mtbf - 14000) * 0.0003
	return max(base, 1.0)

static func create_initial_company(company_idx: int) -> Dictionary:
	var products: Array = []
	for i in range(4):
		products.append(create_initial_product(company_idx, i, 0))

	var prefix: String = COMPANY_PREFIXES[company_idx]
	var names = ["Andrews", "Baldwin", "Chester", "Digby", "Erie", "Ferris"]
	return {
		"name": names[company_idx],
		"prefix": prefix,
		"products": products,
		"cash": 10.0,  # $10M starting cash
		"total_assets": 180.0,
		"plant_value": 160.0,
		"accumulated_depreciation": 20.0,
		"accounts_receivable": 0.0,
		"inventory_value": 0.0,
		"long_term_debt": 60.0,
		"short_term_debt": 0.0,
		"equity": 40.0,
		"retained_earnings": 40.0,
		"stock_issued": 40.0,
		"bonds_issued": 60.0,
		"dividends": 0.0,
		"stock_to_issue": 0.0,
		"stock_to_retire": 0.0,
		"bonds_to_issue": 0.0,
		"bonds_to_retire": 0.0,
		"emergency_loan": 0.0,
		"interest_short": 0.0,
		"interest_long": 0.0,
		"net_profit": 0.0,
		"ebit": 0.0,
		"sga": 0.0,
		"total_revenue": 0.0,
		"total_cogs": 0.0,
		"total_depreciation": 0.0,
		"cumulative_profit": 0.0,
		"market_cap": 40.0,
		"stock_price": 20.0,
		"roa": 0.0,
		"ros": 0.0,
		"asset_turnover": 0.0,
		"market_share": 0.0,
	}

static func get_segment_ideal(seg_name: String, round_num: int) -> Dictionary:
	var seg: Dictionary = SEGMENTS[seg_name]
	var perf: float = seg["ideal_perf"] + seg["perf_drift"] * round_num
	var sz: float = seg["ideal_size"] + seg["size_drift"] * round_num
	return {"performance": perf, "size": sz}

static func calc_customer_score(product: Dictionary, seg_name: String, round_num: int) -> float:
	var seg: Dictionary = SEGMENTS[seg_name]
	var ideal = get_segment_ideal(seg_name, round_num)

	# Position score: distance from ideal spot (0-1, closer = better)
	var dist: float = sqrt(pow(product["performance"] - ideal["performance"], 2) + pow(product["size"] - ideal["size"], 2))
	var pos_score: float = max(0.0, 1.0 - dist / 4.0)

	# Price score (0-1, lower relative to range = better)
	var price_range: float = seg["price_max"] - seg["price_min"]
	var price_score: float = 0.0
	if product["price"] >= seg["price_min"] and product["price"] <= seg["price_max"]:
		price_score = 1.0 - (product["price"] - seg["price_min"]) / price_range
	elif product["price"] < seg["price_min"]:
		price_score = max(0.0, 0.5 - (seg["price_min"] - product["price"]) / 5.0)

	# Age score (0-1, closer to ideal age = better)
	var age_diff: float = abs(product["age"] - seg["ideal_age"])
	var age_score: float = max(0.0, 1.0 - age_diff / 5.0)

	# MTBF score (0-1, higher within range = better)
	var mtbf_score: float = 0.0
	if product["mtbf"] >= seg["mtbf_min"] and product["mtbf"] <= seg["mtbf_max"]:
		mtbf_score = float(product["mtbf"] - seg["mtbf_min"]) / float(seg["mtbf_max"] - seg["mtbf_min"])
	elif product["mtbf"] > seg["mtbf_max"]:
		mtbf_score = 0.8

	# Weighted total
	var score: float = (
		pos_score * seg["importance_pos"] +
		price_score * seg["importance_price"] +
		age_score * seg["importance_age"] +
		mtbf_score * seg["importance_mtbf"]
	)

	# Scale by awareness and accessibility
	score *= product["awareness"] * product["accessibility"]

	return score

static func simulate_round(companies: Array, round_num: int) -> Dictionary:
	# Apply R&D changes
	for co in companies:
		for prod in co["products"]:
			var perf_change: float = abs(prod["rd_perf"] - prod["performance"])
			var size_change: float = abs(prod["rd_size"] - prod["size"])
			if perf_change > 0.01 or size_change > 0.01:
				prod["age"] = 0.0  # Product revision resets age
			prod["performance"] = prod["rd_perf"]
			prod["size"] = prod["rd_size"]
			prod["mtbf"] = prod["rd_mtbf"]
			prod["material_cost"] = _calc_material_cost(prod["performance"], prod["size"], prod["mtbf"])

	# Calculate demand per segment
	var segment_demands: Dictionary = {}
	for seg_name in SEGMENT_ORDER:
		var seg: Dictionary = SEGMENTS[seg_name]
		var demand: float = seg["demand_base"] * pow(1.0 + seg["growth_rate"], round_num)
		segment_demands[seg_name] = demand

	# Score all products in each segment and allocate demand
	var segment_results: Dictionary = {}  # seg -> [{company_idx, product_idx, score, units_sold}]
	for seg_name in SEGMENT_ORDER:
		var entries: Array = []
		var total_score: float = 0.0
		for ci in range(companies.size()):
			var co: Dictionary = companies[ci]
			for pi in range(co["products"].size()):
				var prod: Dictionary = co["products"][pi]
				var score: float = calc_customer_score(prod, seg_name, round_num)
				if score > 0.01:
					entries.append({"ci": ci, "pi": pi, "score": score, "units": 0})
					total_score += score

		var seg_demand: float = segment_demands[seg_name]
		if total_score > 0:
			for e in entries:
				var share: float = e["score"] / total_score
				e["units"] = int(seg_demand * share)

		segment_results[seg_name] = entries

	# Aggregate units sold per product across segments
	for co in companies:
		for prod in co["products"]:
			prod["units_sold"] = 0

	for seg_name in SEGMENT_ORDER:
		for e in segment_results[seg_name]:
			var prod: Dictionary = companies[e["ci"]]["products"][e["pi"]]
			prod["units_sold"] += e["units"]

	# Cap units sold by production schedule + inventory
	for co in companies:
		for prod in co["products"]:
			var available: int = prod["production_schedule"] + prod["inventory"]
			if prod["units_sold"] > available:
				prod["units_sold"] = available
			prod["inventory"] = available - prod["units_sold"]

	# Financial calculations per company
	for co in companies:
		var total_rev: float = 0.0
		var total_cogs: float = 0.0
		var total_sga: float = 0.0

		for prod in co["products"]:
			# Revenue
			var rev: float = prod["units_sold"] * prod["price"] * 0.001  # In millions
			prod["revenue"] = rev
			total_rev += rev

			# COGS (material + labor per unit)
			var cogs: float = prod["units_sold"] * (prod["material_cost"] + prod["labor_cost"]) * 0.001
			total_cogs += cogs

			# SGA (promo + sales budgets)
			total_sga += prod["promo_budget"] + prod["sales_budget"]

			# Update awareness (driven by promo budget)
			prod["awareness"] = min(1.0, prod["awareness"] + prod["promo_budget"] * 0.05)
			prod["awareness"] = max(0.1, prod["awareness"] - 0.02)  # Natural decay

			# Update accessibility (driven by sales budget)
			prod["accessibility"] = min(1.0, prod["accessibility"] + prod["sales_budget"] * 0.04)
			prod["accessibility"] = max(0.1, prod["accessibility"] - 0.02)

			# Age products
			prod["age"] += 1.0

		# Depreciation
		var depreciation: float = co["plant_value"] / DEPRECIATION_YEARS

		# Apply finance decisions
		co["cash"] += co["stock_to_issue"]
		co["stock_issued"] += co["stock_to_issue"]
		co["equity"] += co["stock_to_issue"]

		co["cash"] -= co["stock_to_retire"]
		co["stock_issued"] = max(0, co["stock_issued"] - co["stock_to_retire"])
		co["equity"] -= co["stock_to_retire"]

		co["cash"] += co["bonds_to_issue"]
		co["bonds_issued"] += co["bonds_to_issue"]
		co["long_term_debt"] += co["bonds_to_issue"]

		co["cash"] -= co["bonds_to_retire"]
		co["bonds_issued"] = max(0, co["bonds_issued"] - co["bonds_to_retire"])
		co["long_term_debt"] = max(0, co["long_term_debt"] - co["bonds_to_retire"])

		# Capacity and automation investments
		for prod in co["products"]:
			var cap_change: int = prod["production_schedule"] - prod["capacity"]
			if cap_change > 0:
				var cap_cost: float = cap_change * CAPACITY_COST_PER_UNIT
				co["cash"] -= cap_cost
				co["plant_value"] += cap_cost
				prod["capacity"] = prod["production_schedule"]

		# Interest
		co["interest_short"] = co["short_term_debt"] * 0.10
		co["interest_long"] = co["long_term_debt"] * 0.065
		var total_interest: float = co["interest_short"] + co["interest_long"]

		# EBIT
		var ebit: float = total_rev - total_cogs - total_sga - depreciation
		co["ebit"] = ebit

		# Net profit
		var ebt: float = ebit - total_interest
		var taxes: float = max(0.0, ebt * TAX_RATE)
		var net_profit: float = ebt - taxes

		# Dividends
		co["cash"] -= co["dividends"]

		co["total_revenue"] = total_rev
		co["total_cogs"] = total_cogs
		co["sga"] = total_sga
		co["total_depreciation"] = depreciation
		co["net_profit"] = net_profit
		co["cumulative_profit"] += net_profit
		co["retained_earnings"] += net_profit - co["dividends"]
		co["equity"] = co["stock_issued"] + co["retained_earnings"]

		# Cash flow
		co["cash"] += total_rev - total_cogs - total_sga - total_interest - taxes

		# Emergency loan if cash goes negative
		if co["cash"] < 0:
			co["emergency_loan"] = abs(co["cash"]) + 1.0
			co["short_term_debt"] += co["emergency_loan"]
			co["cash"] += co["emergency_loan"]
		else:
			co["emergency_loan"] = 0.0

		# Balance sheet
		co["accumulated_depreciation"] += depreciation
		co["accounts_receivable"] = total_rev * 0.5
		co["inventory_value"] = 0.0
		for prod in co["products"]:
			co["inventory_value"] += prod["inventory"] * (prod["material_cost"] + prod["labor_cost"]) * 0.001

		co["total_assets"] = co["cash"] + co["accounts_receivable"] + co["inventory_value"] + co["plant_value"] - co["accumulated_depreciation"]

		# Stock price and market cap (simplified)
		co["stock_price"] = max(1.0, 20.0 + co["cumulative_profit"] * 0.5 + co["net_profit"] * 2.0)
		co["market_cap"] = co["stock_price"] * 2.0  # Assume 2M shares

		# Ratios
		co["roa"] = co["net_profit"] / co["total_assets"] * 100.0 if co["total_assets"] > 0 else 0.0
		co["ros"] = co["net_profit"] / co["total_revenue"] * 100.0 if co["total_revenue"] > 0 else 0.0
		co["asset_turnover"] = co["total_revenue"] / co["total_assets"] if co["total_assets"] > 0 else 0.0

		# Reset one-time finance decisions
		co["stock_to_issue"] = 0.0
		co["stock_to_retire"] = 0.0
		co["bonds_to_issue"] = 0.0
		co["bonds_to_retire"] = 0.0

	# Market share
	var total_industry_rev: float = 0.0
	for co in companies:
		total_industry_rev += co["total_revenue"]
	for co in companies:
		co["market_share"] = co["total_revenue"] / total_industry_rev * 100.0 if total_industry_rev > 0 else 0.0

	return {
		"segment_demands": segment_demands,
		"segment_results": segment_results,
	}

static func make_ai_decisions(company: Dictionary, round_num: int) -> void:
	for prod in company["products"]:
		var seg_name: String = prod["segment"]
		var ideal = get_segment_ideal(seg_name, round_num + 1)

		# R&D: drift toward next round's ideal position
		prod["rd_perf"] = lerp(prod["performance"], ideal["performance"], 0.5)
		prod["rd_size"] = lerp(prod["size"], ideal["size"], 0.5)

		# Adjust MTBF toward segment midpoint
		var seg: Dictionary = SEGMENTS[seg_name]
		var mid_mtbf: int = int((seg["mtbf_min"] + seg["mtbf_max"]) / 2.0)
		prod["rd_mtbf"] = int(lerp(float(prod["mtbf"]), float(mid_mtbf), 0.3))

		# Marketing: moderate spending
		prod["promo_budget"] = randf_range(1.0, 2.5)
		prod["sales_budget"] = randf_range(1.0, 2.5)

		# Price: stay in range
		var price_mid: float = (seg["price_min"] + seg["price_max"]) / 2.0
		prod["price"] = lerp(prod["price"], price_mid, 0.3) + randf_range(-1.0, 1.0)
		prod["price"] = clamp(prod["price"], seg["price_min"], seg["price_max"])

		# Production: match expected demand roughly
		prod["production_schedule"] = int(prod["units_sold"] * randf_range(1.0, 1.2)) + 100
		if prod["production_schedule"] < 200:
			prod["production_schedule"] = 800

	# Finance: conservative
	company["dividends"] = max(0, company["net_profit"] * 0.2)
