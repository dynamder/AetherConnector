extends Control

@onready var user_profile_button: Button = %UserProfileButton


func _on_visibility_changed() -> void:
	CoreSystem.event_bus.push_event(
		"setting_sub_page",
		["user_profile"]
	)
	user_profile_button.grab_focus()


func _on_user_profile_button_pressed() -> void:
	CoreSystem.event_bus.push_event(
		"setting_sub_page",
		["user_profile"]
	)
