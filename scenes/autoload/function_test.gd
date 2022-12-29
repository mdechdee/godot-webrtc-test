extends Node

const HOST_ROOM_ENDPOINT := "https://asia-southeast1-godot-serverless-function.cloudfunctions.net/helloWorld/hostRoom"
const STORE_MESSAGE_ENDPOINT := "https://asia-southeast1-godot-serverless-function.cloudfunctions.net/helloWorld/storeMessage"

func host_room():
	var http_request = HTTPRequest.new()	
	add_child(http_request)
	
	var error = http_request.request(HOST_ROOM_ENDPOINT)
	if error != OK:
		push_error("Host room failed")

	var args = await http_request.request_completed
	
	var result: int = args[0]
	var response_code: int = args[1]
	var headers: PackedStringArray = args[2]
	var body: PackedByteArray = args[3]

	print(body.get_string_from_utf8())
	return body.get_string_from_utf8()

#
func store_message(room_id: String, message: String):
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)

	# Perform a POST request. The URL below returns JSON as of writing.
	# Note: Don't make simultaneous requests using a single HTTPRequest node.
	# The snippet below is provided for reference only.
	var body = JSON.stringify({
		"roomId": room_id, 
		"message": message
	})
	http_request.request_completed.connect(_http_request_completed)
	var error = http_request.request(STORE_MESSAGE_ENDPOINT, ["content-type: application/json"], true, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
	
func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print("%d %d" % [result,response_code])
	print(response)

