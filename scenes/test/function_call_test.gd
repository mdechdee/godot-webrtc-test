extends Control

var peer_id := -1
var room_id := ""
var mpp: WebRTCMultiplayerPeer

var messages_cache: Array[Dictionary] = []

func _ready():
	peer_id = %PeerIdBox.value
	mpp = WebRTCMultiplayerPeer.new()
	mpp.create_mesh(peer_id)
	get_tree().get_multiplayer().multiplayer_peer = mpp

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
	print(mpp.get_peers().keys())
	if not mpp.has_peer(dst_id): return
	await FunctionTest.store_message(room_id, {
		"src": peer_id,
		"dst": dst_id,
		"type": type,
		"sdp": sdp,
		"time": Time.get_ticks_usec()
	})
	mpp.get_peer(dst_id).connection.set_local_description(type, sdp)

func on_ice_candidate_created(media: String, idx: int, sdp: String, dst_id: int):
	await FunctionTest.store_message(room_id, {
		"src": peer_id,
		"dst": dst_id,
		"type": "candidate",
		"media": media,
		"idx": idx,
		"sdp": sdp,
		"time": Time.get_ticks_usec()
	})

func _on_join_button_pressed():
	room_id = %JoinEdit.text
	await FunctionTest.join_room(room_id, peer_id)
	await connect_new_peers()
	
	%RoomIdEdit.text = room_id
	
func connect_new_peers():
	var peers = await FunctionTest.get_peers(room_id)
	var new_peers = peers.filter(func(p): return p != peer_id and !mpp.has_peer(p))
	for peer in new_peers:
		connect_webrtc_peer(peer)

func _on_host_button_pressed():
	room_id = await FunctionTest.host_room(peer_id)
	%RoomIdEdit.text = room_id

func _process(delta):
	mpp.poll()

func _on_peer_id_box_value_changed(value:int):
	peer_id = value

func _on_poll_timer_timeout():
	if room_id == "" or peer_id < 0:
		return
	
	# Connect to new peers that are not connected yet
	await connect_new_peers()
	
	# See if there are new WebRTC messages to update remote description
	var messages = await FunctionTest.get_messages(room_id, peer_id) as Array[Dictionary]
	var new_messages = messages.filter(
		func(msg): return !messages_cache.has(msg)
	)
	new_messages.sort_custom(func(msg1, msg2): return msg1.time < msg2.time)
	
	for new_message in new_messages:
		var peer = mpp.get_peer(new_message.src)
		if new_message.type == "offer" || new_message.type == "answer":
			peer.connection.set_remote_description(new_message.type, new_message.sdp)
		elif new_message.type == "candidate":
			peer.connection.add_ice_candidate(
				new_message.media, 
				new_message.idx,
				new_message.sdp
			)
	messages_cache = messages.duplicate(true)

func _on_timer_timeout():
	var peers = mpp.get_peers()
	print("========   %s   ========" % peer_id)
	print(mpp.get_peers().keys())
	for id in mpp.get_peers():
		var connection = mpp.get_peer(id).connection as WebRTCPeerConnection
		var channels = mpp.get_peer(id).channels as Array[WebRTCDataChannel]
		var connected = mpp.get_peer(id).connected
		
		var channel_0 = channels[0]

		print(connection.get_connection_state(), " ", connection.get_gathering_state())
		print(channel_0.get_label()," ", channel_0.get_ready_state())
		print(connected)
	print("=======================")
