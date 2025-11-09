mod animation;
mod app;
mod error;
mod material;
mod model;
mod parser;
mod renderer;
mod settings;
mod texture;
mod ui;

use crate::app::handler::AppHandler;
use crate::error::MdlError;
use tokio::runtime::Runtime;
use winit::event_loop::{ControlFlow, EventLoop};

const CONFY_APP_NAME: &str = "mdlvis-rs";

fn main() -> Result<(), MdlError> {
    std::panic::set_hook(Box::new(|panic_info| {
        let message = if let Some(s) = panic_info.payload().downcast_ref::<&str>() {
            s.to_string()
        } else if let Some(s) = panic_info.payload().downcast_ref::<String>() {
            s.clone()
        } else {
            "Unknown panic".to_string()
        };

        let location = if let Some(location) = panic_info.location() {
            format!(
                "\n\nLocation: {}:{}:{}",
                location.file(),
                location.line(),
                location.column()
            )
        } else {
            String::new()
        };

        let full_message = format!("MDLVis-RS crashed!\n\n{}{}", message, location);

        eprintln!("{}", full_message);

        // Show native error dialog
        #[cfg(not(target_os = "linux"))]
        {
            use rfd::MessageDialog;
            MessageDialog::new()
                .set_title("MDLVis-RS Error")
                .set_description(&full_message)
                .set_level(rfd::MessageLevel::Error)
                .show();
        }

        #[cfg(target_os = "linux")]
        {
            eprintln!("\n{}\n", "=".repeat(80));
            eprintln!("Please report this error to the developers.");
            eprintln!("{}\n", "=".repeat(80));
        }
    }));

    let event_loop = EventLoop::new()?;
    event_loop.set_control_flow(ControlFlow::Poll);

    // Defer window creation to the ApplicationHandler::resumed callback
    // (creating a window before the event loop is active is deprecated).
    event_loop.run_app(&mut AppHandler {
        app: None,
        model_path: std::env::args().skip(1).next().map(String::from),
        runtime: Runtime::new()?,
        window: None,
    })?;

    Ok(())
}
