extends State
@export var strength_jump : float = 1.8
var has_jumped : bool = false

func enter(previous_state_path: String, data := {}) -> void:
	has_jumped = false
	print("double jump")
	#future animation
	pass
 
 
func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()
	player.apply_air_movement(dir, player.walk_speed, delta)
	if has_jumped == false:
		player.jump(strength_jump)
		has_jumped = true
	player.apply_gravity(delta)
	player.rotate_visuals_towards(dir, delta)
	player.move_and_slide()
 	
	check_landing()
	if not player.is_on_floor() and player.velocity.y <= 0:
		finished.emit(&"FallState", {})
