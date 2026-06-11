extends Control

@onready var flavor_text = $FlavorText
@onready var hint = $Hint

func display_flavor_text(text: String):
	flavor_text.scroll_text(text)


