
extends TextureRect

const TRAVEL_DURATION: float = 50.0
const COVER_ZOOM: float = 1.15

var offset_x: float = 0.0
var left_limit: float = 0.0
var right_limit: float = 0.0

# false: se mueve hacia la izquierda al comenzar.
# true: se mueve hacia la derecha.
var moving_right: bool = false

var movement_progress: float = 0.0


func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Evita que la imagen dibujada sobresalga del área del control.
	clip_contents = true

	item_rect_changed.connect(_update_cover_and_movement)
	get_viewport().size_changed.connect(_update_cover_and_movement)

	_update_cover_and_movement()


func _draw() -> void:
	if texture == null:
		return

	var image_size: Vector2 = texture.get_size()

	if image_size.x <= 0.0 or image_size.y <= 0.0:
		return

	var scale_factor: float = maxf(
		size.x / image_size.x,
		size.y / image_size.y
	) * COVER_ZOOM

	var draw_size: Vector2 = image_size * scale_factor

	draw_texture_rect(
		texture,
		Rect2(Vector2(offset_x, 0.0), draw_size),
		false
	)


func _update_cover_and_movement() -> void:
	if texture == null or size.x <= 0.0 or size.y <= 0.0:
		return

	var image_size: Vector2 = texture.get_size()

	var scale_factor: float = maxf(
		size.x / image_size.x,
		size.y / image_size.y
	) * COVER_ZOOM

	var draw_size: Vector2 = image_size * scale_factor
	var excess_x: float = draw_size.x - size.x

	# La imagen se desplaza entre estos dos límites.
	right_limit = 0.0
	left_limit = -excess_x

	# Conserva la posición dentro de los límites nuevos.
	offset_x = clampf(offset_x, left_limit, right_limit)

	# Conserva aproximadamente el progreso al cambiar el viewport.
	if moving_right:
		movement_progress = inverse_lerp(
			left_limit,
			right_limit,
			offset_x
		)
	else:
		movement_progress = inverse_lerp(
			right_limit,
			left_limit,
			offset_x
		)

	queue_redraw()


func _process(delta: float) -> void:
	var excess_x: float = right_limit - left_limit

	if excess_x <= 0.0:
		return

	movement_progress += delta / TRAVEL_DURATION

	if movement_progress >= 1.0:
		movement_progress = 0.0
		moving_right = not moving_right

	if moving_right:
		offset_x = lerpf(
			left_limit,
			right_limit,
			movement_progress
		)
	else:
		offset_x = lerpf(
			right_limit,
			left_limit,
			movement_progress
		)

	queue_redraw()
