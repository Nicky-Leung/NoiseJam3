extends Node
class_name Gas

@export var gas_sound: AudioStreamPlayer2D = null
@export var gas_shader: ColorRect = null
@export var damage_timer: Timer = null
@export var time_before_damage_starts: float = 7
@export var damage_per_tick: int = 2

# Runtime variables
var player: Player = null # expected to be set by the room
var gas_released_time: float = 0
var is_running: bool = false

func _ready():
	damage_timer.timeout.connect(_damage_player)

func _physics_process(delta):
	if !is_running: return

	gas_released_time += delta
	if gas_released_time > time_before_damage_starts && damage_timer.is_stopped(): damage_timer.start()
	gas_shader.material.set_shader_parameter("density", min(gas_released_time, time_before_damage_starts) / time_before_damage_starts / 2)

func start_gas():
	if is_running: return # don't do anything if already running
	is_running = true
	gas_released_time = 0
	HELPERS.play_audio(gas_sound, 0, 0, -10)

func stop_gas():
	is_running = false
	damage_timer.stop()

	var tween = create_tween()
	tween.tween_property(gas_sound, "volume_db", -60, 2)
	tween.parallel().tween_method(
		func(value): gas_shader.material.set_shader_parameter("density", value),
		gas_shader.material.get_shader_parameter("density"), 0, 2
	)
	tween.tween_callback(func(): gas_sound.stop())
	tween.play()

func _damage_player():
	player.damage(damage_per_tick)
