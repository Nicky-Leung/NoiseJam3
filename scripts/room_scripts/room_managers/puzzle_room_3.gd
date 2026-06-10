extends Node2D

@export var gate_layer: TileMapLayer = null

@onready var wall_layer: TileMapLayer = $Layout/Walls
@onready var room_listener: RoomListener = $Layout/RoomListener
@onready var cage_area: Area2D = $Layout/DungeonArea
@onready var gate_switch: Interactable = $Computer/Interactable

@onready var gate_cd: Timer = $Timers/GateCD

@onready var alarm: AudioStreamPlayer2D = $Sounds/Alarm
@onready var gate_noise: AudioStreamPlayer2D = $Sounds/Gate
@onready var gate_error: AudioStreamPlayer2D = $Sounds/GateError

var enemy_in_cage: bool = true
var cage_locked: bool = true

func _ready():
	cage_area.body_entered.connect(func(body): _on_cage_change(body, true))
	cage_area.body_exited.connect(func(body): _on_cage_change(body, false))
	gate_switch.interacted.connect(_on_gate_switch_pressed)

func _on_player_entered():
	pass # enable the enemy

func _on_player_exited():
	pass # disable the enemy

func _on_cage_change(body: Node2D, entered: bool):
	if body is not Titania: return
	enemy_in_cage = entered

func _on_gate_switch_pressed(_player: Player):
	if gate_cd.time_left > 0:
		HELPERS.play_audio(gate_error, 1.1, 1.2, -5)
		return

	gate_cd.start()
	cage_locked = !cage_locked
	gate_layer.enabled = cage_locked
	HELPERS.play_audio(alarm)
	HELPERS.play_audio(gate_noise, 0.9, 1.1, -5)