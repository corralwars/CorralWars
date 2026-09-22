class_name NeighboordBase
extends CharacterBody2D


@export var SPEED: float = 100.0
@export var JUMP_SPEED: float = -450.0
@export var MAX_LIFE: int = 5000

@export_category("Top View Movement")
@export var MOVE_AREA_MIN: Vector2 = Vector2(100, 100)
@export var MOVE_AREA_MAX: Vector2 = Vector2(1000, 600)

@export var MIN_MOVE_DISTANCE: float = 50.0
@export var MAX_MOVE_DISTANCE: float = 150.0

@export var MIN_MOVE_TIME: float = 1.0
@export var MAX_MOVE_TIME: float = 2.5

@export var MIN_IDLE_TIME: float = 1.0
@export var MAX_IDLE_TIME: float = 3.0
@export var MIN_DISTANCE_TO_TARGET: float = 5.0


@export_category("References")
@export var animatedSprite: AnimatedSprite2D


var player: CharacterBody2D
var is_fight_scene: bool = false

var movement_target: Vector2
var movement_timer: float = 0.0

var is_moving: bool = false


func _ready() -> void:

	player = get_tree().get_first_node_in_group("Player")

	var current_scene_path := get_tree().current_scene.scene_file_path

	if current_scene_path.get_file().begins_with("Fight"):
		is_fight_scene = true
	else:
		_start_moving()


func get_player_direction() -> int:

	if player == null:
		return 0

	if player.global_position.x > global_position.x:
		return 1

	if player.global_position.x < global_position.x:
		return -1

	return 0


func _physics_process(delta: float) -> void:

	if player == null:
		return

	if is_fight_scene:
		_physics_process_fight(delta)
	else:
		_physics_process_top_view(delta)


func _physics_process_fight(delta: float) -> void:
	if animatedSprite:
		animatedSprite.flip_h = get_player_direction() < 0


func _physics_process_top_view(delta: float) -> void:
	movement_timer -= delta

	if not is_moving:

		velocity = Vector2.ZERO
		move_and_slide()

		if movement_timer <= 0.0:
			_start_moving()

		return


	var direction := global_position.direction_to(movement_target)

	velocity = direction * SPEED

	move_and_slide()

	if global_position.distance_to(movement_target) <= MIN_DISTANCE_TO_TARGET:

		_start_idle()

		return


	if movement_timer <= 0.0:

		_start_idle()


func _start_moving() -> void:

	is_moving = true

	_choose_random_target()

	movement_timer = randf_range(
		MIN_MOVE_TIME,
		MAX_MOVE_TIME
	)


func _start_idle() -> void:

	is_moving = false

	velocity = Vector2.ZERO

	movement_timer = randf_range(
		MIN_IDLE_TIME,
		MAX_IDLE_TIME
	)


func _choose_random_target() -> void:

	var angle := randf_range(
		0.0,
		TAU
	)

	var distance := randf_range(
		MIN_MOVE_DISTANCE,
		MAX_MOVE_DISTANCE
	)

	var offset := Vector2(
		cos(angle),
		sin(angle)
	) * distance

	movement_target = global_position + offset

	movement_target.x = clamp(
		movement_target.x,
		MOVE_AREA_MIN.x,
		MOVE_AREA_MAX.x
	)

	movement_target.y = clamp(
		movement_target.y,
		MOVE_AREA_MIN.y,
		MOVE_AREA_MAX.y
	)
