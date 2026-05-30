extends PointLight2D

@onready var base_energy = energy
@onready var cd_timer: Timer = $Cooldown
@onready var audio_player = $Click
@onready var enemy_alerter = $EnemyAlerter
@onready var is_on: bool:
	get: return visible

func _physics_process(_delta: float) -> void:
	if !visible: return
	if Engine.get_process_frames() % 5 == 0: try_flicker() # call every 5th frame

func try_flicker():
	energy = base_energy
	if randf() < 0.95: return
	energy = base_energy - randf() * 2

func toggle() -> void:
	if cd_timer.time_left > 0:
		return

	HELPERS.play_audio(audio_player, 0.95, 1.05)
	visible = !visible
	enemy_alerter.enable(visible)
	cd_timer.start()