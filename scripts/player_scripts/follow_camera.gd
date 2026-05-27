extends Camera2D

const default_zoom = 1.75

@export var offset_amount: float = 70
@export var offset_speed: float = 5

const x_threshold = 150
const y_threshold = 100

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
	if mouse_out_of_range(): offset_dir = global_position.direction_to(get_global_mouse_position())
	else: offset_dir = Vector2.ZERO
	offset = offset.lerp(offset_dir * offset_amount, offset_speed * delta)

func mouse_out_of_range() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	return (
		mouse_pos.x < x_threshold
		|| mouse_pos.x > viewport_size.x - x_threshold
		|| mouse_pos.y < y_threshold
		|| mouse_pos.y > viewport_size.y - y_threshold
	)