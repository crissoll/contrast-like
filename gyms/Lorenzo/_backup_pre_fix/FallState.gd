extends State
var previous_state : String = &"" 

func enter(previous_state_path: String, data := {}) -> void:
	#future animation
	print("fall ")
	previous_state = previous_state_path
	pass
 
 
func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()
	player.apply_air_movement(dir, player.walk_speed, delta)
	player.rotate_visuals_towards(dir, delta)
	player.apply_gravity(delta)
	player.move_and_slide()
 	
	check_landing()
	if !player.is_on_floor():
		if previous_state == &"MoveState" or previous_state == &"IdleState":
			if player.try_jump():
				finished.emit(&"JumpState")
		elif previous_state == &"JumpState":
			if player.wants_jump():
				finished.emit(&"DoubleJumpState", {})
