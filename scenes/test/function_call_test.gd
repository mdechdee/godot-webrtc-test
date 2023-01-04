extends CanvasLayer

signal room_joined(room_id: String, peer_id: int)

var peer_id := -1
var room_id := ""
var mpp: WebRTCMultiplayerPeer

var messages_cache: Array[Dictionary] = []

func _ready():
	peer_id = %PeerIdBox.value

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
	await FunctionTest.store_message(room_id, {
		"src": peer_id,
		"dst": dst_id,
		"type": type,
		"sdp": sdp
	})
	if not mpp.has_peer(dst_id): return
	mpp.get_peer(dst_id).connection.set_local_description(type, sdp)

func on_ice_candidate_created(media: String, idx: int, sdp: String, dst_id: int):
	await FunctionTest.store_message(room_id, {
		"src": peer_id,
		"dst": dst_id,
		"type": "candidate",
		"media": media,
		"idx": idx,
		"sdp": sdp
	})

func _on_host_button_pressed():
	mpp = WebRTCMultiplayerPeer.new()
	mpp.create_mesh(peer_id)
	get_tree().get_multiplayer().multiplayer_peer = mpp
	room_id = await FunctionTest.host_room(peer_id)
	%RoomIdEdit.text = room_id
	room_joined.emit(room_id, peer_id)
	
func _on_join_button_pressed():
	mpp = WebRTCMultiplayerPeer.new()
	mpp.create_mesh(peer_id)
	get_tree().get_multiplayer().multiplayer_peer = mpp

	room_id = %JoinEdit.text
	await FunctionTest.join_room(room_id, peer_id)
	
	# Connect to existing peers on the mesh
	await connect_new_peers()
	%RoomIdEdit.text = room_id
	room_joined.emit(room_id, peer_id)
	
func connect_new_peers():
	var peers = await FunctionTest.get_peers(room_id) as Array[int]
	# get peers from the firestore, connect the ones that are not connected yet
	var new_peers = peers.filter(
		func(p): return p != peer_id and !mpp.has_peer(p)
	)
	print(new_peers)
	for peer in new_peers:
		connect_webrtc_peer(peer)
	return peers

func _process(delta):
	if mpp == null: return
	mpp.poll()

func _on_peer_id_box_value_changed(value:int):
	peer_id = value

func _on_poll_timer_timeout():
	if mpp == null: return
	
	# Connect to new peers that are not connected yet
	var peers = await connect_new_peers()
	
	# See if there are new WebRTC messages to update remote description
	var messages = await FunctionTest.get_messages(room_id, peer_id) as Array[Dictionary]
	var new_messages = messages.filter(
		func(msg): return !messages_cache.has(msg)
	)
	
	for new_message in new_messages:
		var peer = mpp.get_peer(new_message.src)
		var connection = peer.connection as WebRTCPeerConnection
		if new_message.type == "offer" || new_message.type == "answer":
			connection.set_remote_description(new_message.type, new_message.sdp)
			messages_cache.append(new_message)
		elif new_message.type == "candidate" and\
			connection.get_signaling_state() == connection.SIGNALING_STATE_STABLE:
			peer.connection.add_ice_candidate(
				new_message.media, 
				new_message.idx,
				new_message.sdp
			)
			messages_cache.append(new_message)

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
