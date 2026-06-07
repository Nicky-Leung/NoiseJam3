extends Node2D

# Components
@onready var north_grate: Area2D = $North # 1
@onready var south_grate: Area2D = $South # 2
@onready var east_grate: Area2D = $East # 3
@onready var west_grate: Area2D = $West # 4
@onready var unlock_key: Pickup = $Pickup

# Run time variables
var current_grate_number: int = 0
var is_completed: bool = false

# solution order -> N, S, E, W
func _ready():
    north_grate.body_entered.connect(func(body: Node2D): on_grate_entered(body, 1))
    south_grate.body_entered.connect(func(body: Node2D): on_grate_entered(body, 2))
    east_grate.body_entered.connect(func(body: Node2D): on_grate_entered(body, 3))
    west_grate.body_entered.connect(func(body: Node2D): on_grate_entered(body, 4))
    unlock_key.visible = false

func on_grate_entered(body: Node2D, grate_number: int):
    if body is not Player || current_grate_number == grate_number || is_completed: return

    var is_correct_order = grate_number - current_grate_number == 1
    current_grate_number = grate_number if is_correct_order else 0
    # if correct, player correct sound
    # if incorrect, play incorrect sound

    if current_grate_number != 4: return
    is_completed = true
    unlock_key.visible = true
    unlock_key.allow_pickup(true)