extends Node2D

@onready var Menu_B = $MenuButton
@onready var Pause_Menu := $PauseMenu
@onready var Resume_B = $PauseMenu/Resume
@onready var Exit_B = $PauseMenu/Exit
@onready var Lose_Menu := $LoseMenu
@onready var Win_Menu := $WinMenu
@onready var Sfx_Click = $SfxClick
@onready var Sfx_Close = $SfxClose
@onready var Sfx_GameOver = $SfxGameOver
@onready var Sfx_Win = $SfxWin

const Rows = 8
const Cols = 8
const Tile_Size = 32

var Grid = []
var LevelMask = []
var Selected_Piece = null #create variable to store selected element
var Selected_Sprite = null 
var Is_Animating = false
var No_More_Moves := false
var Moves_Left = 7
var Moves_Label: Label
var Moves_LabelS: Label
var Score = 0
var Score_Label: Label
var Score_LabelS: Label
var Limit = 5000


func _ready():
	Moves_Label = Label.new()
	Moves_LabelS = Label.new()
	Moves_Label.text = "Moves"
	Moves_LabelS.text = "%d" %Moves_Left
	Moves_Label.position = Vector2(-104,102)
	Moves_LabelS.position = Vector2(-104,114)
	add_child(Moves_Label)
	add_child(Moves_LabelS)
	
	Score_Label = Label.new()
	Score_LabelS = Label.new()
	Score_Label.text = "Score"
	Score_LabelS.text = "%d" %Score
	Score_Label.position = Vector2(-104,68)
	Score_LabelS.position = Vector2(-104,80)
	add_child(Score_Label)
	add_child(Score_LabelS)
	
	Pause_Menu.visible = false
	Lose_Menu.visible = false
	Win_Menu.visible = false
	
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
	
	setup_level_mask()
	
	Grid.resize(Rows)
	for row in range(Rows):
		Grid[row]= []
		for col in range(Cols):
			if not LevelMask[row][col]:
				Grid[row].append(null)
				continue
			var piece = Area2D.new()	#create element
			var sprite = Sprite2D.new()	#create texture
			sprite.name = "Sprite2D"
			piece.position = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)	#position of element
			var type_idx := randi() % textures.size()
			sprite.texture = textures[type_idx]  
			piece.add_child(sprite)
			piece.set_meta("orig_tex", textures[type_idx])
			piece.set_meta("selected_tex", s_textures[type_idx])
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
	if Is_Animating or No_More_Moves:
		return
	if event is InputEventMouseButton and event.pressed:
		if Selected_Piece == null:
			var sprite = piece.get_node("Sprite2D")					#first element selected
			if sprite != null:
				Selected_Piece = piece
				Selected_Sprite = sprite
				var sel := piece.get_meta("selected_tex") as Texture2D
				if sel:
					sprite.texture = sel
		else:
			if neighbors(Selected_Piece.position, piece.position):
				swap_pieces(Selected_Piece, piece)
			else:
				var orig := Selected_Piece.get_meta("orig_tex") as Texture2D
				if orig:
					Selected_Piece.get_node("Sprite2D").texture = orig   
			Selected_Piece = null
			Selected_Sprite = null


func neighbors(Pos1: Vector2, Pos2: Vector2) -> bool:
	var Diff = Pos1 - Pos2
	if (abs(Diff.x) == Tile_Size and Diff.y == 0) or (abs(Diff.y) == Tile_Size and Diff.x == 0):
		var r1 = int(Pos1.y / Tile_Size); var c1 = int(Pos1.x / Tile_Size)
		var r2 = int(Pos2.y / Tile_Size); var c2 = int(Pos2.x / Tile_Size)
		if r1 < 0 or r1 >= Rows or r2 < 0 or r2 >= Rows or c1 < 0 or c1 >= Cols or c2 < 0 or c2 >= Cols:
			return false
		if not LevelMask[r1][c1] or not LevelMask[r2][c2]:
			return false
		if Grid[r1] == null or Grid[r2] == null:
			return false
		if Grid[r1].size() <= c1 or Grid[r2].size() <= c2:
			return false
		if Grid[r1][c1] == null or Grid[r2][c2] == null:
			return false
		return true
	return false


