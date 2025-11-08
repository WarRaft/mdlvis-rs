use crate::error::MdlError;
use std::sync::Arc;
use tokio::runtime::Runtime;
use winit::{
    application::ApplicationHandler,
    event::WindowEvent,
    event_loop::{ActiveEventLoop, ControlFlow, EventLoop},
    window::{Window, WindowId},
};

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

struct AppHandler {
    app: Option<app::App>,
    model_path: Option<String>,
    runtime: Runtime,
}

impl ApplicationHandler for AppHandler {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.app.is_none() {
            let window_attrs = Window::default_attributes()
                .with_title("MDLVis-RS - Warcraft 3 Model Viewer")
                .with_inner_size(winit::dpi::LogicalSize::new(1200.0, 800.0));

            let window = event_loop.create_window(window_attrs).unwrap();
            let runtime_handle = self.runtime.handle().clone();
            let mut app = self
                .runtime
                .block_on(app::App::new(Arc::new(window), runtime_handle))
                .unwrap();

            // Load model if provided as command line argument
            if let Some(path) = &self.model_path {
                if let Err(e) = self.runtime.block_on(app.load_model(path)) {
                    eprintln!("Failed to load model '{}': {}", path, e);
                }
            }

            self.app = Some(app);
        }
    }

    fn window_event(
        &mut self,
        event_loop: &ActiveEventLoop,
        _window_id: WindowId,
        event: WindowEvent,
    ) {
        if let Some(app) = &mut self.app {
            let response = app.handle_event(&event);
            if response.repaint {
                app.window.request_redraw();
            }
            if response.exit {
                event_loop.exit();
            }
        }
    }

    fn about_to_wait(&mut self, _event_loop: &ActiveEventLoop) {
        if let Some(app) = &mut self.app {
            // Check if there's a pending model to load
            if let Some(path) = app.pending_model_path.take() {
                if let Err(e) = self.runtime.block_on(app.load_model(&path)) {
                    eprintln!("Failed to load model '{}': {}", path, e);
                }
            }

            if let Err(e) = app.render() {
                eprintln!("Render error: {:?}", e);
            }
            app.window.request_redraw();
        }
    }
}

fn main() -> Result<(), MdlError> {
    env_logger::init();

    // Set up panic hook to show error dialog
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

    // Parse command line arguments
    let args: Vec<String> = std::env::args().collect();
    let model_path = if args.len() > 1 {
        Some(args[1].clone())
    } else {
        None
    };

    let event_loop = EventLoop::new()?;
    event_loop.set_control_flow(ControlFlow::Poll);

    let mut handler = AppHandler {
        app: None,
        model_path,
        runtime: Runtime::new()?,
    };

    event_loop.run_app(&mut handler)?;

    Ok(())
}
