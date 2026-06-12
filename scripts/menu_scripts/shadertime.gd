extends ColorRect

func _ready():
	if material:
		material.set_shader_parameter("TIME", 0.0)

func _process(delta):
	if material:
		var current_time = material.get_shader_parameter("TIME")
		material.set_shader_parameter("TIME", current_time + delta)
