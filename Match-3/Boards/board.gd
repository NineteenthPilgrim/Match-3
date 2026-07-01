extends Node2D

@onready var Menu_B = $MenuButton
@onready var Pause_Menu := $PauseMenu
@onready var Resume_B = $PauseMenu/Resume
@onready var Exit_B = $PauseMenu/Exit

const Rows = 8
const Cols = 8
const Tile_Size = 32
var Grid = []
var Selected_Piece = null #create variable to store selected element
var Selected_Sprite = null 
var Is_Animating = false
var Moves_Left = 2
var Moves_Label: Label
var Score = 0
var Score_Label: Label
var Limit = 1000


func _ready():
	Moves_Label = Label.new()
	Moves_Label.text = "Moves: %d" % Moves_Left
	Moves_Label.position = Vector2(-100,160)
	add_child(Moves_Label)
	
	Score_Label = Label.new()
	Score_Label.text = "Score: %d" % Score
	Score_Label.position = Vector2(-100,80)
	add_child(Score_Label)
	
	Pause_Menu.visible = false
	
	print("Сетка готова: ", Rows, "x", Cols)
	var textures = [
		preload("res://sprites/Blue-match-3.png"),
		preload("res://sprites/Green-match-3.png"),
		preload("res://sprites/Purple-match-3.png"),
		preload("res://sprites/Red-match-3.png")
	]
	
	var s_textures = [
		preload("res://sprites/p-Blue-match-3.png"),
		preload("res://sprites/p-Green-match-3.png"),
		preload("res://sprites/p-Purple-match-3.png"),
		preload("res://sprites/p-Red-match-3.png")
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
		
	var Camera = $Camera2D				#camera settings
	var Field_Center = Vector2(Cols * Tile_Size / 2, Rows * Tile_Size/2)
	Camera.position = Field_Center
	Camera.enabled = true




func _on_piece_clicked(viewport, event, shape_index, piece):	#call function on element click
	if Is_Animating:
		return
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
		highlight_matches(Matches)
		remove_matches(Matches)
		Moves_Left -= 1
		Moves_Label.text = "Moves: %d" % Moves_Left
		if Moves_Left <= 0:
			game_over()
	else:
		print("No matches")
		Temp_Pos = Piece1.position
		Piece1.position = Piece2.position
		Piece2.position = Temp_Pos
		Temp = Grid[row1][col1]
		Grid[row1][col1] = Grid[row2][col2]
		Grid[row2][col2] = Temp
		Piece1.modulate = Color(1,1,1) 
		Piece2.modulate = Color(1,1,1)


func is_in_match(piece: Area2D) -> bool:
	var row = int(piece.position.y / Tile_Size)
	var col = int(piece.position.x / Tile_Size)
	var tex = piece.get_node("Sprite2D").texture
	var count = 1
	for c in range(max(col-2,0), min(col+3,Cols)):
		if Grid[row][c] != null and Grid[row][c].get_node("Sprite2D").texture == tex:
			count += 1
			if count >= 3:
				return true
	count = 1
	for r in range(max(row-2,0), min(row+3,Rows)):
		if Grid[r][col] != null and Grid[r][col].get_node("Sprite2D").texture == tex:
			count += 1
	return count >= 3


func find_matches() -> Array:
	var Matches_dict = {}
	for row in range(Rows):				#check rows
		if Grid[row] == null:
			continue
		if Grid[row].size() < Cols:
			continue
		var Count = 1
		var Start_col = 0
		for col in range(1, Cols):
			if col >= Grid[row].size():
				break
			if Grid[row][col] == null or Grid[row][col-1] == null:
				Count = 1
				Start_col = col 
				continue
			var Current = Grid[row][col].get_node("Sprite2D").texture
			var Previous = Grid[row][col-1].get_node("Sprite2D").texture
			if Current == Previous: 
				Count += 1
				if Count >= 3 and col == Cols - 1:
					for i in range(Start_col, col + 1):
						Matches_dict[Grid[row][i]] = true
			else:
				if Count >= 3:
					for i in range(Start_col, col):
						Matches_dict[Grid[row][i]] = true
				Count = 1
				Start_col = col
	
	for col in range(Cols):				#check cols
		var Count = 1
		var Start_row = 0  
		for row in range(1, Rows):
			if Grid[row] == null or Grid[row-1] == null:
				continue
			if Grid[row][col] == null or Grid[row-1][col] == null:
				Count = 1
				Start_row = row
				continue
			var Current = Grid[row][col].get_node("Sprite2D").texture
			var Previous = Grid[row-1][col].get_node("Sprite2D").texture
			if Current == Previous:
				Count += 1
				if Count >= 3 and row == Rows-1:
					for i in range(Start_row, row + 1):
						Matches_dict[Grid[i][col]] = true
			else:
				if Count >= 3:
					for i in range(Start_row, row):
						Matches_dict[Grid[i][col]] = true
				Count = 1
				Start_row = row 
	return Matches_dict.keys()


func highlight_matches(Matches: Array):
	for row in range(Rows):
		for col in range(Cols):
			if Grid[row][col] != null:
				Grid[row][col].modulate = Color(1,1,1)
	for piece in Matches:
		if piece != null:
			piece.modulate = Color(1, 0, 0.2)


func remove_matches(Matches: Array):	#added match removal function
	Is_Animating = true
	var count = Matches.size()
	if count == 3:
		Score += 100
	elif  count == 4:
		Score += 300
	else:
		Score += 500
	Score_Label.text = "Score: %d" % Score
	
	for piece in Matches:
		if piece != null:
			piece.modulate = Color(1, 0, 0.2)		#highlight matched elements
	await get_tree().create_timer(0.5).timeout	#delay 
	##
	##
	if get_tree().paused:
		await Resume_B.pressed
	##
	##
	for piece in Matches:
		for row in range(Rows):
			for col in range(Cols):
				if Grid[row][col] == piece:
					Grid[row][col] = null
		piece.queue_free()
	apply_gravity()			#trigger shift down
	refill_board()			#refill from top
	await get_tree().create_timer(0.5).timeout
	if get_tree().paused:
		await Resume_B.pressed
	var new_matches = find_matches()
	if new_matches.size() > 0:
		remove_matches(new_matches)
	else:
		await get_tree().create_timer(0.1).timeout
		if get_tree().paused:
			await Resume_B.pressed
		Is_Animating = false
		
	if Score >= Limit:
		game_win()
	elif Moves_Left <= 0:
		game_over()


func apply_gravity():
	for col in range(Cols):
		for row in range(Rows - 1, -1, -1):
			if Grid[row][col] == null:
				for k in range(row - 1, -1, -1):
					if Grid[k][col] != null:
						var piece = Grid[k][col]
						Grid[row][col] = piece
						Grid[k][col] = null
						var Target_Pos = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)
						##
						##
						if get_tree().paused:
							await Resume_B.pressed
						##
						##
						var tween = get_tree().create_tween()
						tween.tween_property(piece, "position", Target_Pos, 0.5)
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
				
				var Target_Pos = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)
				Piece.position = Target_Pos - Vector2(0, Tile_Size * 2)
				Piece.connect("input_event", Callable(self, "_on_piece_clicked").bind(Piece))
				add_child(Piece)
				Grid[row][col] = Piece
				if get_tree().paused:
							await Resume_B.pressed
				var tween = get_tree().create_tween()
				tween.tween_property(Piece, "position", Target_Pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func game_over():
	print("Game Over!")


func game_win():
	print("You Won!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_button_pressed() -> void:
	Pause_Menu.visible = true
	get_tree().paused = true


func _on_resume_pressed() -> void:
	get_tree().paused = false
	Pause_Menu.visible = false


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/menu.tscn")
