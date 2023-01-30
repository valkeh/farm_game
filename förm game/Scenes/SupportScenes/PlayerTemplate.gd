extends CharacterBody2D

var state

var old_animation_vector

@onready
var animation_tree = get_node("AnimationTree")

@onready
var animation_mode = animation_tree.get("parameters/playback")


func MovePlayer(new_position, animation_vector):



	if animation_vector == Vector2(0,0):
		if state != "Idle":
			animation_mode.travel("Idle")
			state = "Idle"
		else:
			pass
	elif old_animation_vector != animation_vector:
		animation_tree.set('parameters/Walk/blend_position', animation_vector)
		animation_tree.set('parameters/Idle/blend_position', animation_vector)
		animation_mode.travel("Walk")
		state = "Walk"
	old_animation_vector = animation_vector
	set_position(new_position)	
