use leptos::prelude::*;
use leptos::html::Div;
use thaw::*;

#[derive(Clone)]
pub enum MessageRole {
    User,
    Assistant,
    System,
}

#[derive(Clone)]
pub struct ChatMessage {
    pub content: String,
    pub role: MessageRole,
}

#[component]
pub fn ChatBubble(
    #[prop(into)] message: ChatMessage,
) -> impl IntoView {
    let is_user = matches!(message.role, MessageRole::User);
    view! {
        <div class={move || if is_user { "chat-bubble user-message" } else { "chat-bubble ai-message" }}>
            {message.content}
        </div>
    }
}

#[component]
pub fn ChatMessages(
    messages: ReadSignal<Vec<ChatMessage>>,
) -> impl IntoView {
    let messages_container = NodeRef::<Div>::new();
    
    let _ = Effect::new(move |_| {
        let _ = messages.get();
        request_animation_frame(move || {
            request_animation_frame(move || {
                if let Some(div) = messages_container.get() {
                    div.set_scroll_top(div.scroll_height());
                }
            });
        });
    });

    view! {
        <div class="messages-scroll-container">
            <div 
                class="chat-messages" 
                node_ref=messages_container
                on:scroll=move |_| {
                    if let Some(div) = messages_container.get() {
                        let at_bottom = (div.scroll_height() - div.scroll_top() - div.client_height()) < 2;
                        if at_bottom {
                            let _ = Effect::new(move |_| {
                                request_animation_frame(move || {
                                    if let Some(div) = messages_container.get() {
                                        div.set_scroll_top(div.scroll_height());
                                    }
                                });
                            });
                        }
                    }
                }
            >
                {move || messages.get().into_iter().map(|message| {
                    view! {
                        <ChatBubble message=message />
                    }
                }).collect::<Vec<_>>()}
            </div>
        </div>
    }
}

#[component]
pub fn MainPage() -> impl IntoView {
    let (has_chat, set_has_chat) = signal(false);
    let (messages, set_messages) = signal(Vec::new());

    let handle_send = move |input: String| {
        set_messages.update(|msgs| {
            msgs.push(ChatMessage {
                content: input,
                role: MessageRole::User,
            });
            msgs.push(ChatMessage {
                content: "这是一个模拟的 AI 响应，稍后将被实际的 AI 响应替代。".to_string(),
                role: MessageRole::Assistant,
            });
        });
        if !has_chat.get() {
            set_has_chat.set(true);
        }
    };

    view! {
        <div class="app-container">
            {move || if !has_chat.get() {
                view! {
                    <div class="main-page">
                        <Flex vertical=true justify=FlexJustify::Center align=FlexAlign::Center gap=FlexGap::Size(20)>
                            <Image src="/public/assets/app_icon.png" width="40%" height="40%" />
                            <div>"连接已建立"</div>
                            <div>"以太界访问正常"</div>
                            <Button 
                                class="primary-button"
                                on:click=move |_| set_has_chat.set(true)
                            >
                                "开始对话"
                            </Button>
                        </Flex>
                    </div>
                }.into_any()
            } else {
                view! {
                    <div class="chat-page">
                        <div class="chat-header">
                            <Button 
                                class="return-button"
                                on:click=move |_| set_has_chat.set(false)
                            >
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <path d="M19 12H5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M12 19L5 12L12 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </Button>
                        </div>
                        <div class="chat-container">
                            <ChatMessages messages=messages />
                        </div>
                        <UserInput on_send=handle_send />
                    </div>
                }.into_any()
            }}
        </div>
    }
}

#[component]
pub fn UserInput(
    on_send: impl Fn(String) + 'static + Send + Sync,
) -> impl IntoView {
    let user_input = RwSignal::new(String::new());
    
    let send = StoredValue::new(move || {
        let input = user_input.get();
        if !input.trim().is_empty() {
            on_send(input);
            user_input.set(String::new());
        }
    });

    view! {
        <div class="input-container">
            <div>
                <Textarea 
                    value=user_input 
                    class="user-input-box"
                    on:keydown=move |e| {
                        if e.key() == "Enter" && !e.shift_key() {
                            e.prevent_default();
                            send.with_value(|f| f());
                        }
                    }
                />
                <Button 
                    class="submit-button primary-button"
                    on:click=move |_| send.with_value(|f| f())
                >
                    <Flex gap=FlexGap::Size(8) align=FlexAlign::Center>
                        "发送"
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M22 2L11 13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M22 2L15 22L11 13L2 9L22 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </Flex>
                </Button>
            </div>
        </div>
    }
}