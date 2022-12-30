extends Node

const IS_LOCAL = false
const LOCAL_ENDPOINT := "http://127.0.0.1:5001/godot-serverless-function/asia-southeast1/helloWorld"
const PROD_ENDPOINT := "https://asia-southeast1-godot-serverless-function.cloudfunctions.net/helloWorld"

const FUNCTION_ENDPOINT := LOCAL_ENDPOINT if IS_LOCAL else PROD_ENDPOINT

const HOST_ROOM_ENDPOINT := FUNCTION_ENDPOINT + "/hostRoom"
const JOIN_ROOM_ENDPOINT := FUNCTION_ENDPOINT + "/joinRoom"
const STORE_MESSAGE_ENDPOINT := FUNCTION_ENDPOINT + "/storeMessage"
const GET_PEERS_ENDPOINT := FUNCTION_ENDPOINT + "/getPeers"
const GET_MESSAGES_ENDPOINT := FUNCTION_ENDPOINT + "/getMessages"
const DEFAULT_POST_HEADER := ["content-type: application/json"]

func host_room(peer_id: int):
	var http_request = HTTPRequest.new()	
	add_child(http_request)
	var body = JSON.stringify({
		"peerId": peer_id,
	})
	var error = http_request.request(HOST_ROOM_ENDPOINT, DEFAULT_POST_HEADER, true, HTTPClient.METHOD_POST, body)
	if error != OK: push_error("Host room failed")

	var args = await http_request.request_completed
	var res_body: PackedByteArray = args[3]

	return res_body.get_string_from_utf8()

func join_room(room_id: String, peer_id: int):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var body = JSON.stringify({
		"roomId": room_id,
		"peerId": peer_id
	})
	var error = http_request.request(JOIN_ROOM_ENDPOINT, DEFAULT_POST_HEADER, true, HTTPClient.METHOD_POST, body)
	if error != OK: push_error("Join room failed")

	var args = await http_request.request_completed
	var result = args[0]
	
	return result

func store_message(room_id: String, message: Dictionary):
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var body = JSON.stringify({
		"roomId": room_id, 
		"message": message
	})
	var error = http_request.request(STORE_MESSAGE_ENDPOINT, DEFAULT_POST_HEADER, true, HTTPClient.METHOD_POST, body)
	if error != OK: push_error("Store Message Failed")

# Should return [peer_ids]
func get_peers(room_id: String) -> Array[int]:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var error = http_request.request(GET_PEERS_ENDPOINT+"?roomId="+room_id)
	if error != OK: push_error("Get Peers Failed")

	var args = await http_request.request_completed
	
	var result: int = args[0]
	var response_code: int = args[1]
	var headers: PackedStringArray = args[2]
	var res_body: PackedByteArray = args[3]
	var data = JSON.parse_string(res_body.get_string_from_utf8())
	
	if(typeof(data) != TYPE_ARRAY): return []
	return data.map(func(peer: String): return peer.to_int())

# Should return [messages]
func get_messages(room_id: String, peer_id: int) -> Array[Dictionary]:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var error = http_request.request(GET_MESSAGES_ENDPOINT+"?roomId=%s&peerId=%d" % [room_id, peer_id])
	if error != OK: push_error("Get Messages Failed")

	var args = await http_request.request_completed
	
	var result: int = args[0]
	var response_code: int = args[1]
	var headers: PackedStringArray = args[2]
	var res_body: PackedByteArray = args[3]
	var data = JSON.parse_string(res_body.get_string_from_utf8())
	
	if(typeof(data) != TYPE_DICTIONARY): return []
	return data.messages
