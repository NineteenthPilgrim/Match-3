extends Node

const BUS_NAME := "SFX"
const SETTINGS_PATH := "user://settings.cfg"

var sfx_percent: float = 100.0


func _ready() -> void:
	load_settings()
	apply_sfx()


func set_sfx_percent(value: float) -> void:
	sfx_percent = clamp(value, 0.0, 100.0)
	apply_sfx()
	save_settings()


func apply_sfx() -> void:
	var idx = AudioServer.get_bus_index(BUS_NAME)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, _linear_percent_to_db(sfx_percent))


func _linear_percent_to_db(percent: float) -> float:
	var linear = clamp(percent / 100.0, 0.0, 1.0)
	if linear <= 0.0001:
		return -80.0
	return 20.0 * (log(linear) / log(10.0))


func save_settings() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("audio", "sfx", sfx_percent)
	var err = cfg.save(SETTINGS_PATH)
	if err != OK:
		push_error("AudioManager: failed to save settings: %s" % err)

func load_settings() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		sfx_percent = cfg.get_value("audio", "sfx", 100.0)
	else:
		sfx_percent = 100.0
