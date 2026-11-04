extends State

func enter(previous_state_path: String, data := {}) -> void:
	#future animation
	pass
 
 
func physics_update(delta: float) -> void:
	player.apply_horizontal_movement(Vector3.ZERO, 0.0, delta)
	player.apply_gravity(delta)
	player.move_and_slide()
 
	if player.try_jump():
		finished.emit(&"JumpState", {})
	elif not player.is_on_floor():
		finished.emit(&"FallState", {})
	elif player.has_move_input():
		finished.emit(&"MoveState", {})
