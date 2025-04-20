extends Control

		

@onready var view_switcher: ViewSwitcher = %ViewSwitcher

@onready var setting_side_bar: Control = %SettingSideBar

@onready var agent_side_bar: Control = %AgentSideBar

@onready var agent_edit_side_bar: Control = %AgentEditSideBar

@onready var mcp_server_side_bar: Control = %McpServerSideBar

@onready var parent_panel: Panel = $".."

var current_side_bar : String:
	set(value):
		match value:
			"home":
				parent_panel.visible = false
			"setting":
				pr_visible()
				setting_side_bar.visible = true
			"agent":
				pr_visible()
				agent_side_bar.visible = true
			"agent_edit":
				pr_visible()
				agent_edit_side_bar.visible = true
			"mcp_server":
				pr_visible()
				mcp_server_side_bar.visible = true
			
		current_side_bar = value

func _ready() -> void:
	setting_side_bar.visible = false

func pr_visible():
	parent_panel.visible = true
	visible = true

func switch(page : String):
	current_side_bar = page
