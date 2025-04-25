extends TextEdit
@onready var submit_button: TagButton = %SubmitButton

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ENTER:
			if event.shift_pressed:
				var line = get_caret_line()
				var column = get_caret_column()
				var index = 0
				for i in range(line):
					index += get_line(i).length() + 1
				
				index += column
				text = text.insert(index,"\n")
				set_caret_column(0)
				set_caret_line(line + 1)
			else:
				submit_button.set_pressed(true)
				submit_button.pressed.emit()
				get_viewport().set_input_as_handled()
		
