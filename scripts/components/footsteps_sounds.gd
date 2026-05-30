extends AudioStreamPlayer2D

@export var step_collection: Array[AudioStream]
@export var alerter: EnemyAlerter = null
@onready var timer: Timer = $Timer

var area_tween: Tween = null

func play_steps(speed: float, custom_delay: float = -1, custom_lower: float = 0.9, custom_higher: float = 1.1) -> void:
	if speed == 0:
		cancel_emit()
		return
	if timer.time_left > 0: return

	# determine gap between steps
	var delay = custom_delay if custom_delay > 0 else 50 / speed
	timer.wait_time = delay
	timer.start()

	# play audio
	stream = step_collection.pick_random()
	HELPERS.play_audio(self, custom_lower, custom_higher, -5 - 10 / speed)

	# expand noise alerter size
	if alerter != null: emit_area(delay, speed)

func cancel_emit():
	if alerter == null: return
	if area_tween != null: area_tween.kill()
	area_tween = create_tween()
	area_tween.tween_property(alerter.shape, "radius", 0, timer.time_left)
	area_tween.play()

func emit_area(delay: float, speed: float):
	if alerter == null: return
	area_tween = create_tween()
	area_tween.tween_property(alerter.shape, "radius", speed * 1.25, delay / 2)
	area_tween.tween_property(alerter.shape, "radius", 0, delay / 2)
	area_tween.play()
