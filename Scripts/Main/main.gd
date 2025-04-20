##CRITICAL: NO ANDROID SUPPORT

extends Control
@onready var router: Control = %Router
@onready var empty_title_bar: Control = %EmptyTitleBar
@onready var border_panel: Panel = %BorderPanel

@onready var minimize_button: Button = %MinimizeButton
@onready var maximize_button: Button = %MaximizeButton
@onready var restore_button: Button = %RestoreButton
@onready var close_button: Button = %CloseButton

@onready var background: Panel = %Background

var mouse_border_section : DisplayServer.WindowResizeEdge
var prepare_resizing : bool = false

var border_stylebox : StyleBoxFlat
var max_border_stylebox : StyleBoxFlat

func _ready() -> void:
	get_viewport().transparent_bg = true
	
	border_stylebox = border_panel.get_theme_stylebox("panel")
	
	max_border_stylebox = border_stylebox.duplicate()
	max_border_stylebox.corner_radius_bottom_left = 0
	max_border_stylebox.corner_radius_bottom_right = 0
	max_border_stylebox.corner_radius_top_left = 0
	max_border_stylebox.corner_radius_top_right = 0
	
	DisplayServer.window_set_flag(
		DisplayServer.WINDOW_FLAG_TRANSPARENT,
		true,
		0
	)
	router.secondary_side_bar.visible = false
	CoreSystem.event_bus.debug_mode = true
	CoreSystem.event_bus.subscribe(
		"sidebar_change",
		router.switch
	)


var tolerable_margin_x : int = 15
var tolerable_margin_y : int = 15

func get_cursor_section() -> DisplayServer.WindowResizeEdge:
	var mouse_position := get_viewport().get_mouse_position()
	var viewport_size : Vector2i = get_viewport().size
	if mouse_position.x <= tolerable_margin_x and mouse_position.y < tolerable_margin_y:
		return DisplayServer.WINDOW_EDGE_TOP_LEFT
	
	elif mouse_position.x >= viewport_size.x - tolerable_margin_x \
	and mouse_position.x <= viewport_size.x and mouse_position.y <= tolerable_margin_y:
		return DisplayServer.WINDOW_EDGE_TOP_RIGHT
	
	elif mouse_position.x <= tolerable_margin_x \
	and mouse_position.y >= viewport_size.y - tolerable_margin_y and mouse_position.y <= viewport_size.y:
		return DisplayServer.WINDOW_EDGE_BOTTOM_LEFT
	
	elif mouse_position.x >= viewport_size.x - tolerable_margin_x \
	and mouse_position.x <= viewport_size.x \
	and mouse_position.y >= viewport_size.y - tolerable_margin_y \
	and mouse_position.y <= viewport_size.y:
		return DisplayServer.WINDOW_EDGE_BOTTOM_RIGHT
	
	elif mouse_position.y <= tolerable_margin_y:
		return DisplayServer.WINDOW_EDGE_TOP
	
	elif mouse_position.y >= viewport_size.y - tolerable_margin_y \
	and mouse_position.y <= viewport_size.y:
		return DisplayServer.WINDOW_EDGE_BOTTOM
	
	elif mouse_position.x <= tolerable_margin_x:
		return DisplayServer.WINDOW_EDGE_LEFT
	
	else:
		return DisplayServer.WINDOW_EDGE_RIGHT
	
	prepare_resizing = true
	


func _on_minimize_button_pressed() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_MINIMIZED
	)
	minimize_button.release_focus()

func _on_minimize_button_mouse_exited() -> void:
	minimize_button.release_focus()


func _on_maximize_button_pressed() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_MAXIMIZED
	)
	maximize_button.release_focus()
	
	border_panel.add_theme_stylebox_override(
		"panel",
		max_border_stylebox
	)


func _on_maximize_button_mouse_exited() -> void:
	maximize_button.release_focus()

func _on_restore_button_pressed() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_WINDOWED
	)
	DisplayServer.window_set_size(
		Vector2i(1920,1080)
	)
	restore_button.release_focus()
	
	border_panel.add_theme_stylebox_override(
		"panel",
		border_stylebox
	)
	
func _on_restore_button_mouse_exited() -> void:
	restore_button.release_focus()
	
func _on_close_button_pressed() -> void:
	get_tree().quit()

func _on_close_button_mouse_exited() -> void:
	close_button.release_focus()

func _on_empty_title_bar_focus_entered() -> void:
	DisplayServer.window_start_drag()
	empty_title_bar.release_focus()
	background.call_deferred("grab_click_focus")
	

func _on_empty_title_bar_mouse_exited() -> void:
	empty_title_bar.release_focus()
	background.call_deferred("grab_click_focus")

func _on_border_panel_mouse_entered() -> void:
	var shape : CursorShape
	mouse_border_section = get_cursor_section()
	match mouse_border_section:
		DisplayServer.WINDOW_EDGE_TOP:
			shape = CURSOR_VSIZE
		DisplayServer.WINDOW_EDGE_BOTTOM:
			shape = CURSOR_VSIZE
		DisplayServer.WINDOW_EDGE_LEFT:
			shape = CURSOR_HSIZE
		DisplayServer.WINDOW_EDGE_RIGHT:
			shape = CURSOR_HSIZE
		DisplayServer.WINDOW_EDGE_TOP_LEFT:
			shape = CURSOR_FDIAGSIZE
		DisplayServer.WINDOW_EDGE_BOTTOM_RIGHT:
			shape = CURSOR_FDIAGSIZE
		DisplayServer.WINDOW_EDGE_TOP_RIGHT:
			shape = CURSOR_BDIAGSIZE
		DisplayServer.WINDOW_EDGE_BOTTOM_LEFT:
			shape = CURSOR_BDIAGSIZE
			
	mouse_default_cursor_shape = shape


func _on_border_panel_mouse_exited() -> void:
	border_panel.release_focus()
	prepare_resizing = false

func _on_border_panel_focus_entered() -> void:
	DisplayServer.window_start_resize(
		mouse_border_section
	)
			
