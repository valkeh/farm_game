extends CharacterBody2D
class_name Animal

var eating = false
var walking = false

var xdir = 1 #1 1 == right -1 == left
var ydir = 1 #1 1 == down -1 == up
var speed = 5
var current_anim = ""

var motion = Vector2()
var puppet_pos = Vector2()
var puppet_motion = Vector2()

var moving_vertical_horizontal = 1 #1 = horizontal 2 = vertical

func _ready():
	walking = true
	randomize()
	
@rpc
func _update_state(p_pos, p_motion):
	puppet_pos = p_pos
	puppet_motion = p_motion
	
func _physics_process(delta):
	if is_multiplayer_authority():
		var waittime = 1
		if walking == false:
			var x = randf_range(1,2)
			if x > 1.5:
				moving_vertical_horizontal = 1
			else:
				moving_vertical_horizontal = 2
		if walking == true:
			if moving_vertical_horizontal == 1:
				motion.x = speed * xdir
				motion.y = 0
			elif moving_vertical_horizontal == 2:
				motion.y = speed * ydir
				motion.x = 0	
		if eating == true:
			motion.x = 0
			motion.y = 0
		rpc("_update_state", position, motion)
	else:
		position = puppet_pos
		motion = puppet_motion
		
	var new_anim = "walking"
	if motion.y < 0:
		new_anim = "walking"
	elif motion.y > 0:
		new_anim = "walking"
	elif motion.x < 0:
		new_anim = "walking"
	elif motion.x > 0:
		new_anim = "walking"

	if new_anim != current_anim:
		current_anim = new_anim
		get_node("anim").play(current_anim)		
	
	set_velocity(motion)
	move_and_slide()
	
	if not is_multiplayer_authority():
		puppet_pos = position # To avoid jitter
				
func _on_changestatetimer_timeout():
	var waittime = 1
	if walking == true:
		eating = true
		walking = false
		waittime = randf_range(1,5)
	elif eating == true:
		walking = true
		eating = false
		waittime = randf_range(2,6)
	$changestatetimer.wait_time = waittime
	$changestatetimer.start()


func _on_walkingtimer_timeout():
	var x = randf_range(1,2)
	var y = randf_range(1,2)
	var waittime = randf_range(1,4)
	
	if x > 1.5:
		xdir = 1 #right
	else:
		xdir = -1 #left
	if y > 1.5:
		ydir = 1
	else:
		ydir = -1
	$walkingtimer.wait_time = waittime
	$walkingtimer.start()
