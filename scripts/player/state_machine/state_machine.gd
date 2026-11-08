class_name StateMachine extends Node

## Emitted right after a state transition.
signal state_changed(previous_state: State, new_state: State)

## The initial state of the state machine. If not set, the first child node is used.
@export var initial_state: State = null

## The current state of the state machine.
@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

var player: Player

func _ready() -> void:
	player = owner as Player
	# Connect to every state's finished signal to transition to the next state.
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
		state_node.player = player
	# State machines usually access data from the root node of the scene they're part of: the owner.
	# We wait for the owner to be ready to guarantee all the data and nodes the states may need are available.
	# If the owner is already ready, awaiting the signal would hang forever.
	if not owner.is_node_ready():
		await owner.ready
	state.enter("")


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	# Timers first, so every state reads up-to-date coyote / jump buffer values
	# regardless of the node order in the tree.
	if player:
		player.update_timers(delta)
	state.physics_update(delta)
	
	var dir := player.get_move_direction()
	
	if state.movement_mode == State.MovementModes.GROUNDED:
		player.apply_horizontal_movement(dir,player.walk_speed,delta)
	elif state.movement_mode == State.MovementModes.AIR:
		player.apply_air_movement(dir, player.walk_speed, delta)
	
	player.apply_gravity(delta,state.gravity_scale)
	
	player.rotate_visuals_towards(dir, delta)
	
	player.move_and_slide()


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state := state
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state.name, data)
	state_changed.emit(previous_state, state)
