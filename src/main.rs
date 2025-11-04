use std::sync::Arc;
use winit::{
    application::ApplicationHandler,
    event::WindowEvent,
    event_loop::{ActiveEventLoop, ControlFlow, EventLoop},
    window::{Window, WindowId},
};

mod app;
mod material_system;
mod model;
mod parser;
mod pipeline_system;
mod renderer;
mod settings;
mod texture_loader;
mod ui;

struct AppHandler {
    app: Option<app::App>,
    model_path: Option<String>,
    rt: tokio::runtime::Runtime,
}

impl ApplicationHandler for AppHandler {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.app.is_none() {
            let window_attrs = Window::default_attributes()
                .with_title("MDLVis-RS - Warcraft 3 Model Viewer")
                .with_inner_size(winit::dpi::LogicalSize::new(1200.0, 800.0));
            
            let window = event_loop.create_window(window_attrs).unwrap();
            let mut app = self.rt.block_on(app::App::new(Arc::new(window))).unwrap();
            
            // Load model if provided as command line argument
            if let Some(path) = &self.model_path {
                if let Err(e) = self.rt.block_on(app.load_model(path)) {
                    eprintln!("Failed to load model '{}': {}", path, e);
                }
            }
            
            self.app = Some(app);
        }
    }

    fn window_event(&mut self, event_loop: &ActiveEventLoop, _window_id: WindowId, event: WindowEvent) {
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
            if let Err(e) = app.render() {
                eprintln!("Render error: {:?}", e);
            }
            app.window.request_redraw();
        }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();

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
        rt: tokio::runtime::Runtime::new()?,
    };

    event_loop.run_app(&mut handler)?;

    Ok(())
}
