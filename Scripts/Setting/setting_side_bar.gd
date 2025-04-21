extends Control

@onready var user_profile_button: Button = %UserProfileButton
var button_group : ButtonGroup

func _ready() -> void:
	button_group = user_profile_button.button_group
	button_group.pressed.connect(_on_button_toggled)
	
func _on_visibility_changed() -> void:
	CoreSystem.event_bus.push_event(
		"setting_sub_page",
		["user_profile"]
	)
	user_profile_button.set_pressed(true)
	user_profile_button.grab_focus()


func _on_button_toggled(button : TagButton):
	CoreSystem.event_bus.push_event(
		"setting_sub_page",
		[button.tag]
	)
