extends Control
class_name Inventory

const key_item_desc: String = "Perhaps this could be used somewhere?"
const medkit_name: String = "MedKit"
const medkit_desc: String = "Use to heal to max health"
const battery_name: String = "Battery"
const battery_desc: String = "Use to refill flashlight charge"
const trap_name: String = "Trap"
const trap_desc: String = "Use to drop a trap directly under you"

# Signals
signal medkit_consumed
signal trap_consumed
signal battery_consumed

@export var medkit_sprite: Texture2D = null
@export var battery_sprite: Texture2D = null
@export var trap_sprite: Texture2D = null
@export var swipe_sound: AudioStream = null
@export var open_sound: AudioStream = null

# Starting variables
@export var container_sep: int = 50
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
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

# Run time variables
var move_length: int = 0
var running_tween: Tween = null
var items: Dictionary[String, Texture] = {} # Name of key item + sprite of key item
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
	move_length = left_icon.get_parent().custom_minimum_size.x + container_sep

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(INPUTS.INVENTORY):
		if is_open: close()
		else: open()

	if !is_open: return
	if Input.is_action_just_pressed(INPUTS.EXIT): close()
	if Input.is_action_just_pressed(INPUTS.LEFT): cycle_left()
	if Input.is_action_just_pressed(INPUTS.RIGHT): cycle_right()
	if Input.is_action_just_pressed(INPUTS.INTERACT): _use_selected()

# Inventory functions
func add_key_item(key_item_name: String, sprite: Texture) -> bool:
	items[key_item_name] = sprite
	return items.has(key_item_name)

func remove_key_item(key_item_name: String):
	items.erase(key_item_name)

func has_key_item(key_item_name: String):
	return items.has(key_item_name)

func try_change_medkit(is_adding: bool) -> bool:
	if is_adding:
		if medkit_count == max_medkits:
			return false
		medkit_count += 1
		if !items.has(medkit_name): items[medkit_name] = medkit_sprite
		return true
	else:
		if medkit_count <= 0:
			return false
		medkit_count -= 1
		if medkit_count == 0: items.erase(medkit_name)
		return true

func try_change_battery(is_adding: bool) -> bool:
	if is_adding:
		if battery_count == max_batteries:
			# add some ui on screen saying inventory full
			return false
		battery_count += 1
		if !items.has(battery_name): items[battery_name] = battery_sprite
		return true
	else:
		if battery_count <= 0:
			return false
		battery_count -= 1
		if battery_count == 0: items.erase(battery_name)
		return true

func try_change_trap(is_adding: bool) -> bool:
	if is_adding:
		if trap_count == max_traps:
			return false
		trap_count += 1
		if !items.has(trap_name): items[trap_name] = trap_sprite
		return true
	else:
		if trap_count <= 0:
			return false
		trap_count -= 1
		if trap_count == 0: items.erase(trap_name)
		return true

# Helper functions
func _use_selected():
	if selected == medkit_name:
		if try_change_medkit(false):
			medkit_consumed.emit()
			close()
	elif selected == trap_name:
		if try_change_trap(false):
			trap_consumed.emit()
			close()
	elif selected == battery_name:
		if try_change_battery(false):
			battery_consumed.emit()
			close()

func _set_items(direction: int): # -ve for left, 0 for no move, +ve for right
	if items.size() == 0:
		selected = ""
		name_label.text = ""
		desc_label.text = ""
		left_icon.texture = null
		right_icon.texture = null
		middle_icon.texture = null
		return

	var previous_selected = selected
	var keys = items.keys()
	var prev_index = keys.find(selected)

	if direction < 0 && items.size() > 1:
		var current_index = prev_index - 1 if prev_index > 0 else items.size() - 1
		var next_index = current_index - 1 if current_index > 0 else items.size() - 1
		left_icon.texture = items[keys[next_index]]
		middle_icon.texture = items[keys[current_index]]
		right_icon.texture = items[previous_selected]
		selected = keys[current_index]

	elif direction > 0 && items.size() > 1:
		var current_index = prev_index + 1 if prev_index < items.size() - 1  else 0
		var next_index = current_index + 1 if current_index < items.size() - 1 else 0
		left_icon.texture = items[previous_selected]
		middle_icon.texture = items[keys[current_index]]
		right_icon.texture = items[keys[next_index]]
		selected = keys[current_index]

	else: # assumes this is called before left/right versions are called (always happens cause it's called on inventory open)
		selected = keys[prev_index] if prev_index != -1 else keys[0]
		prev_index = 0 if prev_index == -1 else prev_index
		if items.size() == 1:
			middle_icon.texture = items[items.keys()[0]]
			left_icon.texture = null
			right_icon.texture = null
			return
		var left = prev_index - 1 if prev_index > 0 else items.size() - 1
		var right = prev_index + 1 if prev_index < items.size() - 1 else 0
		left_icon.texture = items[keys[left]]
		middle_icon.texture = items[selected]
		right_icon.texture = items[keys[right]]

