extends Node

var tcp_server: TCPServer = TCPServer.new()
var connections: Array[StreamPeerTCP] = []
var DEFAULT_PORT := 7070

func _ready():
	var port = DEFAULT_PORT
	while tcp_server.listen(port) != OK:
		port += 1
	print(port)

func _process(delta):
	# Keep communicating with connected TCP connections
	for cnn in connections:
		cnn.poll()
		# Check if connection still exists, remove it if not
		if cnn.get_status() != StreamPeerTCP.Status.STATUS_CONNECTED:
			connections.erase(cnn)
			continue
		# Get the data from connection
		var bytes = cnn.get_available_bytes()
		var data = cnn.get_utf8_string(bytes)
		if data.length() > 0: print(data)

	# Receive new TCP connection
	if tcp_server.is_connection_available():
		var cnn = tcp_server.take_connection()
		connections.append(cnn)
		print("%s:%s->%s %d" % [cnn.get_connected_host(), 
			cnn.get_connected_port(), 
			cnn.get_local_port(), 
			cnn.get_status()]
		)

func send_message(message: String):
	for cnn in connections:
		cnn.put_utf8_string(message)

