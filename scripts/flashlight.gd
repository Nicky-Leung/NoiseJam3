extends PointLight2D

@onready var cd_timer: Timer = $Cooldown
@onready var is_on: bool:
	get: return visible

func toggle() -> void:
	if cd_timer.time_left > 0:
		return

	# add click noise later
	visible = !visible
	cd_timer.start()