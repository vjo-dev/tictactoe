extends Node

@export var circle_scene : PackedScene
@export var cross_scene : PackedScene

var board_size : int
var temp_marker
var player_panel_pos : Vector2i
var cell_size : int
var grid_pos : Vector2i
var grid_data : Array
var player : int
var winner : int
var turn : int

# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = $Board.texture.get_width()
	# divide board_size by 3 to get cell_size because grid is 3x3
	cell_size = board_size / 3
	# get coordinate of player panel
	player_panel_pos = $PlayerPanel.get_position()
	new_game()


func _input(event):
	# react only if left click with mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# exit function if click is outside the board
		if event.position.x > board_size:
			return
		
		# convert mouse position to grid position
		grid_pos = Vector2i(event.position / cell_size)
		
		# add position not played
		if grid_data[grid_pos.y][grid_pos.x] == 0:
			grid_data[grid_pos.y][grid_pos.x] = player
			
			# add marker
			add_marker(player, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
			turn += 1
			
			# test if player wins
			if check_win():
				winner = player
				get_tree().paused = true
				if winner == 1:
					game_over("Player 1 wins!")
				else:
					game_over("Player 2 wins!")
				return
			
			# test if game is full
			if turn == 9:
				temp_marker.queue_free()
				get_tree().paused = true
				game_over("It's a tie!")
				return
			
			# next player
			player *= -1
			
			# update temp marker for next player
			temp_marker.queue_free()
			add_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)


func new_game():
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
		]
	winner = 0
	turn = 0
	player = 1
	# remove all markers
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	# add first player marker in side panel
	add_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
	$HUD.hide()
	get_tree().paused = false
	
	
func add_marker(player, position, temp=false):
	var marker
	if player == 1:
		marker = circle_scene.instantiate()
	else:
		marker = cross_scene.instantiate()
		
	marker.position = position
	add_child(marker)
	
	if temp: temp_marker = marker


func check_win():
	var row_sum
	var col_sum
	var diag1_sum
	var diag2_sum
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diag1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diag2_sum = grid_data[0][2] +  grid_data[1][1] + grid_data[2][0]
		if abs(row_sum) == 3 or abs(col_sum) == 3 or diag1_sum == 3 or diag2_sum == 3:
			return true


func game_over(result):
	$HUD.show()
	$HUD.get_node("Message").text = result
	

func _on_hud_restart():
	new_game()
