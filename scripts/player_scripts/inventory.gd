extends Control

enum ItemType {
	CONSUMABLE, # items that are used
	KEY_ITEM # items required for puzzle
}

const key_item_desc: String = "Perhaps this could be used somewhere?"
const medkit_desc: String = "Use to fully heal health"
const battery_desc: String = "Use to refill flashlight charge"
const trap_desc: String = "Use to drop a trap directly under you"

# Start stats
@export var transitions_time: float = 0.25

# Components
@onready var type_label = $Type
@onready var desc_label = $Description
@onready var left_icon = $Container/Item1/Icon
@onready var middle_icon = $Container/Item2/Icon
@onready var right_icon = $Container/Item3/Icon

# Run time variables
var selected: String = ""
var running_tween: Tween = null
var is_open: bool:
	get: return visible

func _ready():
	visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(INPUTS.INVENTORY):
		if is_open: close()
		else: open()

	if !is_open: return
	
	if Input.is_action_just_pressed(INPUTS.EXIT): close()

func open():
	if running_tween && running_tween.is_running(): return
	var original_pos = position
	position.y = 1200
	visible = true

	running_tween = create_tween()
	running_tween.tween_property(self, "position", original_pos, transitions_time)
	running_tween.tween_callback(func():
		type_label.visible = true
		desc_label.visible = true
	)
	running_tween.play()

func close():
	if running_tween && running_tween.is_running(): return
	var original_pos = position
	type_label.visible = false
	desc_label.visible = false

	running_tween = create_tween()
	running_tween.tween_property(self, "position", original_pos + Vector2.DOWN * 1200, transitions_time)
	running_tween.tween_callback(func():
		visible = false
		position = original_pos
	)
	running_tween.play()
