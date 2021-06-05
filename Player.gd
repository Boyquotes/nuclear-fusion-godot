class_name Player
extends Actor

const FLOOR_DETECT_DISTANCE = 20.0

onready var platform_detector = $PlatformDetector
onready var sprite = $Sprite

var double_jumps = 0
export var max_double_jump = 1

func _physics_process(delta):
	var direction = get_direction()
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = platform_detector.is_colliding()
	if is_on_floor() or is_on_platform:
		double_jumps = 0
	if Input.is_action_just_pressed("jump") and not is_on_platform and not is_on_floor() and double_jumps < max_double_jump:
		_velocity.y = -speed.y * 0.7
		double_jumps += 1
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false)
	
func get_direction():
	return Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), -1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0)

func calculate_move_velocity(linear_velocity, direction, speed, is_jump_interrupted):
	var velocity = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y *= 0.6
	return velocity
