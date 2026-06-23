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
	var Start_matches = find_matches()
	if Start_matches.size() > 0:
		remove_matches(Start_matches)


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
	
	var row1 = int(Piece1.position.y / Tile_Size)
	var col1 = int(Piece1.position.x / Tile_Size)
	var row2 = int(Piece2.position.y / Tile_Size)
	var col2 = int(Piece2.position.x / Tile_Size)
	
	var Temp = Grid[row1][col1]
	Grid[row1][col1] = Grid[row2][col2]
	Grid[row2][col2] = Temp
	
	var Matches = find_matches()
	if Matches.size() > 0:
		print("Found matches: ", Matches.size())
		remove_matches(Matches)
	else:
		print("No matches")


func find_matches() -> Array:
	var Matches = []
	for row in range(Rows):				#check rows
		if Grid[row] == null:
			continue
		if Grid[row].size() < Cols:
			continue
		var Count = 1
		for col in range(1, Cols):
			if col >= Grid[row].size():
				break
			if Grid[row][col] == null or Grid[row][col-1] == null:
				Count = 1
				continue
			var Current = Grid[row][col].get_node("Sprite2D").texture
			var Previous = Grid[row][col-1].get_node("Sprite2D").texture
			if Current == Previous: 
				Count += 1
				if Count >= 3 and col == Cols - 1:
					for i in range(Count):
						Matches.append(Grid[row][col-i])
			else:
				if Count >= 3:
					for i in range(Count):
						Matches.append(Grid[row][col-1-i])
				Count = 1
	for col in range(Cols):				#check cols
		var Count = 1
		for row in range(1, Rows):
			if Grid[row] == null or Grid[row-1] == null:
				continue
			if Grid[row][col] == null or Grid[row-1][col] == null:
				Count = 1
				continue
			var Current = Grid[row][col].get_node("Sprite2D").texture
			var Previous = Grid[row-1][col].get_node("Sprite2D").texture
			if Current == Previous:
				Count += 1
				if Count >= 3 and row == Rows-1:
					for i in range(Count):
						Matches.append(Grid[row-i][col])
			else:
				if Count >= 3:
					for i in range(Count):
						Matches.append(Grid[row-1-i][col])
				Count = 1
	return Matches


func remove_matches(Matches: Array):	#added match removal function
	for piece in Matches:
		for row in range(Rows):
			for col in range(Cols):
				if Grid[row][col] == piece:
					Grid[row][col] = null
		piece.queue_free()
	apply_gravity()			#trigger shift down
	refill_board()			#refill from top
	var new_matches = find_matches()
	if new_matches.size() > 0:
		remove_matches(new_matches)

func apply_gravity():
	for col in range(Cols):
		for row in range(Rows - 1, -1, -1):
			if Grid[row][col] == null:
				for k in range(row - 1, -1, -1):
					if Grid[k][col] != null:
						var piece = Grid[k][col]
						Grid[row][col] = piece
						Grid[k][col] = null
						piece.position = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)
						break


func refill_board():
	var textures = [
		preload("res://sprites/Blue-match-3.png"),
		preload("res://sprites/Green-match-3.png"),
		preload("res://sprites/Purple-match-3.png"),
		preload("res://sprites/Red-match-3.png")
	]
	for row in range(Rows):
		for col in range(Cols):
			if Grid[row][col] == null:
				var Piece = Area2D.new()
				var Sprite = Sprite2D.new()
				Sprite.name = "Sprite2D"
				Sprite.texture = textures[randi() % textures.size()]
				Piece.add_child(Sprite)
				
				var Collision = CollisionShape2D.new()
				Collision.shape = RectangleShape2D.new()
				Collision.shape.extents = Vector2(Tile_Size/2, Tile_Size/2)
				Piece.add_child(Collision)
				Piece.position = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)
				Piece.connect("input_event", Callable(self, "_on_piece_clicked").bind(Piece))
				add_child(Piece)
				Grid[row][col] = Piece 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
