use std::sync::Arc;
use tokio::runtime::Runtime;
use winit::application::ApplicationHandler;
use winit::event::WindowEvent;
use winit::event_loop::ActiveEventLoop;
use winit::window::{Window, WindowId};
use crate::app::app::App;

pub struct AppHandler {
    pub app: Option<App>,
    pub model_path: Option<String>,
    pub runtime: Runtime,
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
                .block_on(App::new(Arc::new(window), runtime_handle))
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