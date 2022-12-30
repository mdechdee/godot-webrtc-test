extends Control

@onready var mpp := multiplayer.multiplayer_peer as WebRTCMultiplayerPeer
var peer_id := -1
var room_id := ""

var offers: Array[Dictionary] = []
var candidates: Array[Dictionary] = []
var answers: Array[Dictionary] = []

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
	print("session_description created: %s | %s | %d" % [type, sdp, dst_id])
	mpp.get_peer(dst_id).connection.set_local_description(type, sdp)
	FunctionTest.store_message(room_id, {
		"src": peer_id,
		"dst": dst_id,
		"type": type,
		"sdp": sdp
	})


func on_ice_candidate_created(media: String, idx: int, sdp: String, dst_id: int):
	FunctionTest.store_message(room_id, {
		"src": peer_id,
		"dst": dst_id,
		"type": "candidate",
		"media": media,
		"idx": idx,
		"sdp": sdp
	})

func _on_join_button_pressed():
	room_id = %JoinEdit.text
	await FunctionTest.join_room(room_id, peer_id)
	await connect_new_peers()
	
	%RoomIdEdit.text = room_id
	
func connect_new_peers():
	var peers = await FunctionTest.get_peers(room_id)
	var new_peers = peers.filter(func(p): return p != peer_id and !mpp.has_peer(p))
	print(new_peers)
	for peer in new_peers:
		connect_webrtc_peer(peer)

func _on_host_button_pressed():
	room_id = await FunctionTest.host_room(peer_id)
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

func _on_poll_timer_timeout():
	if room_id == "" or peer_id < 0:
		return
	
	# Connect to new peers that are not connected yet
	await connect_new_peers()
	
	# See if there are new WebRTC messages to update remote description
	var messages = await FunctionTest.get_messages(room_id, peer_id)
	if messages == null: return
	
	# important!: make sure to process candidates before offer/answer 
	var new_candidates = messages.candidates
	new_candidates.filter(func(candidate): !candidates.has(candidate))
	for new_candidate in new_candidates:
		var peer = mpp.get_peer(new_candidate.src)
		peer.connection.add_ice_candidate(
			new_candidate.media, 
			new_candidate.idx,
			new_candidate.sdp
		)
	
	var new_offers = messages.offers 
	new_offers.filter(func(offer): !offers.has(offer))
	for new_offer in new_offers:
		var peer = mpp.get_peer(new_offer.src)
		peer.connection.set_remote_description(new_offer.type, new_offer.sdp)
	offers = new_offers
	
	var new_answers =  messages.answers
	new_answers.filter(func(answer): !answers.has(answer))
	for new_answer in new_answers:
		var peer = mpp.get_peer(new_answer.src)
		peer.connection.set_remote_description(new_answer.type, new_answer.sdp)
	

	
