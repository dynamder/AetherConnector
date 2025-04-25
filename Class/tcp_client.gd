extends Node
class_name TCPClient

##important signals
signal connected
signal receive_data(data)
signal disconnected
signal error

##internal vars
var _status : int = 0
var _stream : StreamPeerTCP = StreamPeerTCP.new()

var auto_reconnect : bool = true
var reconnect_timeout : float = 3.0
var max_reconnect_try : int = 3
var _reconnect_try_times : int = 0

var _connect_host : String
var _connect_port : int = -1
var _no_delay : bool = false
#debug vars
var debug : bool = false

func _init(no_delay : bool = false) -> void:
	_no_delay = no_delay

func _ready() -> void:
	_status = _stream.get_status()
	_stream.set_no_delay(_no_delay)
	error.connect(_on_accident)
	disconnected.connect(_on_accident)
	connected.connect(func(): _reconnect_try_times = 0)
	

func connect_to_host(host : String, port : int):
	if debug:
		print("try connecting to %s:%d",[host,port])
	
	_connect_host = host
	_connect_port = port
	_status = _stream.STATUS_NONE
	if not _stream.connect_to_host(host, port) == OK:
		error.emit()
		if debug:
			print("Error connecting to %s:%d",[host,port])
	_stream.poll()
	_status = _stream.get_status()

func reconnect_to_host(host : String, port : int):
	await get_tree().create_timer(reconnect_timeout).timeout
	if debug:
		print("reconnecting to %s:%d",[host,port])
	_stream.disconnect_from_host()
	_stream.poll()
	connect_to_host(host, port)


func send_packet(data : PackedByteArray) -> bool:
	if not _status == _stream.STATUS_CONNECTED:
		if debug:
			print("Error due to unestablished connection")
		return false
	
	var _error : int = _stream.put_data(data)
	if not _error == OK:
		if debug:
			print("error when writing stream: ", error)
		return false
	
	return true


func _process(delta: float) -> void:
	_stream.poll()
	var new_status : int = _stream.get_status()
	if not _status == new_status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				if debug:
					print("disconnected from host")
				disconnected.emit()
			_stream.STATUS_CONNECTING:
				if debug:
					print("connecting to the host")
			_stream.STATUS_CONNECTED:
				if debug:
					print("connected to host")
				connected.emit()
			_stream.STATUS_ERROR:
				if debug:
					print("error with stream")
				error.emit()
	
	if _status == _stream.STATUS_CONNECTED:
		var available_bytes : int = _stream.get_available_bytes()
		if available_bytes > 0:
			if debug:
				print("available bytes:", available_bytes)
			var data : Array = _stream.get_partial_data(available_bytes)
			
			if not data[0] == OK:
				if debug:
					print("error getting data from stream: ", data[0])
				error.emit()
			else:
				receive_data.emit(data[1])

func _on_accident():
	if auto_reconnect and _reconnect_try_times < max_reconnect_try:
		_reconnect_try_times += 1
		if debug:
			print("reconnect try times: %d" % _reconnect_try_times)
		reconnect_to_host(_connect_host,_connect_port)
	else:
		if debug:
			print("abort retry of reconnecting server")
		
func reset():
	_reconnect_try_times = 0
	_connect_host = ""
	_connect_port = -1
	if _status == _stream.STATUS_CONNECTED:
		_stream.disconnect_from_host()
		_status = _stream.STATUS_NONE
