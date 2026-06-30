extends Control
@onready var centerb = $HBoxContainer/BoxSettings
@onready var leftb = $HBoxContainer/MarginContainer/CenterContainer2/BoxMain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_setting() 
	$HBoxContainer/BoxSettings/ColorRect/Window.select(0 if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func show_settings() -> void:
	centerb.visible = true
	centerb.modulate.a = 1.0
	centerb.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_children_interactive(centerb, true)
	_set_children_interactive(leftb, false) 
	centerb.grab_focus()


func hide_setting() -> void:
	centerb.visible = true
	centerb.modulate.a = 0.0
	centerb.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_children_interactive(centerb, false)
	_set_children_interactive(leftb, true) 
	leftb.grab_focus()


func _set_children_interactive(node: Node, enable: bool) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_STOP if enable else Control.MOUSE_FILTER_IGNORE
			child.focus_mode = Control.FOCUS_ALL if enable else Control.FOCUS_NONE
			if child.has_method("set_disabled"):
				child.set_disabled(not enable)
			_set_children_interactive(child, enable) 


func _on_settings_b_pressed() -> void:
	show_settings()


func _on_close_pressed() -> void:
	hide_setting()


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_size(Vector2i(480, 270))
		1: DisplayServer.window_set_size(Vector2i(640, 360))
		2: DisplayServer.window_set_size(Vector2i(800, 450))
		3: DisplayServer.window_set_size(Vector2i(1280, 720))
		4: DisplayServer.window_set_size(Vector2i(1600, 900))
	print("Resolution changed to index:", index)


func _on_window_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_start_b_pressed() -> void:
	get_tree().change_scene_to_file("res://Boards/board.tscn")
