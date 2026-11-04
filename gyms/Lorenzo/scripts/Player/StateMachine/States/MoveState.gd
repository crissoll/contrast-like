extends State

func enter(previous_state_path: String, data := {}) -> void:
	#future animation
	pass
 
 
func physics_update(delta: float) -> void:
	var raw_input : Vector2 = player.get_input_vector()
	player.apply_horizontal_movement((Vector3(raw_input.x,0,raw_input.y)), player.walk_speed, delta)
	player.apply_gravity(delta)
	player.move_and_slide()
 
	if player.try_jump():
		finished.emit(&"JumpState", {})
	elif not player.is_on_floor():
		finished.emit(&"FallState", {})
	elif player.has_move_input():
		finished.emit(&"MoveState", {})