func swap_pieces(Piece1: Area2D, Piece2: Area2D):
	var Temp_Pos = Piece1.position
	Piece1.position = Piece2.position
	Piece2.position = Temp_Pos
	
	var row1 = int(Piece1.position.y / Tile_Size)
	var col1 = int(Piece1.position.x / Tile_Size)
	var row2 = int(Piece2.position.y / Tile_Size)
	var col2 = int(Piece2.position.x / Tile_Size)
	
	if row1 >= 0 and row1 < Rows and row2 >= 0 and row2 < Rows and col1 >= 0 and col1 < Cols and col2 >= 0 and col2 < Cols:
		if LevelMask[row1][col1] and LevelMask[row2][col2]:
			var Temp = Grid[row1][col1]
			Grid[row1][col1] = Grid[row2][col2]
			Grid[row2][col2] = Temp
	
	var o1 := Piece1.get_meta("orig_tex") as Texture2D
	var o2 := Piece2.get_meta("orig_tex") as Texture2D
	if o1: Piece1.get_node("Sprite2D").texture = o1
	if o2: Piece2.get_node("Sprite2D").texture = o2
	
	var groups = find_matches()
	var flat_matches = []
	for g in groups:
		for p in g:
			if not flat_matches.has(p):
				flat_matches.append(p)
	if flat_matches.size() > 0:
		Sfx_Click.play()
		highlight_matches(flat_matches)
		Moves_Left -= 1
		Moves_Label.text = "Moves"
		Moves_LabelS.text = "%d" % Moves_Left
		if Moves_Left <= 0:
			No_More_Moves = true
		await remove_matches(groups)
	else:
		Sfx_Close.play()
		Temp_Pos = Piece1.position
		Piece1.position = Piece2.position
		Piece2.position = Temp_Pos
		if row1 >= 0 and row1 < Rows and row2 >= 0 and row2 < Rows and col1 >= 0 and col1 < Cols and col2 >= 0 and col2 < Cols:
			if LevelMask[row1][col1] and LevelMask[row2][col2]:
				var Temp = Grid[row1][col1]
				Grid[row1][col1] = Grid[row2][col2]
				Grid[row2][col2] = Temp
		var ro1 := Piece1.get_meta("orig_tex") as Texture2D
		var ro2 := Piece2.get_meta("orig_tex") as Texture2D
		if ro1: Piece1.get_node("Sprite2D").texture = ro1
		if ro2: Piece2.get_node("Sprite2D").texture = ro2


func is_in_match(piece: Area2D) -> bool:
	if piece == null:
		return false
	var row = int(piece.position.y / Tile_Size)
	var col = int(piece.position.x / Tile_Size)
	if row < 0 or row >= Rows or col < 0 or col >= Cols:
		return false
	if not LevelMask[row][col]:
		return false
	var tex = piece.get_node("Sprite2D").texture
	var count = 1
	for c in range(max(col-2,0), min(col+3,Cols)):
		if not LevelMask[row][c]:
			continue
		if Grid[row] == null or Grid[row].size() <= c:
			continue
		if Grid[row][c] != null and Grid[row][c].get_node("Sprite2D").texture == tex:
			count += 1
			if count >= 3:
				return true
	count = 1
	for r in range(max(row-2,0), min(row+3,Rows)):
		if not LevelMask[r][col]:
			continue
		if Grid[r] == null or Grid[r].size() <= col:
			continue
		if Grid[r][col] != null and Grid[r][col].get_node("Sprite2D").texture == tex:
			count += 1
	return count >= 3


