extends Control
class_name Inventory

const key_item_desc: String = "Perhaps this could be used somewhere?"
const medkit_name: String = "MedKit"
const medkit_desc: String = "Use to fully heal health"
const battery_name: String = "Battery"
const battery_desc: String = "Use to refill flashlight charge"
const trap_name: String = "Trap"
const trap_desc: String = "Use to drop a trap directly under you"

@export var medkit_sprite: Texture2D = null
@export var battery_sprite: Texture2D = null
@export var trap_sprite: Texture2D = null

# Starting variables
@export var transitions_time: float = 0.25
@export var max_batteries: int = 3
@export var max_medkits: int = 2
@export var max_traps: int = 1

# Components
@onready var name_label: Label = $Name
@onready var desc_label: Label = $Description
@onready var container: HBoxContainer = $Container
@onready var left_icon: TextureRect = $Container/Item1/Icon
@onready var middle_icon: TextureRect = $Container/Item2/Icon
@onready var right_icon: TextureRect = $Container/Item3/Icon

# Run time variables
var move_length: int = 0
var running_tween: Tween = null
var key_items: Dictionary[String, Texture] = {} # Name of key item + sprite of key item
var selected: String = ""
var is_open: bool:
	get: return visible

var medkit_count: int = 0
var battery_count: int  = 0
var trap_count: int = 0

func _ready():
	visible = false
	left_icon.scale = Vector2.ONE * 0.5
	right_icon.scale = Vector2.ONE * 0.5
	move_length = left_icon.get_parent().custom_minimum_size.x + container.get_theme_constant("separation", "BoxContainer")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(INPUTS.INVENTORY):
		if is_open: close()
		else: open()

	if !is_open: return
	if Input.is_action_just_pressed(INPUTS.EXIT): close()
	if Input.is_action_just_pressed(INPUTS.LEFT): cycle_left()
	if Input.is_action_just_pressed(INPUTS.RIGHT): cycle_right()

# Inventory functions
func add_key_item(key_item_name: String, sprite: Texture):
	key_items[key_item_name] = sprite

func remove_key_item(key_item_name: String):
	key_items.erase(key_item_name)

func try_change_medkit(is_adding: bool) -> bool:
	if is_adding:
		if medkit_count == max_medkits:
			return false
		medkit_count += 1
		return true
	else:
		if medkit_count <= 0:
			return false
		medkit_count -= 1
		return true

func try_change_battery(is_adding: bool) -> bool: # assumes items on floor only ever 1
	if is_adding:
		if battery_count == max_batteries:
			# add some ui on screen saying inventory full
			return false
		battery_count += 1
		return true
	else:
		if battery_count <= 0:
			return false
		battery_count -= 1
		return true

func try_change_trap(is_adding: bool) -> bool:
	if is_adding:
		if trap_count == max_traps:
			return false
		trap_count += 1
		return true
	else:
		if trap_count <= 0:
			return false
		trap_count -= 1
		return true

# Helper functions
func _get_description(item_name: String) -> String:
	if item_name == medkit_name: return medkit_desc
	elif item_name == battery_name: return battery_desc
	elif item_name == trap_name: return trap_desc
	return key_item_desc

func _get_consumable_max(item_name: String) -> int:
	if item_name == medkit_name: return max_medkits
	elif item_name == battery_name: return battery_count
	elif item_name == trap_name: return trap_count
	return 0

# Tween functions -> do animations first, then figure out logic on how to cycle btn everything
func cycle_left():
	if running_tween && running_tween.is_running(): return
	# duplicate icons
	var L = left_icon.duplicate()
	var M = middle_icon.duplicate()
	var R = right_icon.duplicate()
	L.position = left_icon.get_parent().position
	M.position = middle_icon.get_parent().position
	R.position = right_icon.get_parent().position
	add_child(L)
	add_child(M)
	add_child(R)

	# set underlying icons
	get_node("Container").visible = false
	var R_texture = right_icon.texture
	right_icon.texture = middle_icon.texture
	middle_icon.texture = left_icon.texture
	left_icon.texture = R_texture

	# do animations with duplicates
	running_tween = create_tween()
	running_tween.set_parallel(true)
	running_tween.tween_property(L, "position", L.position + Vector2.RIGHT * move_length, transitions_time / 2)
	running_tween.tween_property(L, "scale", Vector2.ONE, transitions_time / 2)
	running_tween.tween_property(M, "position", M.position + Vector2.RIGHT * move_length, transitions_time / 2)
	running_tween.tween_property(M, "scale", Vector2.ONE * 0.5, transitions_time / 2)
	running_tween.tween_property(R, "position", R.position + Vector2.RIGHT * move_length, transitions_time / 2)
	running_tween.tween_property(R, "scale", Vector2.ZERO, transitions_time / 2)
	running_tween.set_parallel(false)
	running_tween.tween_callback(func():
		get_node("Container").visible = true
		L.queue_free()
		M.queue_free()
		R.queue_free()
	)
	running_tween.play()

func cycle_right():
	if running_tween && running_tween.is_running(): return
	# duplicate icons
	var L = left_icon.duplicate()
	var M = middle_icon.duplicate()
	var R = right_icon.duplicate()
	L.position = left_icon.get_parent().position
	M.position = middle_icon.get_parent().position
	R.position = right_icon.get_parent().position
	add_child(L)
	add_child(M)
	add_child(R)

	# set underlying icons
	get_node("Container").visible = false
	var L_texture = left_icon.texture
	left_icon.texture = middle_icon.texture
	middle_icon.texture = right_icon.texture
	right_icon.texture = L_texture

	# do animations with duplicates
	running_tween = create_tween()
	running_tween.set_parallel(true)
	running_tween.tween_property(L, "position", L.position + Vector2.LEFT * move_length, transitions_time / 2)
	running_tween.tween_property(L, "scale", Vector2.ZERO, transitions_time / 2)
	running_tween.tween_property(M, "position", M.position + Vector2.LEFT * move_length, transitions_time / 2)
	running_tween.tween_property(M, "scale", Vector2.ONE * 0.5, transitions_time / 2)
	running_tween.tween_property(R, "position", R.position + Vector2.LEFT * move_length, transitions_time / 2)
	running_tween.tween_property(R, "scale", Vector2.ONE, transitions_time / 2)
	running_tween.set_parallel(false)
	running_tween.tween_callback(func():
		get_node("Container").visible = true
		L.queue_free()
		M.queue_free()
		R.queue_free()
	)
	running_tween.play()

func open():
	if running_tween && running_tween.is_running(): return
	var original_pos = position
	position.y = original_pos.y + 400
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
	running_tween.tween_property(self, "position", original_pos + Vector2.DOWN * 400, transitions_time)
	running_tween.tween_callback(func():
		visible = false
		position = original_pos
	)
	running_tween.play()
