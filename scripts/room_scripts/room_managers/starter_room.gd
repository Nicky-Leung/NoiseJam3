extends Node2D
class_name StarterRoom

@export var player: Player = null
@export var required_pickups: Array[Node2D] = []
@export var gate_tile_coords: Array[Vector2i] = []

@onready var censored_sin = $CensoredSin
@onready var obstacles_tile_map: TileMapLayer = $Layout/Obstacles
@onready var room_listener: RoomListener = $Layout/RoomListener
@onready var open_sfx: AudioStreamPlayer2D = $Sounds/Open
@onready var cinematic: StartCinematic = $Cinematic

signal initiate_ending

func _ready():
	player.disable_inputs(true)
	cinematic.finish_cinematic.connect(_on_finished_cinematic)
	censored_sin.uncensored_interacted.connect(func(): initiate_ending.emit())
	for pickup in required_pickups:
		pickup.tree_exiting.connect(func():
			required_pickups.remove_at(required_pickups.find(pickup))
			try_unlock_door()
		)
	cinematic.play_sequence()

func uncensor_sin():
	censored_sin.uncensor()

func try_unlock_door():
	if required_pickups.size() > 0: return
	HELPERS.play_audio(open_sfx)
	for coord in gate_tile_coords:
		obstacles_tile_map.erase_cell(coord)

func _on_finished_cinematic():
	player.disable_inputs(false)
