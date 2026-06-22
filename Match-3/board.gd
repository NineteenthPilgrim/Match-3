extends Node2D

const Rows = 8
const Cols = 8
const Tile_Size = 32
var Grid = []

func _ready():
	print("Сетка готова: ", Rows, "x", Cols)
	var textures = [
		preload("res://sprites/Blue-match-3.png"),
		preload("res://sprites/Green-match-3.png"),
		preload("res://sprites/Purple-match-3.png"),
		preload("res://sprites/Red-match-3.png")
	]
	Grid.resize(Rows)
	for row in range(Rows):
		Grid[row]= []
		for col in range(Cols):
			var sprite = Sprite2D.new()
			sprite.texture = textures[randi() % textures.size()]
			sprite.position = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)
			add_child(sprite)
			Grid[row].append(sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
