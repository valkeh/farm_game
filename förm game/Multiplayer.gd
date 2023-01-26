extends Node

func _hostGame():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(7000, 10)
	get_tree().network_peer = peer


func _connectGame():
	var peerConn = ENetMultiplayerPeer.new()
	peerConn.create_client('83.254.157.18', 7000)
	get_tree().network_peer = peerConn


func _on_host_pressed():
	_hostGame()


func _on_connect_pressed():
	_connectGame()


func _ready():
	_hostGame()
