extends Node

var user_profile : Dictionary
var model_provider_settings : Dictionary

var model_list_http : HTTPRequest

var model_list_db : SQLite

#region window size variable
var window_size : Vector2i
#endregion

func _ready() -> void:
	load_user_profile()
	load_model_list_db()
	load_model_provider_settings()
	
	
#region load config
func touch_yaml(path : String, init_content : Variant) -> bool:
	if FileAccess.file_exists(path):
		return false
	var new_file = FileAccess.open(path,FileAccess.WRITE)
	var string = YAMLWriter.save_string(
		init_content
	)
	new_file.store_string(string)
	new_file.close()
	return true

func load_user_profile():
	if touch_yaml(ConfigPath.user_profile,ConfigDictTemplate.user_profile):
		user_profile = ConfigDictTemplate.user_profile
	else:
		user_profile = YAMLLoader.load_file(ConfigPath.user_profile)

func load_model_provider_settings():
	if touch_yaml(ConfigPath.model_provider_settings,ConfigDictTemplate.model_provider_settings):
		model_provider_settings = ConfigDictTemplate.model_provider_settings
	else:
		model_provider_settings = YAMLLoader.load_file(ConfigPath.model_provider_settings)
	
	model_list_http = HTTPRequest.new()
	model_list_http.request_completed.connect(_on_http_request_complete)
	add_child(model_list_http)
	
	for provider in model_provider_settings:
		if model_provider_settings[provider].base_url:
			await request_model_list(provider)

#endregion

#region http request for model list
##a bit nasty hack
var requested_data : Dictionary
var http_response_code : int

func request_model_list(provider : String):
	
	var base_url : String = model_provider_settings[provider].base_url
	var api_key : String
	if model_provider_settings[provider].api_key:
		api_key = model_provider_settings[provider].api_key
	
	var inserting_rows : Array
	
	match provider:
		"siliconflow":
			#print(ModelProviderHttpTemplate.header.siliconflow % api_key)
			model_list_http.request(
				ModelProviderHttpTemplate.request_url.siliconflow,
				[ModelProviderHttpTemplate.header.siliconflow % api_key]
			)
			await http_request_complete
			if http_response_code == 200:
				for item in requested_data.data:
					inserting_rows.append(
						{"uid": "siliconflow/"+item.id,"provider": "siliconflow", "model_id": item.id}
					)
			
		"openrouter":
			model_list_http.request(
				ModelProviderHttpTemplate.request_url.openrouter
			)
			await http_request_complete
			if http_response_code == 200:
				for item in requested_data.data:
					inserting_rows.append(
						{"uid": "openrouter/"+item.id,"provider": "openrouter", "model_id": item.id}
					)
		_:
			return
	
	model_list_db.insert_rows("model_id",inserting_rows)


		
signal http_request_complete(response_code)

func _on_http_request_complete(result, response_code, headers, body):
	if response_code == 200:
		requested_data = JSON.parse_string(
			body.get_string_from_utf8()
		)
	http_response_code = response_code
	http_request_complete.emit(response_code)

#endregion

#region sqlite database load
func load_model_list_db():
	model_list_db = SQLite.new()
	model_list_db.path = ConfigPath.model_list_db
	model_list_db.open_db()
	model_list_db.create_table(
		"model_id",
		ConfigDictTemplate.model_list_db_init
	)
#endregion
