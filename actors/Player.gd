extends KinematicBody2D

signal grounded_updated(is_grounded)

const UP = Vector2(0, -1)
const SLOPE_STOP = 64
var velocity = Vector2()
var move_speed = 6 * Globals.UNIT_SIZE
var gravity
var max_jump_velocity
var min_jump_velocity
var wall_jump_velocity
var is_grounded
var is_jumping = false
var move_direction = 0
var wall_direction = 1

var max_jump_height = 4.5 * Globals.UNIT_SIZE
var min_jump_height = 0.75 * Globals.UNIT_SIZE
var jump_duration = 0.5


onready var sprite = $AnimatedSprite
onready var floor_raycasts = $FloorRaycasts
onready var left_wall_raycasts = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts = $WallRaycasts/RightWallRaycasts
onready var anim_player = $AnimationPlayer
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer

func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	wall_jump_velocity = Vector2(move_speed * 1.5, max_jump_velocity)
	
	Globals.player = self

func _physics_process(delta):
	pass
	
func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func _cap_gravity_wall_slide():
	var max_velocity = Globals.UNIT_SIZE if !Input.is_action_just_pressed("down") else 6 * Globals.UNIT_SIZE
	velocity.y = min(velocity.y, max_velocity)
	
func _apply_movement():
	if is_jumping && velocity.y >= 0:
		is_jumping = false
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	var was_grounded = is_grounded
	is_grounded = _check_is_grounded()
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)
		
func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
	
func _handle_movement():
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction != 0:
		sprite.scale.x = move_direction

func wall_jump():
	var vel = wall_jump_velocity
	vel.x *= -wall_direction
	velocity = vel

func jump():
	velocity.y = max_jump_velocity
	is_jumping = true

func _handle_wall_slide_sticking():
	if move_direction != 0 && move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()

func _get_h_weight():
	if is_grounded:
		return 0.4
	else:
		if move_direction == 0:
			return 0.02
		elif move_direction == sign(velocity.x) && abs(velocity.x) > move_speed:
			return 0.0
		else:
			return 0.1
	
func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	if is_near_wall_left && is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)

func _check_is_grounded():
	for raycast in floor_raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
	
func _check_is_valid_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55: # 60deg slope
				return true
	return false
	
func _assign_animation():
	var anim = "idle"
	if !is_grounded:
		anim = "jump"
	elif velocity.x != 0:
		anim = "run"
		
	if anim_player.assigned_animation != anim:
		anim_player.play(anim)
