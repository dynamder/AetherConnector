extends ViewSwitcher
@onready var maximize_button: Button = %MaximizeButton
@onready var restore_button: Button = %RestoreButton

func _ready() -> void:
	restore_button.visible = false
	restore_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	maximize_button.mouse_filter = Control.MOUSE_FILTER_PASS
	
func _on_maximize_button_pressed() -> void:
	restore_button.visible = true
	restore_button.mouse_filter = Control.MOUSE_FILTER_PASS
	maximize_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_restore_button_pressed() -> void:
	maximize_button.visible = true
	maximize_button.mouse_filter = Control.MOUSE_FILTER_PASS
	restore_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
