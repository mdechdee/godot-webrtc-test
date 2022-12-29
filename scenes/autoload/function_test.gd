extends Node

const IS_LOCAL = true
const LOCAL_ENDPOINT := "http://127.0.0.1:5001/godot-serverless-function/asia-southeast1/helloWorld"
const PROD_ENDPOINT := "https://asia-southeast1-godot-serverless-function.cloudfunctions.net/helloWorld"

const FUNCTION_ENDPOINT := LOCAL_ENDPOINT if IS_LOCAL else PROD_ENDPOINT

const HOST_ROOM_ENDPOINT := FUNCTION_ENDPOINT + "/hostRoom"
const STORE_MESSAGE_ENDPOINT := FUNCTION_ENDPOINT + "/storeMessage"
const GET_PEERS_ENDPOINT := FUNCTION_ENDPOINT + "/getPeers"
const DEFAULT_POST_HEADER := ["content-type: application/json"]

func host_room(peer_id: int):
	var http_request = HTTPRequest.new()	
	add_child(http_request)
	var body = JSON.stringify({
		"peerId": peer_id,
	})
	print(body)
	var error = http_request.request(HOST_ROOM_ENDPOINT, DEFAULT_POST_HEADER, true, HTTPClient.METHOD_POST, body)
	if error != OK: push_error("Host room failed")

	var args = await http_request.request_completed
	
	var result: int = args[0]
	var response_code: int = args[1]
	var headers: PackedStringArray = args[2]
	var res_body: PackedByteArray = args[3]

	print(res_body.get_string_from_utf8())
	return res_body.get_string_from_utf8()

func store_message(room_id: String, message: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var body = JSON.stringify({
		"roomId": room_id, 
		"message": message
	})
	http_request.request_completed.connect(_http_request_completed)
	var error = http_request.request(STORE_MESSAGE_ENDPOINT, DEFAULT_POST_HEADER, true, HTTPClient.METHOD_POST, body)
	if error != OK: push_error("Store Message Failed")

func get_peers(room_id: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(_http_request_completed)
	print(GET_PEERS_ENDPOINT+"?roomId="+room_id)
	var error = http_request.request(GET_PEERS_ENDPOINT+"?roomId="+room_id)
	if error != OK: push_error("Store Message Failed")

	var args = await http_request.request_completed
	
	var result: int = args[0]
	var response_code: int = args[1]
	var headers: PackedStringArray = args[2]
	var res_body: PackedByteArray = args[3]
	var data = JSON.parse_string(res_body.get_string_from_utf8())
	
	return data

func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print("%d %d" % [result,response_code])
	print(response)

