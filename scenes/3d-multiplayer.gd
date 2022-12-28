extends Node3D

@onready var mpp := multiplayer.multiplayer_peer as WebRTCMultiplayerPeer
var peer_id := randi_range(1, 2147483647)

func _ready():
	mpp = WebRTCMultiplayerPeer.new()
	%PeerIdLabel.text = "%s" % peer_id
	mpp.create_mesh(peer_id)
	await get_tree().create_timer(5.0).timeout
	connect_webrtc_peer(1)
	
func connect_webrtc_peer(dst_id: int):
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.session_description_created.connect(on_session_description_created.bind(dst_id))
	peer.ice_candidate_created.connect(on_ice_candidate_created.bind(dst_id))
	mpp.add_peer(peer, dst_id)
	
func on_session_description_created(type: String, sdp: String, dst_id: int):
	if not mpp.has_peer(dst_id): return
	print("session_description created: %s %s %d" % [type, sdp, dst_id])
	mpp.get_peer(dst_id).connection.set_local_description(type, sdp)
	if type == "offer":
		send_offer(dst_id, sdp)
	elif type == "answer": 
		send_answer(dst_id, sdp)

func on_ice_candidate_created(media: String, idx: int, sdp: String, id: int):
	print("ICE created: %s %d %s %d" % [media, idx, sdp, id])
	send_candidate(id, media, idx, sdp)

func send_offer(dst_id: int, offer: String):
	TCPTest.send_message(offer)

func send_answer(dst_id: int, answer: String):
	TCPTest.send_message(answer)

func send_candidate(dst_id: int, media: String, idx: int, sdp: String):	
	TCPTest.send_message(media)
