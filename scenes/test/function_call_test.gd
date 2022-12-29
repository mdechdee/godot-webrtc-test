extends Control

@onready var mpp := multiplayer.multiplayer_peer as WebRTCMultiplayerPeer
var peer_id := -1
var room_id := ""

func _ready():
	peer_id = %PeerIdBox.value
	mpp = WebRTCMultiplayerPeer.new()
	mpp.peer_connected.connect(func(id): print("Peer connected %d" % id))
	mpp.create_mesh(peer_id)

func connect_webrtc_peer(dst_id: int):
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.session_description_created.connect(on_session_description_created.bind(dst_id))
	peer.ice_candidate_created.connect(on_ice_candidate_created.bind(dst_id))
	mpp.add_peer(peer, dst_id)
	peer.create_offer()
	
func on_session_description_created(type: String, sdp: String, dst_id: int):
	if not mpp.has_peer(dst_id): return
	print("session_description created: %s %s %d" % [type, sdp, dst_id])
	mpp.get_peer(dst_id).connection.set_local_description(type, sdp)
	if type == "offer":
		send_offer(dst_id, sdp)
	elif type == "answer": 
		send_answer(dst_id, sdp)

func on_ice_candidate_created(media: String, idx: int, sdp: String, id: int):
	print("ICE created: %s | %d | %s | %d" % [media, idx, sdp, id])
	send_candidate(id, media, idx, sdp)

func send_offer(dst_id: int, offer: String):
	FunctionTest.store_message(room_id, "O\n%d\n%d\n%s" % [peer_id, dst_id, offer])

func send_answer(dst_id: int, answer: String):
	FunctionTest.store_message(room_id, "A\n%d\n%d\n%s" % [peer_id, dst_id, answer])
	
func send_candidate(dst_id: int, media: String, idx: int, sdp: String):
	FunctionTest.store_message(room_id, "C\n%d\n%d\n%s\n%d\n%s" % [peer_id, dst_id, media, idx, sdp])

func _on_join_button_pressed():
	room_id = %JoinEdit.text
	%RoomIdEdit.text = room_id

func _on_host_button_pressed():
	room_id = await FunctionTest.host_room()
	%RoomIdEdit.text = room_id

func _on_timer_timeout():
	for id in mpp.get_peers():
		var connection = mpp.get_peer(id).connection as WebRTCPeerConnection
		var channels = mpp.get_peer(id).channels as Array[WebRTCDataChannel]
		var connected = mpp.get_peer(id).connected
		
		var channel_0 = channels[0]
		print(connection.get_connection_state(), " ", connection.get_gathering_state())
		print(channel_0.get_label()," ", channel_0.get_ready_state())
		print(connected)
		print("")
	
func _process(delta):
	mpp.poll()

func _on_peer_id_box_value_changed(value:int):
	peer_id = value
