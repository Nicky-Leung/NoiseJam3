extends Node2D

@export var gate_tiles: Array[Vector2i] = []

@onready var room_listener: RoomListener = $Layout/RoomListener
@onready var cage_area: Area2D = $Layout/DungeonArea
@onready var gate_switch: Interactable = $Computer/Interactable
@onready var alarm: AudioStreamPlayer2D = $Sounds/Alarm

var enemy_in_cage: bool = true

func _ready():
	cage_area.body_entered.connect(func(body): _on_cage_change(body, true))
	cage_area.body_exited.connect(func(body): _on_cage_change(body, false))
	gate_switch.interacted.connect(_on_gate_switch_pressed)

func _on_player_entered():
	pass # enable the enemy

func _on_player_exited():
	pass # disable the enemy

func _on_cage_change(body: Node2D, entered: bool):
	if body is not Lamb: return
	enemy_in_cage = entered

func _on_gate_switch_pressed():
	HELPERS.play_audio(alarm)
	pass # change tiles at gate tiles to invisible and de-activate collision on them