func _to_shown_name(item_name: String) -> String:
	if item_name == medkit_name: return "%s (%d/%d)" % [item_name, medkit_count, max_medkits]
	elif item_name == trap_name: return "%s (%d/%d)" % [item_name, trap_count, max_traps]
	elif item_name == battery_name: return "%s (%d/%d)" % [item_name, battery_count, max_batteries]
	else: return item_name

func _get_description(item_name: String) -> String:
	if item_name == medkit_name: return medkit_desc
	elif item_name == battery_name: return battery_desc
	elif item_name == trap_name: return trap_desc
	elif item_name == "": return ""
	return key_item_desc

# Tween functions -> do animations first, then figure out logic on how to cycle btn everything
func cycle_left():
	if (running_tween && running_tween.is_running()) || items.size() <= 1: return

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

	_set_items(-1)
	var new_L = left_icon.duplicate()
	new_L.position = right_icon.get_parent().position + Vector2.LEFT * move_length
	new_L.scale = Vector2.ZERO
	add_child(new_L)

	get_node("Container").visible = false
	name_label.visible = false
	desc_label.visible = false

	# do animations with duplicates
	running_tween = create_tween()
	running_tween.set_parallel(true)
	running_tween.tween_property(L, "position", L.position + Vector2.RIGHT * move_length, transitions_time / 2)
	running_tween.tween_property(L, "scale", Vector2.ONE, transitions_time / 2)
	running_tween.tween_property(M, "position", M.position + Vector2.RIGHT * move_length, transitions_time / 2)
	running_tween.tween_property(M, "scale", Vector2.ONE * 0.5, transitions_time / 2)
	running_tween.tween_property(R, "position", R.position + Vector2.RIGHT * move_length, transitions_time / 2)
	running_tween.tween_property(R, "scale", Vector2.ZERO, transitions_time / 2)
	running_tween.tween_property(new_L, "position", new_L.position + Vector2.RIGHT * move_length, transitions_time / 2)
	running_tween.tween_property(new_L, "scale", Vector2.ONE * 0.5, transitions_time / 2)
	running_tween.set_parallel(false)
	running_tween.tween_callback(func():
		get_node("Container").visible = true

		name_label.text = _to_shown_name(selected)
		desc_label.text = _get_description(selected)
		name_label.visible = true
		desc_label.visible = true

		L.queue_free()
		M.queue_free()
		R.queue_free()
		new_L.queue_free()
	)
	running_tween.play()
	audio_player.stream = swipe_sound
	HELPERS.play_audio(audio_player, 0.95, 1.05)

func cycle_right():
	if (running_tween && running_tween.is_running()) || items.size() <= 1: return

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
	_set_items(1)
	var new_R = right_icon.duplicate()
	new_R.position = right_icon.get_parent().position + Vector2.RIGHT * move_length
	new_R.scale = Vector2.ZERO
	add_child(new_R)

	get_node("Container").visible = false
	name_label.visible = false
	desc_label.visible = false

	# do animations with duplicates
	running_tween = create_tween()
	running_tween.set_parallel(true)
	running_tween.tween_property(L, "position", L.position + Vector2.LEFT * move_length, transitions_time / 2)
	running_tween.tween_property(L, "scale", Vector2.ZERO, transitions_time / 2)
	running_tween.tween_property(M, "position", M.position + Vector2.LEFT * move_length, transitions_time / 2)
	running_tween.tween_property(M, "scale", Vector2.ONE * 0.5, transitions_time / 2)
	running_tween.tween_property(R, "position", R.position + Vector2.LEFT * move_length, transitions_time / 2)
	running_tween.tween_property(R, "scale", Vector2.ONE, transitions_time / 2)
	running_tween.tween_property(new_R, "position", new_R.position + Vector2.LEFT * move_length, transitions_time / 2)
	running_tween.tween_property(new_R, "scale", Vector2.ONE * 0.5, transitions_time / 2)
	running_tween.set_parallel(false)
	running_tween.tween_callback(func():
		get_node("Container").visible = true

		name_label.text = _to_shown_name(selected)
		desc_label.text = _get_description(selected)
		name_label.visible = true
		desc_label.visible = true

		L.queue_free()
		M.queue_free()
		R.queue_free()
		new_R.queue_free()
	)
	running_tween.play()
	audio_player.stream = swipe_sound
	HELPERS.play_audio(audio_player, 0.95, 1.05)

func open():
	if running_tween && running_tween.is_running(): return
	var original_pos = position
	position.y = original_pos.y + 400
	name_label.visible = false
	desc_label.visible = false
	visible = true

	_set_items(0)
	running_tween = create_tween()
	running_tween.tween_property(self, "position", original_pos, transitions_time)
	running_tween.tween_callback(func():
		name_label.visible = true
		desc_label.visible = true
		name_label.text = _to_shown_name(selected)
		desc_label.text = _get_description(selected)
	)
	running_tween.play()
	audio_player.stream = open_sound
	HELPERS.play_audio(audio_player)

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
