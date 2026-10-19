
extends VBoxContainer

const HIDE_DELAY: float = 0.5
const MOVE_DURATION: float = 0.22
const FADE_DURATION: float = 0.25
const BOB_DISTANCE: float = 5.0
const BOB_DURATION: float = 0.7
const MARK_OFFSET_X: float = 20.0

var mark: TextureRect
var hide_timer: Timer

var move_tween: Tween
var fade_tween: Tween
var bob_tween: Tween

var current_option: Label
var is_mark_visible: bool = false


func _ready() -> void:
	mark = get_tree().get_first_node_in_group("mark") as TextureRect

	if mark == null:
		push_error("No se encontró un TextureRect en el grupo 'mark'.")
		return

	# Ocultar instantáneamente al iniciar.
	mark.modulate.a = 0.0

	# Temporizador para ocultar el marcador después de 2 segundos.
	hide_timer = Timer.new()
	hide_timer.one_shot = true
	hide_timer.wait_time = HIDE_DELAY
	hide_timer.timeout.connect(_on_hide_timer_timeout)
	add_child(hide_timer)

	# Conectar las opciones.
	for child in get_children():
		if child is Label and child.is_in_group("options"):
			child.mouse_filter = Control.MOUSE_FILTER_STOP
			child.mouse_entered.connect(_on_option_mouse_entered.bind(child))
			child.mouse_exited.connect(_on_option_mouse_exited.bind(child))



func _on_option_mouse_entered(option: Label) -> void:
	option.add_theme_color_override("font_color", Color.BLACK)

	# Si venimos de otra opción rápidamente, cancelamos el ocultamiento.
	hide_timer.stop()

	var target_position := _get_mark_position(option)

	if is_mark_visible:
		_stop_bob_animation()
		_stop_move_animation()

		move_tween = create_tween()
		move_tween.set_trans(Tween.TRANS_QUAD)
		move_tween.set_ease(Tween.EASE_OUT)
		move_tween.tween_property(
			mark,
			"global_position",
			target_position,
			MOVE_DURATION
		)

		move_tween.finished.connect(_start_bob_animation)
	else:
		mark.global_position = target_position
		current_option = option
		_show_mark()





func _on_option_mouse_exited(option: Label) -> void:
	option.remove_theme_color_override("font_color")
	hide_timer.start()


func _on_hide_timer_timeout() -> void:
	_stop_bob_animation()
	_stop_move_animation()
	_stop_fade_animation()

	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.tween_property(
		mark,
		"modulate:a",
		0.0,
		FADE_DURATION
	)

	fade_tween.finished.connect(_on_mark_hidden)


func _on_mark_hidden() -> void:
	is_mark_visible = false
	current_option = null


func _show_mark() -> void:
	is_mark_visible = true
	_stop_fade_animation()

	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(
		mark,
		"modulate:a",
		1.0,
		FADE_DURATION
	)

	fade_tween.finished.connect(_start_bob_animation)



func _get_mark_position(option: Label) -> Vector2:
	var centered_position := Vector2(
		option.global_position.x + (option.size.x - mark.size.x) / 2.0,
		option.global_position.y + (option.size.y - mark.size.y) / 2.0
	)

	# Desplazar 20 px a la izquierda después de centrar.
	centered_position.x -= MARK_OFFSET_X

	return centered_position



func _start_bob_animation() -> void:
	if not is_mark_visible:
		return

	_stop_bob_animation()

	# Guardar la posición base para oscilar alrededor de ella.
	var base_X= mark.global_position.x

	bob_tween = create_tween()
	bob_tween.set_loops()
	bob_tween.set_trans(Tween.TRANS_SINE)
	bob_tween.set_ease(Tween.EASE_IN_OUT)

	bob_tween.tween_property(
		mark,
		"global_position:x",
		base_X - BOB_DISTANCE,
		BOB_DURATION
	)

	bob_tween.tween_property(
		mark,
		"global_position:x",
		base_X + BOB_DISTANCE,
		BOB_DURATION
	)


func _stop_bob_animation() -> void:
	if bob_tween and bob_tween.is_valid():
		bob_tween.kill()

	bob_tween = null


func _stop_move_animation() -> void:
	if move_tween and move_tween.is_valid():
		move_tween.kill()

	move_tween = null


func _stop_fade_animation() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()

	fade_tween = null
