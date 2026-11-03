extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera_handler: CompCameraHandler = $CameraHandler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_handler.target = player.get_node("CameraTarget")
	player.camera_handler = camera_handler


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
