extends Node

const HOST: String = "127.0.0.1"
const PORT: int = 5000
const RECONNECT_TIMEOUT: float = 3.0

var _client: TCPClient = TCPClient.new()

func _ready() -> void:
	_client.debug = true
	_client.connected.connect(_handle_client_connected)
	_client.disconnected.connect(_handle_client_disconnected)
	_client.error.connect(_handle_client_error)
	_client.receive_data.connect(_handle_client_data)
	
	_client.reconnect_timeout = RECONNECT_TIMEOUT
	_client.max_reconnect_try = 4
	add_child(_client)
	_client.connect_to_host(HOST, PORT)


func _handle_client_connected() -> void:
	print("Client connected to server.")

func _handle_client_data(data: PackedByteArray) -> void:
	print("Client data: ", data.get_string_from_utf8())
	var message: PackedByteArray = [97, 99, 107] # Bytes for "ack" in ASCII
	_client.send_packet(message)

func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	

func _handle_client_error() -> void:
	print("Client error.")
