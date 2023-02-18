extends Area2D

signal player_moved(player)


const N = 0x1
const E = 0x2
const S = 0x4
const W = 0x8

var move_queue = []

var animations = {N: 'n',
				  S: 's',
				  E: 'e',
				  W: 'w'}
var moves = {N: Vector2(0, -1),
			 S: Vector2(0, 1),
			 E: Vector2(1, 0),
			 W: Vector2(-1, 0)}
var keys = {N:"move_up",
			S:"move_down",
			E:"move_right",
			W:"move_left"}

var map : TileMap
var map_pos = Vector2()
var speed = .25
var moving = false
var direction


func can_move(dir):
	if map.get_cellv(map_pos + moves[dir]) < 0:
		return false
	var t = map.get_cellv(map_pos)
	if t & dir:
		return false
	else:
		return true
	

func _input(_event):
	check_recent_action()


func check_recent_action():
	for key in keys:
		if Input.is_action_just_pressed(keys[key]):
			move(key)


func check_action():
	for key in keys:
		if Input.is_action_pressed(keys[key]):
			move(key)
			return true


func move(dir = 0):
	if moving or not can_move(dir):
		return
	direction = moves[dir] * 2
	map_pos += direction
	moving = true
	
	var destination = map.map_to_world(map_pos) + Vector2(32, 32)
	emit_signal("player_moved", self)
	$Tween.interpolate_property(self, 'position', position, destination, speed,
								Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	moving = false
	check_action()



func _on_Player_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("Enemy"):
		SoundManager.play_death_sound()
		get_tree().reload_current_scene()
