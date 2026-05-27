extends PointLight2D

signal coverage_changed(is_active: bool, center: Vector2, radius: float, bounds: Rect2)


@onready var cd_timer: Timer = $Cooldown
@onready var is_on: bool:
	get: return visible

func _physics_process(delta: float) -> void:
	if visible:
		_emit_coverage(true)
	

func toggle() -> void:
	if cd_timer.time_left > 0:
		return

	# add click noise later
	visible = !visible
	_emit_coverage(visible)
	cd_timer.start()
	
func _emit_coverage(is_active: bool) -> void:
	var center: Vector2 = _get_light_center_global()
	var radius: float = _get_light_radius_global()
	var bounds := Rect2(center - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0))
	coverage_changed.emit(is_active, center, radius, bounds)

func _get_light_center_global() -> Vector2:
	var light_offset: Vector2 = offset * global_scale
	return global_position + light_offset.rotated(global_rotation)

func _get_light_radius_global() -> float:
	if texture == null:
		return 0.0

	var texture_size: Vector2 = texture.get_size()
	var half_max_extent: float = maxf(texture_size.x, texture_size.y) * 0.5
	var scale_factor: float = maxf(absf(global_scale.x), absf(global_scale.y))
	return half_max_extent * texture_scale * scale_factor