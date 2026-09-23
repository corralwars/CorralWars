class_name NeighboordBase
extends CharacterBody2D


@export var SPEED: float = 100.0
@export var JUMP_SPEED: float = -450.0
@export var MAX_LIFE: int = 5000


@export_category("Top View Movement")
@export var MOVE_AREA_SIZE: Vector2 = Vector2(300, 200)

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
var starting_position: Vector2

var move_area_min: Vector2
var move_area_max: Vector2

var movement_target: Vector2

var movement_timer: float = 0.0

var is_moving: bool = false


func _ready() -> void:

	player = get_tree().get_first_node_in_group("Player")
	var current_scene_path := get_tree().current_scene.scene_file_path

	if current_scene_path.get_file().begins_with("Fight"):
		is_fight_scene = true

	else:
		is_fight_scene = false
		starting_position = position
		_calculate_move_area()


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
		_update_idle_animation()
		if movement_timer <= 0.0:
			_start_moving()
		return
		
	var direction := position.direction_to(movement_target)
	velocity = direction * SPEED
	move_and_slide()
	_update_movement_animation_top_view(direction)
	
	if position.distance_to(movement_target) <= MIN_DISTANCE_TO_TARGET:
		_start_idle()
		return

	if movement_timer <= 0.0:
		_start_idle()
		
func _calculate_move_area() -> void:
	move_area_min = starting_position - (MOVE_AREA_SIZE / 2.0)
	move_area_max = starting_position + (MOVE_AREA_SIZE / 2.0)

func _update_movement_animation_top_view(direction: Vector2) -> void:
	if animatedSprite == null:
		return
	if abs(direction.x) > abs(direction.y):
		animatedSprite.play("Walk_Front")
		animatedSprite.flip_h = direction.x < 0.0
	else:
		if direction.y < 0.0:
			animatedSprite.play("Walk_Up")
		else:
			animatedSprite.play("Walk_Down")

func _update_idle_animation() -> void:
	if animatedSprite == null:
		return
	if player == null:
		return

	animatedSprite.play("Idle")
	animatedSprite.flip_h = get_player_direction() < 0

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

	movement_target = position + offset

	movement_target.x = clamp(
		movement_target.x,
		move_area_min.x,
		move_area_max.x
	)
	
	movement_target.y = clamp(
		movement_target.y,
		move_area_min.y,
		move_area_max.y
	)
