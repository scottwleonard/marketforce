extends Control
## res://scripts/bar_chart.gd
## Custom drawn bar chart for market share and financial comparisons.

const MARGIN_LEFT = 60.0
const MARGIN_RIGHT = 20.0
const MARGIN_TOP = 30.0
const MARGIN_BOTTOM = 40.0
const BAR_COLORS = [
	Color(0.2, 0.4, 0.8),
	Color(0.8, 0.2, 0.2),
	Color(0.2, 0.7, 0.3),
	Color(0.9, 0.5, 0.1),
	Color(0.6, 0.2, 0.8),
	Color(0.1, 0.6, 0.6),
]

var title: String = ""
var labels: Array = []
var values: Array = []
var value_suffix: String = ""
var max_value_override: float = -1.0

func set_chart_data(p_title: String, p_labels: Array, p_values: Array, p_suffix: String = "") -> void:
	title = p_title
	labels = p_labels
	values = p_values
	value_suffix = p_suffix
	queue_redraw()

func _draw() -> void:
	if labels.is_empty():
		return

	var font: Font = ThemeDB.fallback_font
	var font_size: int = 11
	var title_size: int = 13

	# Background
	draw_rect(Rect2(0, 0, size.x, size.y), Color.WHITE)

	# Title
	draw_string(font, Vector2(MARGIN_LEFT, 18), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - MARGIN_LEFT - MARGIN_RIGHT, title_size, Color(0.102, 0.137, 0.494))

	var plot_w: float = size.x - MARGIN_LEFT - MARGIN_RIGHT
	var plot_h: float = size.y - MARGIN_TOP - MARGIN_BOTTOM

	var max_val: float = max_value_override if max_value_override > 0 else 1.0
	if max_value_override <= 0:
		for v in values:
			if v > max_val:
				max_val = v
		max_val *= 1.1

	var bar_count: int = labels.size()
	var bar_width: float = plot_w / bar_count * 0.7
	var gap: float = plot_w / bar_count * 0.3

	# Y-axis gridlines
	var num_grid: int = 5
	for i in range(num_grid + 1):
		var y_val: float = max_val * i / num_grid
		var y_pos: float = MARGIN_TOP + plot_h - (y_val / max_val * plot_h)
		draw_line(Vector2(MARGIN_LEFT, y_pos), Vector2(size.x - MARGIN_RIGHT, y_pos), Color(0.9, 0.9, 0.9), 1.0)
		var label_text: String = "%.1f%s" % [y_val, value_suffix]
		draw_string(font, Vector2(4, y_pos + 4), label_text, HORIZONTAL_ALIGNMENT_LEFT, MARGIN_LEFT - 8, font_size - 1, Color(0.5, 0.5, 0.5))

	# Bars
	for i in range(bar_count):
		var x: float = MARGIN_LEFT + i * (bar_width + gap) + gap / 2.0
		var val: float = values[i] if i < values.size() else 0.0
		var bar_h: float = (val / max_val) * plot_h if max_val > 0 else 0.0
		var y: float = MARGIN_TOP + plot_h - bar_h
		var color: Color = BAR_COLORS[i % BAR_COLORS.size()]

		draw_rect(Rect2(x, y, bar_width, bar_h), color)

		# Value on top
		var val_text: String = "%.1f%s" % [val, value_suffix]
		draw_string(font, Vector2(x, y - 4), val_text, HORIZONTAL_ALIGNMENT_LEFT, bar_width, font_size - 1, color)

		# Label below
		draw_string(font, Vector2(x - 5, MARGIN_TOP + plot_h + 16), str(labels[i]), HORIZONTAL_ALIGNMENT_LEFT, bar_width + 10, font_size - 1, Color(0.3, 0.3, 0.3))

	# Axes
	draw_line(Vector2(MARGIN_LEFT, MARGIN_TOP), Vector2(MARGIN_LEFT, MARGIN_TOP + plot_h), Color(0.5, 0.5, 0.5), 1.0)
	draw_line(Vector2(MARGIN_LEFT, MARGIN_TOP + plot_h), Vector2(size.x - MARGIN_RIGHT, MARGIN_TOP + plot_h), Color(0.5, 0.5, 0.5), 1.0)

	# Border
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.8, 0.8, 0.8), false, 1.0)
