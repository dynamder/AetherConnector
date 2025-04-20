extends Control
var current_page : String:
	set(value):
		match value:
			"home":
				home_page.visible = true
			"setting":
				setting_page.visible = true
			"agent":
				agent_page.visible = true
			"agent_edit":
				agent_edit_page.visible = true
			"mcp_server":
				mcp_server_page.visible = true
		
@onready var home_page: Control = %HomePage
@onready var setting_page: Control = %SettingPage
@onready var agent_page: Control = %AgentPage
@onready var agent_edit_page: Control = %AgentEditPage
@onready var mcp_server_page: Control = %McpServerPage

func _ready() -> void:
	setting_page.visible = false

func switch(page : String):
	current_page = page
			
