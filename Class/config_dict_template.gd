extends Node

const user_profile :={
	"user_name" : "AnonymousAetherer"
}
const model_provider_settings :={
	"siliconflow":{
		"base_url":"https://api.siliconflow.cn/v1",
		"api_key":""
	},
	"openrouter":{
		"base_url":"https://openrouter.ai/api/v1",
		"api_key":""
	}
}

const model_list_db_init := {
	"uid": {"data_type": "text", "primary_key": true, "not_null": true, "unique": true},
	"provider": {"data_type": "text"},
	"model_id": {"data_type": "text"}
}
