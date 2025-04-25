extends Control
@onready var new_chat_button: TagButton = %NewChatButton
@onready var change_model_button: TagButton = %ChangeModelButton
@onready var change_model: Control = %ChangeModel
@onready var panel_container: PanelContainer = $MarginContainer/PanelContainer
@onready var submit_button: TagButton = %SubmitButton
@onready var text_edit: TextEdit = %TextEdit
@onready var messages_container: VBoxContainer = %MessagesContainer

var message_tcp_client : TCPClient

var bottom_button_group : ButtonGroup

var chat_bubble_user : PackedScene = preload("res://UI/tabs/agent/agent_page_chat/chat_bubble_user.tscn")
var chat_bubble_agent : PackedScene = preload("res://UI/tabs/agent/agent_page_chat/chat_bubble_agent.tscn")

func _ready() -> void:
	message_tcp_client = TCPClient.new()
	
	bottom_button_group = new_chat_button.button_group
	bottom_button_group.pressed.connect(_on_bottom_button_toggled)
	CoreSystem.event_bus.subscribe(
		"pop_window_end",
		_on_pop_up_window_end
	)
	

func _on_bottom_button_toggled(button : TagButton):
	button.button_pressed = false
	button.toggled.emit(false)
	button.release_focus()
	subwindow_pop_up(button.tag)
	
func subwindow_pop_up(tag : String):
	panel_container.visible = true
	match tag:
		"change_model":
			change_model.visible = true
		"new_chat":
			pass #TODO

func _on_pop_up_window_end():
	panel_container.visible = false
	


func _on_submit_button_pressed() -> void:
	submit_button.release_focus()
	if text_edit.text == "":
		return
	CoreSystem.event_bus.push_event(
		"user_message",
		[text_edit.text]
	)
	post_user_message()
	post_agent_message("test test test test")

func post_user_message(message : String = ""):
	var user_message_bubble := chat_bubble_user.instantiate()
	messages_container.add_child(user_message_bubble)
	if message == "":
		user_message_bubble.markdown_content.markdown_text = text_edit.text
		user_message_bubble.markdown_content.text = text_edit.text
		text_edit.clear()
	else:
		user_message_bubble.markdown_content.markdown_text = message
	var spacer = messages_container.add_spacer(false)
	spacer.custom_minimum_size = Vector2(0,20)
	spacer.size_flags_vertical = Control.SIZE_SHRINK_END
	
func post_agent_message(message : String):
	var agent_message_bubble := chat_bubble_agent.instantiate()
	messages_container.add_child(agent_message_bubble)
	agent_message_bubble.markdown_content.markdown_text = message
	agent_message_bubble.markdown_content.text = message
	var spacer = messages_container.add_spacer(false)
	spacer.custom_minimum_size = Vector2(0,20)
	spacer.size_flags_vertical = Control.SIZE_SHRINK_END
