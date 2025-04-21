extends Control
@onready var user_profile: Control = %UserProfile
@onready var model_provider: Control = %ModelProvider

var current_sub_page : String:
	set(value):
		match value:
			"user_profile":
				user_profile.visible = true
			"model_provider":
				model_provider.visible = true
		current_sub_page = value

func _ready() -> void:
	CoreSystem.event_bus.subscribe(
		"setting_sub_page",
		switch_sub_page
	)
	
func switch_sub_page(sub_page : String):
	current_sub_page = sub_page
