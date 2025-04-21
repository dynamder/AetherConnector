extends Control

@onready var user_name_text_edit: LineEdit = %UserNameTextEdit

func _on_user_name_text_edit_text_changed(new_text : String) -> void:
	if new_text == AetherConfig.user_profile.user_name:
		return
	AetherConfig.user_profile = ConfigDictTemplate.user_profile.duplicate()
	AetherConfig.user_profile.user_name = new_text
	var success := YAMLWriter.save_file(
		AetherConfig.user_profile,
		ConfigPath.user_profile
	)
	if not success:
		printerr("Error when saving user profile: %s" % YAMLWriter.last_error)
	
func _ready() -> void:
	user_name_text_edit.text = AetherConfig.user_profile.user_name
