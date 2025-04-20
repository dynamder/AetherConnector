extends Control

@export var secondary_side_bar : Control
@export var pages : Control

func switch(tab : String):
	secondary_side_bar.switch(tab)
	pages.switch(tab)
