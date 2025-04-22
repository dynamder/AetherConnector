extends Control
@export var provider : String
@onready var base_url_line_edit: LineEdit = $VBoxContainer/BaseUrlLineEdit
@onready var api_key_line_edit: LineEdit = $VBoxContainer/ApiKeyLineEdit
@onready var model_list_v_box_container: VBoxContainer = $VBoxContainer/ScrollContainer/ModelListVBoxContainer


var model_unit_tscn := preload("res://UI/tabs/setting/subpages/model_provider/sub2router/sub2pages/template/model_unit.tscn")

var model_list : Array

func _ready() -> void:
	if AetherConfig.model_provider_settings.has(provider):
		base_url_line_edit.text = AetherConfig.model_provider_settings[provider].base_url
		if AetherConfig.model_provider_settings[provider].api_key:
			api_key_line_edit.text = AetherConfig.model_provider_settings[provider].api_key
		
		show_model_list()
		
func _on_api_key_line_edit_text_submitted(new_text: String) -> void:
	if AetherConfig.model_provider_settings.has(provider):
		AetherConfig.model_provider_settings[provider].api_key = new_text
		YAMLWriter.save_file(
			AetherConfig.model_provider_settings,
			ConfigPath.model_provider_settings_path,
		)

func show_model_list():
	model_list= AetherConfig.model_list_db.select_rows(
		"model_id",
		"provider='%s'" % provider,
		["model_id"]
	)
	for unit in model_list:
		var m_unit = model_unit_tscn.instantiate()
		model_list_v_box_container.add_child(m_unit)
		m_unit.label.text = unit.model_id
		
		#var empty_control := Control.new()
		#empty_control.custom_minimum_size = Vector2i(0,40)
		#model_list_v_box_container.add_child(empty_control)
