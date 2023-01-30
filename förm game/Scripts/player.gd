extends CharacterBody2D	
var animation_vector = Vector2()

const MOTION_SPEED = 90.0
var current_anim = ""

var player_state

@onready
var animation_tree = get_node("AnimationTree")

@onready
var animation_mode = animation_tree.get("parameters/playback")

#func _ready():
	#print("hey")
	#animation_tree.set('parameters/Idle/blend_position', Vector2(0,1))
	#animation_mode.travel("Idle")

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
		
	

		
	#print(animation_vector)
	set_velocity(motion * MOTION_SPEED)
	
	move_and_slide()
	
	if (animation_vector != motion.normalized()):
		animation_vector = motion.normalized()
		if (motion != Vector2(0, 0)):
			animation_tree.set('parameters/Walk/blend_position', animation_vector)
			animation_tree.set('parameters/Idle/blend_position', animation_vector)
			animation_mode.travel("Walk")
		else:
			animation_mode.travel("Idle")
	else:
		pass
		
	DefinePlayerState()

func player_sell_method():
	print("sellshop")
	pass

func player_shop_method():
	print("shopmethod")
	pass
	

func DefinePlayerState():

	#print(str(get_global_position()) + "here is position")
	player_state = {"T": GameServer.client_clock, "P": get_global_position(), "A": animation_vector}
	GameServer.SendPlayerState(player_state)



func _on_spawn_moose_pressed():
	GameServer.SpawnOnPress(get_global_position(),["mammals/moose"])


func _on_spawn_cow_pressed():
	GameServer.SpawnOnPress(get_global_position(),["mammals/cow"])


func _on_spawn_bird_pressed():
	GameServer.SpawnOnPress(get_global_position(),["aves/doomlord"])


func _on_spawn_chicken_pressed():
	GameServer.SpawnOnPress(get_global_position(),["mammals/chicken"])
