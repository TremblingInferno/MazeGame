extends Node


func get_destination(player:Area2D, map:TileMap): # shared by all enemy move strategies
	var dir = player.direction
	var destination = player.map_pos + 2 * dir
	return map.map_to_world(destination)
