extends Control
@onready var siliconflow: Control = %Siliconflow
@onready var openrouter: Control = %Openrouter

var current_page : String:
	set(value):
		current_page = value
		match value:
			"siliconflow":
				siliconflow.visible = true
			"openrouter":
				openrouter.visible = true
	
func switch(page : String):
	current_page = page
