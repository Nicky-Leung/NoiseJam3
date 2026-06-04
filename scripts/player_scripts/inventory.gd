extends Control
class_name Inventory

const key_item_desc: String = "Perhaps this could be used somewhere?"
const medkit_desc: String = "Use to fully heal health"
const battery_desc: String = "Use to refill flashlight charge"
const trap_desc: String = "Use to drop a trap directly under you"

# Starting variables
@export var transitions_time: float = 0.25
@export var max_batteries: int = 3
@export var max_medkits: int = 3
@export var max_traps: int = 1

# Components
@onready var name_label = $Name
@onready var desc_label = $Description
@onready var left_icon = $Container/Item1/Icon
@onready var middle_icon = $Container/Item2/Icon
@onready var right_icon = $Container/Item3/Icon

# Run time variables
var key_items: Array[Dictionary] # Should be String/Texture pair, for key_item name and associated sprite
var selected: String = ""
var running_tween: Tween = null
var is_open: bool:
	get: return visible

func _ready():
	visible = false
	left_icon.scale = Vector2.ONE * 0.5
	right_icon.scale = Vector2.ONE * 0.5

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(INPUTS.INVENTORY):
		if is_open: close()
		else: open()

	if !is_open: return
	if Input.is_action_just_pressed(INPUTS.EXIT): close()

# Tween functions
func open():
	if running_tween && running_tween.is_running(): return
	var original_pos = position
	position.y = 1200
	visible = true

	running_tween = create_tween()
	running_tween.tween_property(self, "position", original_pos, transitions_time)
	running_tween.tween_callback(func():
		name_label.visible = true
		desc_label.visible = true
	)
	running_tween.play()

func close():
	if running_tween && running_tween.is_running(): return
	var original_pos = position
	name_label.visible = false
	desc_label.visible = false

	running_tween = create_tween()
	running_tween.tween_property(self, "position", original_pos + Vector2.DOWN * 1200, transitions_time)
	running_tween.tween_callback(func():
		visible = false
		position = original_pos
	)
	running_tween.play()
