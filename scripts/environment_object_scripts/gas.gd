extends Node


@onready var timer: Timer = $Timer
@onready var gas: ColorRect = get_node("Shaders/Gas")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time_past: float = timer.time_left
	var percentage: float = 1- (time_past / timer.wait_time)
	gas.material.set_shader_parameter("density", percentage)
