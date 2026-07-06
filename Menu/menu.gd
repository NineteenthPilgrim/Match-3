extends Control

@onready var centerb = $HBoxContainer/BoxSettings
@onready var leftb = $HBoxContainer/MarginContainer/CenterContainer2/BoxMain
@onready var slevel = $SelectLevel
@onready var Sfx_Click = $SfxClick
@onready var Sfx_Close = $SfxClose
@onready var Sfx_Slider = $HBoxContainer/BoxSettings/ColorRect/HSlider


func _ready() -> void:
	if not get_tree().get_root().has_node("AudioManager"):
		var am_new = preload("res://AudioManager.gd").new()
		am_new.name = "AudioManager"
		get_tree().get_root().add_child(am_new)
		am_new.load_settings()
		am_new.apply_sfx()
	var am = get_tree().get_root().get_node("AudioManager")
	if am:
		Sfx_Slider.value = am.sfx_percent
	else:
		Sfx_Slider.value = 100.0
	Sfx_Slider.connect("value_changed", Callable(self, "_on_h_slider_value_changed"))
	slevel.visible = false
	hide_setting() 
	$HBoxContainer/BoxSettings/ColorRect/Window.select(0 if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else 1)


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
	Sfx_Click.play()


func _on_close_pressed() -> void:
	hide_setting()
	Sfx_Close.play()


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_size(Vector2i(480, 270))
		1: DisplayServer.window_set_size(Vector2i(640, 360))
		2: DisplayServer.window_set_size(Vector2i(800, 450))
		3: DisplayServer.window_set_size(Vector2i(1280, 720))
		4: DisplayServer.window_set_size(Vector2i(1600, 900))


func _on_window_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_start_b_pressed() -> void:
	slevel.visible = true
	Sfx_Click.play()
	slevel.mouse_filter = Control.MOUSE_FILTER_STOP
	slevel.grab_focus()
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/StartB.disabled = true
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/StartB.focus_mode = Control.FOCUS_NONE
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/SettingsB.disabled = true
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/SettingsB.focus_mode = Control.FOCUS_NONE
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/ExitB.disabled = true
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/ExitB.focus_mode = Control.FOCUS_NONE


func _on_b_close_pressed() -> void:
	slevel.visible = false
	Sfx_Close.play()
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/StartB.disabled = false
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/StartB.focus_mode = Control.FOCUS_ALL
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/SettingsB.disabled = false
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/SettingsB.focus_mode = Control.FOCUS_ALL
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/ExitB.disabled = false
	$HBoxContainer/MarginContainer/CenterContainer2/BoxMain/ExitB.focus_mode = Control.FOCUS_ALL


func _on_texture_button_pressed() -> void:
	Sfx_Click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Boards/board.tscn")


func _on_texture_button_2_pressed() -> void:
	Sfx_Click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Boards/board#2.tscn")


func _on_texture_button_3_pressed() -> void:
	Sfx_Click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Boards/board#3.tscn")


func _on_texture_button_4_pressed() -> void:
	Sfx_Click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Boards/board#4.tscn")


func _on_texture_button_5_pressed() -> void:
	Sfx_Click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Boards/board#5.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	var am = get_tree().get_root().get_node_or_null("AudioManager")
	if am:
		am.set_sfx_percent(value)
