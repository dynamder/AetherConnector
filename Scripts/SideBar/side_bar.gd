extends Control
var sidebar_button_group : ButtonGroup
@onready var home_button: TagButton = %HomeButton


func _ready() -> void:
	sidebar_button_group = home_button.button_group 
	sidebar_button_group.pressed.connect(_on_button_toggled)
	
	home_button.set_pressed(true)
	home_button.grab_focus()
	
func _on_button_toggled(button : TagButton):
	CoreSystem.event_bus.push_event(
		"sidebar_change",
		[button.tag]
	)
