extends Node2D

const north_key_name: String = "North Key"
const east_key_name: String = "East Key"

@onready var north_gate: TileMapLayer = $Layout/NorthGate
@onready var north_trigger: Interactable = %NorthTrigger
@onready var east_gate: TileMapLayer = $Layout/EastGate
@onready var east_trigger: Interactable = %EastTrigger
@onready var gate_sound: AudioStreamPlayer2D = $Sounds/GateSound

func _ready():
    north_trigger.interacted.connect(func(node): try_open_gate(node as Player, north_key_name))
    east_trigger.interacted.connect(func(node): try_open_gate(node as Player, east_key_name))

func try_open_gate(player: Player, key_name_check: String):
    if !player.inventory.has_key_item(key_name_check):
        player.hud.display_flavor_text(north_trigger.description) # Both desc should be the same
        return
    player.inventory.remove_key_item(key_name_check)
    gate_sound.global_position = north_gate.global_position if key_name_check == north_key_name else east_gate.global_position
    HELPERS.play_audio(gate_sound)
    if key_name_check == north_key_name:
        north_gate.enabled = false
        north_trigger.enable(false)
    elif key_name_check == east_key_name:
        east_gate.enabled = false
        east_trigger.enable(false)