extends CanvasLayer

@export_multiline var report_text: String = ""
@onready var label: RichTextLabel = $Label

var readable_layer: CanvasLayer = null

func _ready():
	label.text = report_text
	readable_layer = owner.get_parent()
	visible = false
	readable_layer.visibility_changed.connect(_on_visible_changed)
	set_process_input(false)

func _input(_event: InputEvent):
	if !readable_layer.visible: return
	if Input.is_action_just_pressed(INPUTS.INTERACT):
		visible = !visible

func _on_visible_changed():
	set_process_input(readable_layer.visible)
	visible = false