func find_matches() -> Array:
	var groups = []
	for row in range(Rows):				#check rows
		if Grid[row] == null:
			continue
		var Count = 1
		var Start_col = 0
		for col in range(1, Cols):
			if not LevelMask[row][col] or not LevelMask[row][col-1]:
				if not LevelMask[row][col] or not LevelMask[row][col-1] or Grid[row] == null or Grid[row].size() <= col or Grid[row].size() <= col-1 or Grid[row][col] == null or Grid[row][col-1] == null:
					if Count >= 3:
						var group = []
						for i in range(Start_col, col):
							if LevelMask[row][i] and Grid[row].size() > i and Grid[row][i] != null:
								group.append(Grid[row][i])
							if group.size() > 0:
								groups.append(group)
				Count = 1
				Start_col = col 
				continue
			var Current = Grid[row][col].get_node("Sprite2D").texture
			var Previous = Grid[row][col-1].get_node("Sprite2D").texture
			if Current == Previous: 
				Count += 1
				if Count >= 3 and col == Cols - 1:
					var group = []
					for i in range(Start_col, col + 1):
						if LevelMask[row][i] and Grid[row].size() > i and Grid[row][i] != null:
							group.append(Grid[row][i])
					if group.size() > 0:
						groups.append(group)
			else:
				if Count >= 3:
					var group = []
					for i in range(Start_col, col):
						if LevelMask[row][i] and Grid[row].size() > i and Grid[row][i] != null:
							group.append(Grid[row][i])
						if group.size() > 0:
							groups.append(group)
				Count = 1
				Start_col = col
	
	for col in range(Cols):				#check cols
		var Count = 1
		var Start_row = 0  
		for row in range(1, Rows):
			if not LevelMask[row][col] or not LevelMask[row-1][col] or Grid[row] == null or Grid[row-1] == null or Grid[row].size() <= col or Grid[row-1].size() <= col or Grid[row][col] == null or Grid[row-1][col] == null:
				if Count >= 3:
					var group = []
					for i in range(Start_row, row):
						if LevelMask[i][col] and Grid[i].size() > col and Grid[i][col] != null:
							group.append(Grid[i][col])
					if group.size() > 0:
						groups.append(group)
				Count = 1
				Start_row = row
				continue
			var Current = Grid[row][col].get_node("Sprite2D").texture
			var Previous = Grid[row-1][col].get_node("Sprite2D").texture
			if Current == Previous:
				Count += 1
				if Count >= 3 and row == Rows-1:
					##
					var group = []
					##
					for i in range(Start_row, row + 1):
						if LevelMask[i][col] and Grid[i].size() > col and Grid[i][col] != null:
							group.append(Grid[i][col])
						if group.size() > 0:
							groups.append(group)
			else:
				if Count >= 3:
					##
					var group = []
					##
					for i in range(Start_row, row):
						if LevelMask[i][col] and Grid[i].size() > col and Grid[i][col] != null:
							group.append(Grid[i][col])
						if group.size() > 0:
							groups.append(group)
				Count = 1
				Start_row = row 
	
	var merged = []
	for g in groups:
		var added = false
		for i in range(merged.size()):
			for p in g:
				if merged[i].has(p):
					for q in g:
						if not merged[i].has(q):
							merged[i].append(q)
					added = true
					break
				if added:
					break
		if not added:
			merged.append(g.duplicate())

	var changed = true
	while changed:
		changed = false
		for i in range(merged.size()):
			for j in range(i + 1, merged.size()):
				var inter = false
				for p in merged[i]:
					if merged[j].has(p):
						inter = true
						break
				if inter:
					for p in merged[j]:
						if not merged[i].has(p):
							merged[i].append(p)
					merged.remove_at(j)
					changed = true
					break
			if changed:
				break
	return merged


func highlight_matches(Matches: Array):
	for row in range(Rows):
		if Grid[row] == null:
			continue
		for col in range(Grid[row].size()):
			if Grid[row][col] != null:
				Grid[row][col].modulate = Color(1,1,1)
	for piece in Matches:
		if piece != null:
			piece.modulate = Color(1, 0, 0.2)


