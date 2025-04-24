extends Control
@onready var search_bar: LineEdit = $VBoxContainer/SearchBar
@onready var v_box_container: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer

var model_list : Array[String]
var model_select_button_group : ButtonGroup

var children_list : Array

func _ready() -> void:
	model_select_button_group = ButtonGroup.new()
	model_select_button_group.pressed.connect(_on_button_toggled)
	var raw_model_list= AetherConfig.model_list_db.select_rows(
		"model_id",
		"TRUE",
		["model_id"]
	)
	for unit in raw_model_list:
		model_list.append(unit.model_id)
		var button = TagButton.new()
		button.tag = unit.model_id
		button.text = unit.model_id
		button.toggle_mode = true
		button.button_group = model_select_button_group
		v_box_container.add_child(button)
		children_list.append(button)

func _on_search_bar_text_changed(new_text: String) -> void:
	if new_text == "":
		for unit in children_list:
			unit.visible = true
		return
	for unit in children_list:
		if not new_text in unit.tag:
			unit.visible = false
		if new_text in unit.tag:
			unit.visible = true

func _on_button_toggled(button : TagButton):
	CoreSystem.event_bus.push_event(
		"temp_model_select",
		[button.tag]
	)
	CoreSystem.event_bus.push_event(
		"pop_window_end"
	)
