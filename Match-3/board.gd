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
			var piece = Area2D.new()	#create element
			var sprite = Sprite2D.new()	#create texture
			
			piece.position = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)	#position of element
			sprite.texture = textures[randi() % textures.size()]	#select texture
			piece.add_child(sprite)		#add image to node
			
			var collision = CollisionShape2D.new()		#create click area
			collision.shape = RectangleShape2D.new()	#create ectangle shape
			collision.shape.extents = Vector2(Tile_Size/2, Tile_Size/2)
			piece.add_child(collision)
			
			piece.connect("input_event", Callable(self, "_on_piece_clicked")) #connect signal
			add_child(piece)
			Grid[row].append(piece)		#save element to array

func _on_piece_clicked(viewport, event, shape_index):
	if event is InputEventMouseButton and event.pressed:
		print("Element selected")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
