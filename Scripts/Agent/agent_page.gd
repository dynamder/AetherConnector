extends Control
@onready var new_chat_button: TagButton = %NewChatButton
@onready var change_model_button: TagButton = %ChangeModelButton
@onready var change_model: Control = %ChangeModel
@onready var panel_container: PanelContainer = $MarginContainer/PanelContainer

var bottom_button_group : ButtonGroup

func _ready() -> void:
	bottom_button_group = new_chat_button.button_group
	bottom_button_group.pressed.connect(_on_bottom_button_toggled)
	CoreSystem.event_bus.subscribe(
		"pop_window_end",
		_on_pop_up_window_end
	)
	

func _on_bottom_button_toggled(button : TagButton):
	button.set_pressed_no_signal(false)
	subwindow_pop_up(button.tag)
	
func subwindow_pop_up(tag : String):
	panel_container.visible = true
	match tag:
		"change_model":
			change_model.visible = true

func _on_pop_up_window_end():
	panel_container.visible = false
	
