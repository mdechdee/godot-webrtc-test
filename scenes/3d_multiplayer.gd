extends Node3D

@onready var mpp := get_tree().get_multiplayer().multiplayer_peer as WebRTCMultiplayerPeer
@export var player_scene: PackedScene 

func _ready():
	# mpp must be initialize by a child first
	mpp.peer_connected.connect(on_peer_connected)
	
func on_peer_connected(id: int): 
	print("Peer connected %d" % id)
	add_child(player_scene.instantiate())
