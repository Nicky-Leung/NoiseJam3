extends Control

@onready var flavor_text = $FlavorText

func display_flavor_text(text: String):
    flavor_text.scroll_text(text)