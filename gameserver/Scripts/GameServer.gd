extends Node

var network = ENetMultiplayerPeer.new()
var port = 7000
var max_players = 100

var player_state_collection = {}

@onready
var player_verification_process = get_node("PlayerVerification")

signal peer_connected()
signal connection_fail()

func _ready():
	StartServer()
	
	var savegame = FileAccess.open("user://savegame.save", FileAccess.READ)
	while savegame.get_position() < savegame.get_length():
		var content = savegame.get_line()
		var json_object = JSON.new()
		json_object.parse(content)
		print (json_object.data["pos_x"])
	
func StartServer():
	network.create_server(port, max_players)
	multiplayer.set_multiplayer_peer(network)
	#print("Server started")
	
	network.connect("peer_connected", Callable(self, "_Peer_Connected"))	
	network.connect("peer_disconnected", Callable(self, "_Peer_Disconnected"))
	
func _Peer_Connected(player_id):
	#print("User " + str(player_id) + " Connected")
	player_verification_process.start(player_id)
	
func _Peer_Disconnected(player_id):
	#print("User " + str(player_id) + " Disconnected")
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		player_state_collection.erase(player_id)
		DespawnPlayer.rpc_id(0, player_id)
		
@rpc(any_peer)
func DetermineLatency(client_time):
	var player_id = multiplayer.get_remote_sender_id()
	ReturnLatency.rpc_id(player_id, client_time)

@rpc(any_peer)
func FetchServerTime(client_time):
	var player_id = multiplayer.get_remote_sender_id()
	ReturnServerTime.rpc_id(player_id, Time.get_unix_time_from_system() * 1000, client_time)

@rpc
func ReturnLatency(client_time):
	pass
	
@rpc
func ReturnServerTime(server_time, client_time):
	pass
	
@rpc
func DespawnPlayer(player_id):
	pass

@rpc(any_peer)
func RecievePlayerState(player_state):
	var player_id = multiplayer.get_remote_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
			#print(player_state)
	else:
		#print("else")
		player_state_collection[player_id] = player_state
		
func SendWorldState(world_state):
	RecieveWorldState.rpc_id(0, world_state)
	
@rpc(any_peer)
func SpawnAnimal(position,animal_type):
	get_node("Map").SpawnAnimal(position,animal_type) 
	

@rpc
func RecieveWorldState(world_state):
	pass
	
@rpc(any_peer)
func LoadWorldRequest():
	var savegame = FileAccess.open("user://savegame.save", FileAccess.READ)
	var content = savegame.get_as_text()
	print(content)
	RecieveWorldSave.rpc_id(0, content)
	
@rpc
func RecieveWorldSave(savegame):
	pass
