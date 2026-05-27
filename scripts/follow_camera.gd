extends Camera2D

const default_zoom = 1.75

@export var offset_threshold: float = 120
@export var offset_amount: float = 70
@export var offset_speed: float = 5

func transition_zoom(amount = default_zoom, trans_time = 0.25):
	if trans_time <= 0:
		zoom = amount
		return
	var tween = create_tween()
	tween.tween_property(self, "zoom", amount, trans_time)
	tween.play()

func _physics_process(delta):
	# camera offsetting when moving mouse towards edge of screen
	var offset_dir
	if global_position.distance_to(get_global_mouse_position()) < offset_threshold: offset_dir = Vector2.ZERO
	else: offset_dir = global_position.direction_to(get_global_mouse_position())
	offset = offset.lerp(offset_dir * offset_amount, offset_speed * delta)