extends AudioStreamPlayer2D

@export var step_collection: Array[AudioStream]
@onready var timer: Timer = $Timer
@onready var alerter: EnemyAlerter = $EnemyAlerter

var area_tween: Tween = null

func play_steps(speed: float, custom_delay: float = -1) -> void:
    if speed == 0:
        if area_tween != null: area_tween.kill()
        area_tween = create_tween()
        area_tween.tween_property(alerter.shape, "radius", 0, timer.time_left)
        area_tween.play()
        return
    if timer.time_left > 0: return

    # determine gap between steps
    var delay = custom_delay if custom_delay > 0 else 50 / speed
    timer.wait_time = delay
    timer.start()

    # play audio
    stream = step_collection.pick_random()
    HELPERS.play_audio(self, 0.9, 1.1, -10 - speed / 10)

    # expand noise alerter size
    area_tween = create_tween()
    area_tween.tween_property(alerter.shape, "radius", speed * 1.25, delay / 2)
    area_tween.tween_property(alerter.shape, "radius", 0, delay / 2)
    area_tween.play()