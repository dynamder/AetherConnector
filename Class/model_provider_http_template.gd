extends Node

const request_url := {
	"siliconflow": "https://api.siliconflow.cn/v1/models",
	"openrouter": "https://openrouter.ai/api/v1/models"
}

const header := {
	"siliconflow": "Authorization: Bearer %s",
	"openrouter": ""
}
