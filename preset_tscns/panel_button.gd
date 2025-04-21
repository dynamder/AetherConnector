@tool
extends MarginContainer
@export var button_tag : String:
	set(value):
		if not is_node_ready():
			await ready
		button_tag = value
		tag_button.tag = value
@export_multiline var button_text : String:
	set(value):
		if not is_node_ready():
			await ready
		button_text = value
		tag_button.text = value
		
@export var button_group : ButtonGroup:
	set(value):
		if not is_node_ready():
			await ready
		if button_group == null:
			return
		if value.resource_local_to_scene:
			printerr("Panel Button: the button group resource should not be local to scene")
		value.resource_local_to_scene = false
		button_group = value
		tag_button.button_group = value


@export var toggle_mode : bool = false:
	set(value):
		if not is_node_ready():
			await ready
		toggle_mode = value
		tag_button.toggle_mode = value

@onready var tag_button: TagButton = $MarginContainer/TagButton

func _ready() -> void:
	if not tag_button.is_inside_tree():
		await tag_button.ready
