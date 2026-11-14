extends State

func enter(_previous_state: States, _data := {}) -> void:
	print("moving")
	#future animation
	pass


func physics_update(_delta: float) -> void:
	if player.try_jump():
		transition_to(States.JUMP)
	elif not player.is_on_floor():
		transition_to(States.FALL)
	elif player.get_horizontal_speed() < 0.5 and not player.has_move_input():
		transition_to(States.IDLE)
