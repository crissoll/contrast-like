class_name State
extends Node

signal finished(next_state_path: String, data: Dictionary)

## State node names, use these instead of writing the strings by hand.
const IDLE := &"IdleState"
const MOVE := &"MoveState"
const JUMP := &"JumpState"
const FALL := &"FallState"
const DOUBLE_JUMP := &"DoubleJumpState"


var gravity_scale := 1.0
@export_group("")
var overwrite_gravity := false

enum MovementModes {
	GROUNDED,
	AIR,
}
@export
var movement_mode : MovementModes = MovementModes.GROUNDED

var player : Player

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass


## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass


## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass


## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	pass


## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass


## Asks the state machine to switch state. The switch happens immediately
## (signals are synchronous), so return right after calling it.
func transition_to(state_name: StringName, data := {}) -> void:
	finished.emit(state_name, data)


## If the player is on the floor, switches to Move or Idle and returns true.
## Usage: `if check_landing(): return`
func check_landing() -> bool:
	if not player.is_on_floor():
		return false
	transition_to(MOVE if player.has_move_input() else IDLE)
	return true
