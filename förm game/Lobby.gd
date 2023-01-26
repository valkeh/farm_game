extends Node

# Connect all functions

func _ready():
	get_tree().connect("peer_connected",Callable(self,"_player_connected"))
	get_tree().connect("peer_disconnected",Callable(self,"_player_disconnected"))
	get_tree().connect("connected_to_server",Callable(self,"_connected_ok"))
	get_tree().connect("connection_failed",Callable(self,"_connected_fail"))
	get_tree().connect("server_disconnected",Callable(self,"_server_disconnected"))


# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	# Called checked both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)
	print("connected")
	pre_configure_game()


func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	pass # Only called checked clients, not server. Will go unused; not useful here.
	

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

@rpc(any_peer) func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_remote_sender_id()
	# Store the info
	player_info[id] = info

	# Call function to update lobby UI here
	
	client_configure_game()
	
@rpc(any_peer) func pre_configure_game():
	var selfPeerID = get_tree().get_unique_id()

	# Load world
	var world = load('res://world.tscn').instantiate()
	get_node("/root").add_child(world)

	# Load my player
	var my_player = preload("res://player.tscn").instantiate()
	my_player.set_name(str(selfPeerID))
	my_player.set_multiplayer_authority(selfPeerID) # Will be explained later
	print("hello")
	#get_node("/root/world/players").add_child(my_player)



	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_remote_sender_id() to find out who said they were done.
	rpc_id(1, "done_preconfiguring")

@rpc(any_peer) func client_configure_game():
	
	# Load other players
	for p in player_info:
		var player = preload("res://player.tscn").instantiate()
		player.set_name(str(p))
		player.set_multiplayer_authority(p) # Will be explained later
		get_node("/root/world/players").add_child(player)
