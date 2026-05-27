extends PointLight2D

signal coverage_changed(is_active: bool, center: Vector2, radius: float, bounds: Rect2)

@onready var base_energy = energy
@onready var cd_timer: Timer = $Cooldown
@onready var audio_player = $Click
@onready var is_on: bool:
	get: return visible

func _physics_process(_delta: float) -> void:
	if !visible: return
	_emit_coverage(true)
	if Engine.get_process_frames() % 5 == 0: try_flicker()

func try_flicker():
	energy = base_energy
	if randf() < 0.95: return
	energy = base_energy - randf() * 2

func toggle() -> void:
	if cd_timer.time_left > 0:
		return

	HELPERS.play_audio(audio_player, 0.95, 1.05)
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