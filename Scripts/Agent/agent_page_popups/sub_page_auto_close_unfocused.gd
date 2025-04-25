extends PanelContainer


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			CoreSystem.event_bus.push_event(
				"pop_window_end"
			)
