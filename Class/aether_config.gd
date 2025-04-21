extends Node

var user_profile : Dictionary

func _ready() -> void:
	if not FileAccess.file_exists(ConfigPath.user_profile):
		var new_user_profile = FileAccess.open(ConfigPath.user_profile,FileAccess.WRITE)
		user_profile = ConfigDictTemplate.user_profile
		var string = YAMLWriter.save_string(
			user_profile
		)
		new_user_profile.store_string(string)
		new_user_profile.close()
	else:
		user_profile = YAMLLoader.load_file(ConfigPath.user_profile)
