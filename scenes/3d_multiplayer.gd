extends Node3D

@export var player_scene: PackedScene 

func _ready():
	# mpp must be initialize by a child first
	FunctionCallTest.room_joined.connect(
		func(room_id, peer_id):
			var mpp = get_tree().get_multiplayer().multiplayer_peer
			mpp.peer_connected.connect(on_peer_connected)
	)

func on_peer_connected(id: int): 
	print("Peer connected %d" % id)
	var peer_player: Player = player_scene.instantiate()
	peer_player.name = str(id)
	peer_player.get_node("%PeerIdLabel").text = str(id)
	peer_player.set_multiplayer_authority(id)
	add_child(peer_player)
