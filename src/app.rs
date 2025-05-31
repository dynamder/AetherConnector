use leptos::prelude::*;
use thaw::*;
use crate::components::MainPage;

#[component]
pub fn App() -> impl IntoView {
    view! {
        <Flex 
            vertical=true 
            justify=FlexJustify::Start
            align=FlexAlign::Stretch 
            style="min-height: 100vh; padding-top: 50px;"
        >
            <MainPage/>
        </Flex>
    }
}
