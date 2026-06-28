extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed", Callable(self, "_on_pressed"))


func _on_pressed() -> void:
	print("Quit")
	get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
