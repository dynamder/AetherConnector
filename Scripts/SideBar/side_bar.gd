extends Control



func _on_setting_button_pressed() -> void:
	CoreSystem.event_bus.push_event(
		"sidebar_change",
		["setting"]
	)


func _on_home_button_pressed() -> void:
	CoreSystem.event_bus.push_event(
		"sidebar_change",
		["home"]
	)


func _on_agent_button_pressed() -> void:
	CoreSystem.event_bus.push_event(
		"sidebar_change",
		["agent"]
	)


func _on_agent_edit_button_pressed() -> void:
	CoreSystem.event_bus.push_event(
		"sidebar_change",
		["agent_edit"]
	)


func _on_mcp_server_button_pressed() -> void:
	CoreSystem.event_bus.push_event(
		"sidebar_change",
		["mcp_server"]
	)
