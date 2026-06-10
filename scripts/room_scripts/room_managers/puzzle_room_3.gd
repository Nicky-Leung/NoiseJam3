extends Node2D

signal diamond_collected

@export var cage_gate_layer: TileMapLayer = null
@export var room_gate_layer: TileMapLayer = null
@export var required_pickups: Array[Node2D] = []

@onready var gas_mechanic: Gas = $GasMechanic
@onready var titania: Titania = $Titania
@onready var wall_layer: TileMapLayer = $Layout/Walls
@onready var room_listener: RoomListener = $Layout/RoomListener
@onready var cage_area: Area2D = $Layout/DungeonArea
@onready var gate_switch: Interactable = $Layout/Computer/Interactable
@onready var gate_cd: Timer = $Timers/GateCD
@onready var alarm: AudioStreamPlayer2D = $Sounds/Alarm
@onready var gate_noise: AudioStreamPlayer2D = $Sounds/Gate
@onready var gate_error: AudioStreamPlayer2D = $Sounds/GateError

var enemy_in_cage: bool = true
var cage_locked: bool = true

func _ready():
	room_listener.player_entered.connect(_on_player_entered)
	room_listener.player_entered.connect(_on_player_exited)
	cage_area.body_entered.connect(func(body): _on_cage_change(body, true))
	cage_area.body_exited.connect(func(body): _on_cage_change(body, false))
	gate_switch.interacted.connect(_on_gate_switch_pressed)

	for pickup in required_pickups:
		pickup.tree_exiting.connect(func():
			required_pickups.remove_at(required_pickups.find(pickup))
			diamond_collected.emit()
		)

func _on_player_entered(player: Player):
	titania.toggle_active(true)
	titania.player = player
	gas_mechanic.player = player

func _on_player_exited(_player: Player):
	titania.toggle_active(false)

func _on_cage_change(body: Node2D, entered: bool):
	if body is not Titania: return
	enemy_in_cage = entered

func _on_gate_switch_pressed(_player: Player):
	if gate_cd.time_left > 0:
		HELPERS.play_audio(gate_error, 1.1, 1.2, -5)
		return

	gate_cd.start()
	HELPERS.play_audio(gate_noise, 0.9, 1.1, -5)

	cage_locked = !cage_locked
	cage_gate_layer.enabled = cage_locked
	room_gate_layer.enabled = !(cage_locked && enemy_in_cage)
	if room_gate_layer.enabled:
		HELPERS.play_audio(alarm)
		gas_mechanic.start_gas()
	else:
		alarm.stop()
		gas_mechanic.stop_gas()
