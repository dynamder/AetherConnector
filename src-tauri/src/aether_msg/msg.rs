use std::sync::Arc;
use tokio::sync::RwLock;

#[derive(Clone, Debug,Serialize,Deserialize)]
pub enum MsgContent {
    Text(String),
    Image(String),
    Emoji(String)
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserInfo {
    pub username: String,
    pub id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Message {
    pub id: String,
    pub content: Arc<MsgContent>,
    pub timestamp: u64,
    pub from: UserInfo,
    pub session_id: String,

    pub references: Option<String>,
}

// 消息构建器
pub struct MessageBuilder {
    content: MsgContent,
    from: String,
    session_id: String,
    references: Option<String>,
}

impl MessageBuilder {
    pub fn new(content: MsgContent, from: String, session_id: String, references: Option<String>) -> Self {
        Self {
            content,
            from,
            session_id,
            references,
        }
    }

    // 添加回复引用
    pub fn ref_to(mut self, msg_id: String) -> Self {
        self.references = Some(msg_id);
        self
    }

    pub fn build(self) -> Message {
        Message {
            id: MessageId {
                id: generate_uuid(),
                timestamp: Utc::now(),
            },
            content: Arc::new(self.content),
            metadata: MessageMetadata {
                from: self.from,
                to: self.to,
                session_id: self.session_id,
                references: self.references,
            },
            context: RwLock::new(None),
        }
    }
}

// 使用示例
async fn example_usage() {
    let store = Arc::new(MessageStore::new());
    let renderer = MessageRenderer { message_store: store.clone() };

    // 创建一个引用回复
    let reply = Message::create_reply(
        MsgContent::Text("I agree with your point".to_string()),
        "user1".to_string(),
        "agent1".to_string(),
        "session1".to_string(),
        "original_msg_id".to_string(),
    );

    // 渲染消息（包含引用预览）
    let rendered = renderer.render_message(&reply).await?;

    // 处理消息（需要上下文分析）
    let context = reply.get_context(store.as_ref()).await?;
    process_message_with_context(&reply, &context);
}