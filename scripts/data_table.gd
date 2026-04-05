extends Control
## res://scripts/data_table.gd
## Reusable styled data table with headers and rows.

const HEADER_COLOR = Color(0.102, 0.137, 0.494)  # Navy #1a237e
const HEADER_TEXT = Color.WHITE
const ROW_EVEN = Color(0.97, 0.97, 0.97)
const ROW_ODD = Color.WHITE
const BORDER_COLOR = Color(0.82, 0.82, 0.82)
const ROW_HEIGHT = 32
const HEADER_HEIGHT = 36

var headers: Array = []
var rows: Array = []  # Array of Arrays
var column_widths: Array = []

func setup(p_headers: Array, p_widths: Array = []) -> void:
	headers = p_headers
	column_widths = p_widths
	if column_widths.is_empty():
		var w: float = size.x / max(1, headers.size())
		for i in range(headers.size()):
			column_widths.append(w)
	queue_redraw()

func set_data(p_rows: Array) -> void:
	rows = p_rows
	custom_minimum_size.y = HEADER_HEIGHT + rows.size() * ROW_HEIGHT + 2
	queue_redraw()

func _draw() -> void:
	if headers.is_empty():
		return

	var font: Font = ThemeDB.fallback_font
	var font_size: int = 13

	# Header background
	draw_rect(Rect2(0, 0, size.x, HEADER_HEIGHT), HEADER_COLOR)

	# Header text
	var x_offset: float = 4.0
	for i in range(headers.size()):
		var w: float = column_widths[i] if i < column_widths.size() else 100.0
		draw_string(font, Vector2(x_offset + 6, HEADER_HEIGHT - 10), str(headers[i]), HORIZONTAL_ALIGNMENT_LEFT, w - 12, font_size, HEADER_TEXT)
		x_offset += w

	# Rows
	for r in range(rows.size()):
		var y: float = HEADER_HEIGHT + r * ROW_HEIGHT
		var bg_color: Color = ROW_EVEN if r % 2 == 0 else ROW_ODD
		draw_rect(Rect2(0, y, size.x, ROW_HEIGHT), bg_color)
		draw_line(Vector2(0, y + ROW_HEIGHT), Vector2(size.x, y + ROW_HEIGHT), BORDER_COLOR, 1.0)

		x_offset = 4.0
		for c in range(rows[r].size()):
			var w: float = column_widths[c] if c < column_widths.size() else 100.0
			var text: String = str(rows[r][c])
			draw_string(font, Vector2(x_offset + 6, y + ROW_HEIGHT - 10), text, HORIZONTAL_ALIGNMENT_LEFT, w - 12, font_size, Color.BLACK)
			x_offset += w

	# Border
	draw_rect(Rect2(0, 0, size.x, HEADER_HEIGHT + rows.size() * ROW_HEIGHT), BORDER_COLOR, false, 1.0)
