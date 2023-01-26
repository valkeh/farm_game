extends CharacterBody2D

const MOTION_SPEED = 90.0
var current_anim = ""
var puppet_pos = Vector2()
var puppet_motion = Vector2()
var player_state

#@rpc(unreliable)
#func _update_state(p_pos, p_motion):
#	puppet_pos = p_pos
#	puppet_motion = p_motion
	
#@rpc(unreliable) func set_pos_and_motion(p_pos, p_motion):
#	puppet_pos = p_pos
#	puppet_motion = p_motion

func _physics_process(delta):
	var motion = Vector2()
	#if is_multiplayer_authority():
	if Input.is_action_pressed("ui_right"):
		motion += Vector2(1, 0)
	elif Input.is_action_pressed("ui_left"):
		motion += Vector2(-1, 0)
	elif Input.is_action_pressed("ui_down"):
		motion += Vector2(0, 1)
	elif Input.is_action_pressed("ui_up"):
		motion += Vector2(0, -1)
		
		#rpc("_update_state", position, motion)
		#set_pos_and_motion.rpc(position, motion)
		
	var new_anim = "idle"
	if motion.y < 0:
		new_anim = "upwalk"	
	elif motion.y > 0:
		new_anim = "downwalk"
	elif motion.x < 0:
		new_anim = "leftwalk"
	elif motion.x > 0:
		new_anim = "rightwalk"

	if new_anim != current_anim:
		current_anim = new_anim
		get_node("anim").play(current_anim)	
		
	set_velocity(motion * MOTION_SPEED)
	move_and_slide()
	#if not is_multiplayer_authority():
	#	puppet_pos = position # To avoid jitter
		
	DefinePlayerState()

func player_sell_method():
	print("sellshop")
	pass

func player_shop_method():
	print("shopmethod")
	pass
	

func DefinePlayerState():

	#print(str(get_global_position()) + "here is position")
	player_state = {"T": Time.get_unix_time_from_system() * 1000, "P": get_global_position()}
	GameServer.SendPlayerState(player_state)
