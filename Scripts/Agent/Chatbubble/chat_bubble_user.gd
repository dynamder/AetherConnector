extends MarginContainer
@onready var user_name: Label = %UserName
@onready var markdown_content: MarkdownLabel = %MarkdownContent
@onready var texture_rect: TextureRect = %TextureRect
@onready var v_box_container: VBoxContainer = %VBoxContainer

var bubble_factor : float = 2.0 / 3.0
var max_threshold : int = 1270 * 2 / 3

func _ready() -> void:
	user_name.text = AetherConfig.user_profile.user_name
	

##RichTextLabel Bug, manually adjust the label size
func _on_markdown_content_finished() -> void:
	if markdown_content:
		#minus 30 for HBoxContainer's seperation,40 for PanelContainer Content Margins
		var max_width : int = min(
			(size.x * scale.x - texture_rect.size.x * texture_rect.scale.x - 70) * bubble_factor,
			max_threshold
		)
		if markdown_content.get_content_width() < max_width:
			markdown_content.custom_minimum_size = Vector2(
				markdown_content.get_content_width(),
				markdown_content.get_content_height() 
			)
		else:
			markdown_content.custom_minimum_size = Vector2(
				max_width,
				markdown_content.get_content_width() * markdown_content.get_content_height() / max_width
			)
	
