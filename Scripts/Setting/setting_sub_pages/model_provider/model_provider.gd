extends Control
@onready var model_provider_side_bar: Control = $HBoxContainer/SecondarySideBarPanel/ModelProviderSideBar
@onready var model_provider_subpage: Control = $HBoxContainer/PagesPanel/ModelProviderSubpage

func _ready() -> void:
	CoreSystem.event_bus.subscribe(
		"setting_model_provider_subpage",
		model_provider_subpage.switch
	)
