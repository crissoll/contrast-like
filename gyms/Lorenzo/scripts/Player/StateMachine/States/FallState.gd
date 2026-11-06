extends State

func enter(previous_state_path: String, data := {}) -> void:
	#future animation
	print("fall ")
	pass
 
 
func physics_update(delta: float) -> void:
	player.apply_horizontal_movement(Vector3.ZERO, 0.0, delta)
	player.apply_gravity(delta)
	player.move_and_slide()
 
	if player.try_jump():
		print("double jump")
		finished.emit(&"JumpState", {})
	elif player.has_move_input():
		print("trying to move in air")
		finished.emit(&"MoveState", {})
	else:
		print("NONE")
