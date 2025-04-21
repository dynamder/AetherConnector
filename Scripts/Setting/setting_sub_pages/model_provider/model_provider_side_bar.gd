extends Control
@onready var parent_panel: Panel = $".."
@onready var silicon_flow: TagButton = $MarginContainer/Panel/ScrollContainer/VBoxContainer/SiliconFlow
var button_group : ButtonGroup
var current_side_bar : String:
	set(value):	
		current_side_bar = value

func _ready() -> void:
	button_group = silicon_flow.button_group
	button_group.pressed.connect(_on_button_toggled)

func pr_visible():
	parent_panel.visible = true
	visible = true

func switch(page : String):
	current_side_bar = page

func _on_button_toggled(button : TagButton):
	CoreSystem.event_bus.push_event(
		"setting_model_provider_subpage",
		[button.tag]
	)


func _on_visibility_changed() -> void:
	silicon_flow.set_pressed(true)
	silicon_flow.grab_focus()
