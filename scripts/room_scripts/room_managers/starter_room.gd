extends Node2D

@export var player: Player = null

@onready var room_listener: RoomListener = $Layout/RoomListener
@onready var cinematic: StartCinematic = $Cinematic

func _ready():
	player.disable_inputs(true)
	cinematic.finish_cinematic.connect(_on_finished_cinematic)
	cinematic.play_sequence()

func _on_finished_cinematic():
	player.disable_inputs(false)
