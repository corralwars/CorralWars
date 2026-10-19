
extends TextureRect

const TRAVEL_DURATION: float = 10.0

var movement_tween: Tween
var initial_position: Vector2


func _ready() -> void:
	await get_tree().process_frame

	initial_position = position
	_start_movement()


func _start_movement() -> void:
	var viewport_width: float = get_viewport_rect().size.x

	# Tamaño que realmente ocupa el control.
	var visual_width: float = size.x * scale.x
	var excess_x: float = visual_width - viewport_width

	print("Control: ", size.x)
	print("Escala: ", scale.x)
	print("Ancho visual: ", visual_width)
	print("Viewport: ", viewport_width)
	print("Excedente: ", excess_x)

	if excess_x <= 0.0:
		push_warning("El control no tiene excedente horizontal para animar.")
		return

	# Mantener la posición inicial y oscilar dentro del excedente.
	var start_x: float = initial_position.x - excess_x / 2.0
	var end_x: float = initial_position.x + excess_x / 2.0

	movement_tween = create_tween()
	movement_tween.set_loops()
	movement_tween.set_trans(Tween.TRANS_SINE)
	movement_tween.set_ease(Tween.EASE_IN_OUT)

	movement_tween.tween_property(
		self,
		"position:x",
		end_x,
		TRAVEL_DURATION
	)

	movement_tween.tween_property(
		self,
		"position:x",
		start_x,
		TRAVEL_DURATION
	)


func _exit_tree() -> void:
	if movement_tween and movement_tween.is_valid():
		movement_tween.kill()
