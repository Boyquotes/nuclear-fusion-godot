extends "res://StateMachine.gd"

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent._update_move_direction()
	parent._update_wall_direction()
	if state != states.wall_slide:
		parent._handle_movement()
	parent._apply_gravity(delta)
	parent._apply_movement()
	
func _input(event):
	if [states.idle, states.run, states.wall_slide].has(state):
		if event.is_action_pressed("jump"):
			parent.velocity.y = parent.max_jump_velocity
			parent.is_jumping = true
	if state == states.jump:
		if event.is_action_released("jump") && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity
	
func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.wall_direction != 0:
				return states.wall_slide
			elif parent.velocity.y >= 0:
				return states.fall
			elif parent.is_grounded:
				return states.idle
		states.fall:
			if parent.wall_direction != 0:
				return states.wall_slide
			elif parent.is_grounded:
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		states.wall_slide:
			if parent.wall_direction == 0:
				if parent.is_grounded:
					if parent.velocity.x != 0:
						return states.run
					return states.idle
				elif parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
			if parent.is_grounded:
				if parent.velocity.x != 0:
					return states.run
				return states.idle
	
	return null
	
func _enter_state(new_state, old_state):
	match new_state:
		states.wall_slide:
			parent.sprite.scale.x = -parent.wall_direction
	
func _exit_state(old_state, new_state):
	pass
