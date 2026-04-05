extends Control
## res://scripts/perceptual_map.gd
## Custom drawn perceptual map showing products on Performance vs Size axes.

const MARGIN = 40.0
const DOT_RADIUS = 6.0
const AXIS_COLOR = Color(0.3, 0.3, 0.3)
const GRID_COLOR = Color(0.9, 0.9, 0.9)
const SEGMENT_COLORS = {
	"Traditional": Color(0.2, 0.4, 0.8, 0.15),
	"Low End": Color(0.2, 0.7, 0.3, 0.15),
	"High End": Color(0.8, 0.2, 0.2, 0.15),
	"Performance": Color(0.9, 0.5, 0.1, 0.15),
	"Size": Color(0.6, 0.2, 0.8, 0.15),
}
const PRODUCT_COLORS = {
	"A": Color(0.2, 0.4, 0.8),
	"B": Color(0.8, 0.2, 0.2),
	"C": Color(0.2, 0.7, 0.3),
	"D": Color(0.9, 0.5, 0.1),
	"E": Color(0.6, 0.2, 0.8),
	"F": Color(0.1, 0.6, 0.6),
}

var products: Array = []  # [{name, performance, size, company_prefix}]
var segment_centers: Dictionary = {}  # {seg_name: {performance, size}}

var perf_min: float = 0.0
var perf_max: float = 20.0
var size_min: float = 0.0
var size_max: float = 25.0

func set_products(p_products: Array) -> void:
	products = p_products
	queue_redraw()

func set_segment_centers(centers: Dictionary) -> void:
	segment_centers = centers
	queue_redraw()

func _map_to_screen(perf: float, sz: float) -> Vector2:
	var plot_w: float = size.x - MARGIN * 2
	var plot_h: float = size.y - MARGIN * 2
	var x: float = MARGIN + (perf - perf_min) / (perf_max - perf_min) * plot_w
	var y: float = MARGIN + (1.0 - (sz - size_min) / (size_max - size_min)) * plot_h
	return Vector2(x, y)

func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 11

	# Background
	draw_rect(Rect2(0, 0, size.x, size.y), Color.WHITE)

	var plot_rect = Rect2(MARGIN, MARGIN, size.x - MARGIN * 2, size.y - MARGIN * 2)

	# Grid lines
	for i in range(0, 21, 5):
		var p: Vector2 = _map_to_screen(float(i), size_min)
		var p2: Vector2 = _map_to_screen(float(i), size_max)
		draw_line(Vector2(p.x, plot_rect.position.y), Vector2(p.x, plot_rect.end.y), GRID_COLOR, 1.0)
		draw_string(font, Vector2(p.x - 8, size.y - 8), str(i), HORIZONTAL_ALIGNMENT_CENTER, 30, font_size - 1, AXIS_COLOR)

	for i in range(0, 26, 5):
		var p: Vector2 = _map_to_screen(perf_min, float(i))
		draw_line(Vector2(plot_rect.position.x, p.y), Vector2(plot_rect.end.x, p.y), GRID_COLOR, 1.0)
		draw_string(font, Vector2(4, p.y + 4), str(i), HORIZONTAL_ALIGNMENT_LEFT, 30, font_size - 1, AXIS_COLOR)

	# Segment circles
	for seg_name in segment_centers:
		if seg_name in SEGMENT_COLORS:
			var center: Dictionary = segment_centers[seg_name]
			var screen_pos: Vector2 = _map_to_screen(center["performance"], center["size"])
			draw_circle(screen_pos, 40.0, SEGMENT_COLORS[seg_name])
			draw_arc(screen_pos, 40.0, 0, TAU, 32, SEGMENT_COLORS[seg_name] * 2.0, 1.0)
			draw_string(font, screen_pos + Vector2(-20, -28), seg_name, HORIZONTAL_ALIGNMENT_CENTER, 60, font_size - 1, Color(0.4, 0.4, 0.4))

	# Product dots
	for prod in products:
		var pos: Vector2 = _map_to_screen(prod["performance"], prod["size"])
		var prefix: String = prod["name"].substr(0, 1)
		var color: Color = PRODUCT_COLORS.get(prefix, Color.GRAY)
		draw_circle(pos, DOT_RADIUS, color)
		draw_string(font, pos + Vector2(-10, -10), prod["name"], HORIZONTAL_ALIGNMENT_CENTER, 40, font_size, color)

	# Axes
	draw_line(Vector2(MARGIN, MARGIN), Vector2(MARGIN, size.y - MARGIN), AXIS_COLOR, 2.0)
	draw_line(Vector2(MARGIN, size.y - MARGIN), Vector2(size.x - MARGIN, size.y - MARGIN), AXIS_COLOR, 2.0)

	# Labels
	draw_string(font, Vector2(size.x / 2 - 40, size.y - 2), "Performance", HORIZONTAL_ALIGNMENT_CENTER, 100, font_size, AXIS_COLOR)
	draw_string(font, Vector2(2, size.y / 2), "Size", HORIZONTAL_ALIGNMENT_LEFT, 40, font_size, AXIS_COLOR)

	# Border
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.7, 0.7, 0.7), false, 1.0)
