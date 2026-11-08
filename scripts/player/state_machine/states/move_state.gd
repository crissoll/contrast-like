extends State

func enter(previous_state_path: String, data := {}) -> void:
	print("moving")
	#future animation
	pass


func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()

	if player.try_jump():
		transition_to(JUMP)
	elif not player.is_on_floor():
		transition_to(FALL)
	elif player.get_horizontal_speed() < 0.5 and not player.has_move_input():
		transition_to(IDLE)
