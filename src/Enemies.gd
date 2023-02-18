extends Node

export(PackedScene) var Enemy
export(Array, Script) var strategies
export(Array, SpriteFrames) var textures

onready var Main = get_parent()


func spawn_enemies():
	var Map = Main.Map
	var positions = [Vector2(Main.east_bounds - 1, 0), 
					Vector2(Main.east_bounds - 1, Main.height - 1),
					Vector2(Main.west_bounds + Main.width/2, Main.height - 1),
					Vector2(Main.west_bounds + Main.width/2, 0),
					]
	for i in Main.completed_rooms + 3:
		var pos
		if i >= positions.size():
			pos = positions[randi()%positions.size()]
		else:
			pos = positions[i]
		var enemy = Enemy.instance()
		
		var strategy_i = i % strategies.size()
		enemy.get_node("MoveStrategy").set_script(strategies[strategy_i])
		enemy.get_node("Sprite").frames = textures[strategy_i]
		enemy.get_node("Sprite").animation = "w"
		enemy.Map = Map
		enemy.position = Map.map_to_world(pos) + Map.cell_size / 2 
		enemy.map_pos = pos
		Main.get_node("Player").connect("player_moved", enemy, "on_player_moved")
		add_child(enemy)


func remove_enemies():
	for child in get_children():
		if child.is_in_group("Enemy"):
			child.queue_free()


func enemy_in_spot(pos):
	for child in get_children():
		if child.map_pos == pos:
			return true
	return false
