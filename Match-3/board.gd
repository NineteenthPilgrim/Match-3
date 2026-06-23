extends Node2D

const Rows = 8
const Cols = 8
const Tile_Size = 32
var Grid = []
var Selected_Piece = null #create variable to store selected element
var Selected_Sprite = null 


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
			sprite.name = "Sprite2D"
			
			piece.position = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)	#position of element
			sprite.texture = textures[randi() % textures.size()]	#select texture
			piece.add_child(sprite)		#add image to node
			
			var collision = CollisionShape2D.new()		#create click area
			collision.shape = RectangleShape2D.new()	#create ectangle shape
			collision.shape.extents = Vector2(Tile_Size/2, Tile_Size/2)
			piece.add_child(collision)
			
			piece.connect("input_event", Callable(self, "_on_piece_clicked").bind(piece)) #connect signal
			add_child(piece)
			Grid[row].append(piece)		#save element to array


func _on_piece_clicked(viewport, event, shape_index, piece):	#call function on element click
	if event is InputEventMouseButton and event.pressed:
		if Selected_Piece == null:
			var sprite = piece.get_node("Sprite2D")					#first element selected
			if sprite != null:
				Selected_Piece = piece
				Selected_Sprite = sprite
				Selected_Piece.modulate = Color(0.2, 0.2, 0.2)		#highlight element
				print("First element selected")
		else:
			if neighbors(Selected_Piece.position, piece.position):
				swap_pieces(Selected_Piece, piece)
				print("Pieces swapped")
			else:
				print("Not neighbors")
			Selected_Piece.modulate = Color(1, 1, 1)
			Selected_Piece = null
			Selected_Sprite = null
			print("First element is no longer selected")


func neighbors(Pos1: Vector2, Pos2: Vector2) -> bool:
	var Diff = Pos1 - Pos2
	return (abs(Diff.x) == Tile_Size and Diff.y == 0) or (abs(Diff.y) == Tile_Size and Diff.x == 0)


func swap_pieces(Piece1: Area2D, Piece2: Area2D):
	var Temp_Pos = Piece1.position
	Piece1.position = Piece2.position
	Piece2.position = Temp_Pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
