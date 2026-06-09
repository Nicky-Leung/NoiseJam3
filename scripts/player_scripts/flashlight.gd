extends PointLight2D

@export var clickSFX: AudioStream = null
@export var dieSFX: AudioStream = null
@export var refillSFX: AudioStream = null

# starting stats
@export var max_battery_seconds: float = 60 * 3
@export var refill_time: float = 1.5
@export var show_sprite: bool = false
@export var infinite_battery: bool = false

# Components
@onready var cd_timer: Timer = $Cooldown
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var enemy_alerter: EnemyAlerter = $EnemyAlerter

# stats
@onready var base_energy = energy
@onready var is_on: bool:
	get: return visible

# Running variables
var is_refilling: bool = false
var battery_time: float = max_battery_seconds

func _ready():
	get_node("Sprite").visible = show_sprite

func _physics_process(delta: float) -> void:
	if !visible: return
	if Engine.get_process_frames() % 5 == 0: try_flicker()
	if infinite_battery: return

	battery_time -= delta
	if battery_time <= 0: disable_light()

func try_flicker():
	energy = base_energy
	var no_flicker_chance = 0.95 - (1 - battery_time / max_battery_seconds) * 0.45 # flicker more when low battery
	if randf() < no_flicker_chance: return
	energy = base_energy - randf() * 2

func refill_battery():
	is_refilling = true
	audio_player.stream = refillSFX
	HELPERS.play_audio(audio_player, 0.7, 0.8, -10)

	if visible: # turn off flashlight when needing to refill
		visible = false
		enemy_alerter.enable(false)

	# do the refill
	var tween = create_tween()
	tween.tween_interval(refill_time)
	tween.tween_callback(func():
		battery_time = max_battery_seconds
		is_refilling = false
		toggle()
	)
	tween.play()

func toggle() -> void:
	if cd_timer.time_left > 0 || battery_time <= 0 || is_refilling: return

	audio_player.stream = clickSFX
	HELPERS.play_audio(audio_player, 0.95, 1.05)
	visible = !visible
	enemy_alerter.enable(visible)
	cd_timer.start()

func disable_light() -> void:
	visible = false
	audio_player.stream = dieSFX
	HELPERS.play_audio(audio_player)
	enemy_alerter.enable(false)