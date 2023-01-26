extends Node

var player_state_collection = {}

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 7000

func _ready():
	ConnectToServer()

func ConnectToServer():
	network.create_client(ip, port)
	multiplayer.set_multiplayer_peer(network)
	
	#network.connect("connection_failed", Callable(self, "_OnConnectionFailed"))	
	#network.connect("connection_succeeded", Callable(self, "_OnConnectionSucceeded"))
	

func _OnConnectionFailed():
	print("Failed to connect")
	
func _OnConnectionSucceeded():
	print("Successfully connected")

func SendPlayerState(player_state):
	#print(player_state)
	rpc("RecievePlayerState", player_state)



@rpc(unreliable)
func RecieveWorldState(world_state):
	print(world_state)
	get_node("../SceneHandler/Map").UpdateWorldState(world_state)
