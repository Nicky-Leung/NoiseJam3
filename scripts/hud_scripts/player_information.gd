extends Control

@export var player: Player = null

@onready var health_bar = %HealthBar
@onready var battery_bar = %BatteryBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = player.max_health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	health_bar.value = player.health
	# battery_bar.value = player.battery
