extends Node3D

@onready var mpp := multiplayer.multiplayer_peer as WebRTCMultiplayerPeer
var peer_id := randi_range(1, 2147483647)
var room_id := ""

func _ready():
	mpp = WebRTCMultiplayerPeer.new()
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
	mpp.get_peer(dst_id).connection.set_local_description(type, sdp)
	if type == "offer":
		send_offer(dst_id, sdp)
	elif type == "answer": 
		send_answer(dst_id, sdp)

func on_ice_candidate_created(media: String, idx: int, sdp: String, id: int):
	send_candidate(id, media, idx, sdp)

func send_offer(dst_id: int, offer: String):
	FunctionTest.store_message(room_id, "O %d %s" % [dst_id, offer])

func send_answer(dst_id: int, answer: String):
	FunctionTest.store_message(room_id, "A %d %s" % [dst_id, answer])
	
func send_candidate(dst_id: int, media: String, idx: int, sdp: String):	
	FunctionTest.store_message(room_id, "C %d %s %d %s" % [dst_id, media, idx, sdp])

func _on_join_button_pressed():
	room_id = %JoinEdit.text
	%RoomIdEdit.text = room_id

func _on_host_button_pressed():
	room_id = await FunctionTest.host_room()
	%RoomIdEdit.text = room_id
	FunctionTest.store_message("J9HI3", "HI MOM")
