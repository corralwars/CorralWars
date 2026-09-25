class_name PetBase extends CharacterBody2D

@export_category("Target")
@export var GROUP_FOLLOW: String = ""

@export_category("Movement Delay")
@export var MOVEMENT_DELAY: float = 1.0

@export_category("References")
@export var animatedSprite: AnimatedSprite2D
@export var IsInUse:bool

var is_fight_scene:bool;

var target: CharacterBody2D = null
var movement_history: Array[Dictionary] = []
var elapsed_time: float = 0.0


func _ready() -> void:
	target = get_tree().get_first_node_in_group(GROUP_FOLLOW) as CharacterBody2D
	is_fight_scene = get_tree().current_scene.scene_file_path.get_file().get_basename().begins_with("Fight")


func _physics_process(delta: float) -> void:
	if target == null:
		return

	if is_fight_scene:
		pass
	else:
		_physics_process_top_view(delta)


func _physics_process_top_view(delta: float) -> void:

	elapsed_time += delta
	movement_history.append({
		"time": elapsed_time,
		"velocity": target.velocity
	})

	var delayed_time: float = elapsed_time - MOVEMENT_DELAY
	if delayed_time <= 0.0:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation(velocity)
		return

	var delayed_velocity: Vector2 = _get_delayed_velocity(delayed_time)
	velocity = delayed_velocity

	move_and_slide()
	_update_animation(velocity)


func _get_delayed_velocity(target_time: float) -> Vector2:

	if movement_history.is_empty():
		return Vector2.ZERO

	var oldest_entry: Dictionary = movement_history[0]

	if float(oldest_entry["time"]) > target_time:
		return Vector2.ZERO

	var delayed_velocity: Vector2 = Vector2.ZERO

	for i in range(movement_history.size() - 1, -1, -1):
		var entry: Dictionary = movement_history[i]
		var entry_time: float = float(entry["time"])

		if entry_time <= target_time:
			delayed_velocity = entry["velocity"] as Vector2
			break
	return delayed_velocity

func _update_animation(movement_velocity: Vector2) -> void:
	if animatedSprite == null:
		return

	if movement_velocity.is_zero_approx():
		animatedSprite.play("Idle")
		return

	if abs(movement_velocity.x) > abs(movement_velocity.y):
		animatedSprite.play("Walk_Front")
		animatedSprite.flip_h = movement_velocity.x < 0.0
		return

	if movement_velocity.y < 0.0:
		animatedSprite.play("Walk_Up")
		return

	if movement_velocity.y > 0.0:
		animatedSprite.play("Walk_Down")
		return