func remove_matches(Matches: Array):	#added match removal function
	Is_Animating = true
	for group in Matches:
		var group_size = group.size()
		if group_size == 3:
			Score += 100
		elif group_size == 4:
			Score += 300
		else:
			Score += 500
	
	Score_Label.text = "Score"
	Score_LabelS.text = "%d" %Score
	
	for group in Matches:
		for piece in group:
			if piece != null:
				piece.modulate = Color(1, 0, 0.2)
	
	await get_tree().create_timer(0.5).timeout	#delay 
	if get_tree().paused:
		await Resume_B.pressed
	
	for group in Matches:
		for piece in group:
			for row in range(Rows):
				if Grid[row] == null:
					continue
				for col in range(Grid[row].size()):
					if Grid[row][col] == piece:
						Grid[row][col] = null
			if piece:
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
	elif No_More_Moves:
		game_over()
		get_tree().paused = true


func apply_gravity():
	for col in range(Cols):
		for row in range(Rows - 1, -1, -1):
			if not LevelMask[row][col]:
				continue
			if Grid[row] == null or Grid[row].size() <= col:
				continue
			if Grid[row][col] == null:
				for k in range(row - 1, -1, -1):
					if not LevelMask[k][col]:
						continue
					if Grid[k] == null or Grid[k].size() <= col:
						continue
					if Grid[k][col] != null:
						var piece = Grid[k][col]
						Grid[row][col] = piece
						Grid[k][col] = null
						var Target_Pos = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)
						if get_tree().paused:
							await Resume_B.pressed
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
	var s_textures = [
		preload("res://sprites/p-Blue-match-3.png"),
		preload("res://sprites/p-Green-match-3.png"),
		preload("res://sprites/p-Purple-match-3.png"),
		preload("res://sprites/p-Red-match-3.png")
	]
	for row in range(Rows):
		for col in range(Cols):
			if not LevelMask[row][col]:
				continue
			if Grid[row] == null:
				continue
			if Grid[row].size() <= col:
				while Grid[row].size() <= col:
					Grid[row].append(null)
			if Grid[row][col] == null:
				var Piece = Area2D.new()
				var Sprite = Sprite2D.new()
				Sprite.name = "Sprite2D"
				var type_idx := randi() % textures.size()
				Sprite.texture = textures[type_idx]  
				Piece.add_child(Sprite)
				Piece.set_meta("orig_tex", textures[type_idx])
				Piece.set_meta("selected_tex", s_textures[type_idx])
				var Collision = CollisionShape2D.new()
				Collision.shape = RectangleShape2D.new()
				Collision.shape.extents = Vector2(Tile_Size/2, Tile_Size/2)
				Piece.add_child(Collision)
				var Target_Pos = Vector2(col * Tile_Size + Tile_Size/2, row * Tile_Size + Tile_Size/2)
				Piece.position = Target_Pos - Vector2(0, Tile_Size * 6)
				Piece.connect("input_event", Callable(self, "_on_piece_clicked").bind(Piece))
				add_child(Piece)
				Grid[row][col] = Piece
				if get_tree().paused:
							await Resume_B.pressed
				var tween = get_tree().create_tween()
				tween.tween_property(Piece, "position", Target_Pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func setup_level_mask():
	LevelMask = []
	for r in range(Rows):
		var row_mask = []
		for c in range(Cols):
			row_mask.append(true) 
		LevelMask.append(row_mask)
	LevelMask[0][0] = false
	LevelMask[0][1] = false
	LevelMask[0][6] = false
	LevelMask[0][7] = false
	LevelMask[1][0] = false
	LevelMask[1][7] = false
	
	LevelMask[6][0] = false
	LevelMask[7][0] = false
	LevelMask[7][1] = false
	LevelMask[6][7] = false
	LevelMask[7][6] = false
	LevelMask[7][7] = false

func game_over():
	Sfx_GameOver.play()
	Lose_Menu.visible = true


func game_win():
	Sfx_Win.play()
	Win_Menu.visible = true
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_button_pressed() -> void:
	Sfx_Click.play()
	await get_tree().create_timer(0.1).timeout
	Pause_Menu.visible = true
	get_tree().paused = true


func _on_resume_pressed() -> void:
	Sfx_Click.play()
	get_tree().paused = false
	Pause_Menu.visible = false


func _on_exit_pressed() -> void:
	Sfx_Close.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/menu.tscn")


func _on_restart_pressed() -> void:
	Sfx_Click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_button_continue_pressed() -> void:
	Sfx_Click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Boards/board#3.tscn")
