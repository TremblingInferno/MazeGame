extends Area2D

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

var map : TileMap
var map_pos = Vector2()
var speed = .25
var moving = false
	

func can_move(dir):
	if map.get_cellv(map_pos + moves[dir]) < 0:
		return false
	var t = map.get_cellv(map_pos)
	if t & dir:
		return false
	else:
		return true
	

func _input(event):
	if Input.is_action_just_pressed('ui_up'):
		move(N)
	if Input.is_action_just_pressed('ui_down'):
		move(S)
	if Input.is_action_just_pressed('ui_right'):
		move(E)
	if Input.is_action_just_pressed('ui_left'):
		move(W)
	

func move(dir = 0):
	if dir and move_queue.size() < 2:
		move_queue.append(dir)
	if moving or not move_queue:
		return
	if can_move(move_queue.front()):
		map_pos += moves[move_queue.front()]
	else:
		move_queue.pop_front()
		move()
		return
	move_queue.pop_front()
	moving = true
	
	var destination = map.map_to_world(map_pos) + Vector2(32, 32)
	$Tween.interpolate_property(self, 'position', position, destination, speed,
								Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	moving = false
	move()

