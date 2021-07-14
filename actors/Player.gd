class_name Player
extends Actor

onready var sprite = $AnimatedSprite

var double_jumps = 0
export var max_double_jump = 1

func _physics_process(delta):
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	var direction = get_direction()
	var velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	velocity.y += gravity * delta
	if is_on_wall() and not is_on_floor() and velocity.y > 0.0:
		velocity.y = gravity * 0.01
	_velocity = move_and_slide(velocity, FLOOR_NORMAL)
	if _velocity.x != 0.0:
		sprite.flip_h = true if _velocity.x < 0.0 else false
		
	
func get_direction() -> Vector2:
	var direction = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
							-1.0 if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()) else 1.0)
	return direction

func calculate_move_velocity(linear_velocity, direction, speed, is_jump_interrupted):
	var velocity = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y == -1.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y = 0.0
	
	return velocity
