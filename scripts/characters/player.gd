extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const TOP_VIEW_SPEED = 300.0

var is_fight_scene := false


func _ready() -> void:
	is_fight_scene = get_tree().current_scene.scene_file_path.get_file().get_basename().begins_with("Fight")


func _physics_process(delta: float) -> void:
	if is_fight_scene:
		_physics_process_fight(delta)
	else:
		_physics_process_top_view(delta)


func _physics_process_fight(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
		if direction < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.play("Jump")
		else:
			$AnimatedSprite2D.play("Fall")
	else:
		if direction != 0:
			$AnimatedSprite2D.play("Walk_Front")
		else:
			$AnimatedSprite2D.play("Idle")


func _physics_process_top_view(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * TOP_VIEW_SPEED

	move_and_slide()

	if direction.y != 0:
		$AnimatedSprite2D.play("Walk_Up")
	elif direction.x != 0:
		$AnimatedSprite2D.flip_h = direction.x < 0
		$AnimatedSprite2D.play("Walk_Front")
	else:
		$AnimatedSprite2D.play("Idle")
