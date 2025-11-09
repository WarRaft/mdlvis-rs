use crate::app::app::App;
use crate::app::handler_registry;
use crate::model::model::Model;
use crate::renderer::camera::CameraController;
use crate::renderer::renderer::Renderer;
use crate::settings::Settings;
use crate::texture::loader::TextureLoadResult;
use crate::texture::manager::TextureManager;
use crate::texture::panel::TexturePanel;
use crate::ui::Ui;
use egui_winit::State;
use tokio::runtime::Runtime;
use tokio::sync::mpsc;
use winit::application::ApplicationHandler;
use winit::event::WindowEvent;
use winit::event_loop::ActiveEventLoop;
use winit::window::{Window, WindowId};

pub struct AppHandler {
    pub app: Option<App>,
    pub model_path: Option<String>,
    pub runtime: Runtime,
    pub window: Option<Window>,
    pub texture_receiver: mpsc::UnboundedReceiver<TextureLoadResult>,
    pub texture_sender: mpsc::UnboundedSender<TextureLoadResult>,
    pub(crate) model: Option<Model>,
    pub pending_model_path: Option<String>,
    pub current_cursor_pos: Option<(f64, f64)>,
    pub ui: Ui,
    pub camera_controller: CameraController,
    pub animation_system: crate::animation::AnimationSystem,
    pub egui_wants_pointer: bool,
    pub texture_panel: TexturePanel,
    pub texture_manager: TextureManager,
    pub settings: Settings,
    pub egui_state: Option<State>,
    pub renderer: Option<Renderer>,
}

impl ApplicationHandler for AppHandler {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.window.is_none() {
            self.window = Some(
                event_loop
                    .create_window(
                        Window::default_attributes()
                            .with_title("MDLVis-RS - Warcraft 3 Model Viewer")
                            .with_inner_size(winit::dpi::LogicalSize::new(1200.0, 800.0)),
                    )
                    .unwrap(),
            );

            let egui_ctx = egui::Context::default();
            egui_ctx.options_mut(|options| {
                options.max_passes = std::num::NonZero::new(2).unwrap();
            });

            self.egui_state = Some(State::new(
                egui_ctx,
                egui::viewport::ViewportId::ROOT,
                &self.window.as_ref().unwrap(),
                None,
                None,
                None,
            ));

            let rt = Runtime::new().unwrap();
            self.renderer = Some(
                rt.block_on(async { Renderer::new(&self.window.as_ref().unwrap()).await })
                    .unwrap(),
            );

            self.renderer
                .as_mut()
                .unwrap()
                .update_colors(&self.settings, None);
        }

        if self.app.is_none() {
            let app = self.runtime.block_on(App::new()).unwrap();
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
                if let Some(window) = &self.window {
                    window.request_redraw();
                }
            }
            if response.exit {
                event_loop.exit();
            }
        }
    }

    fn about_to_wait(&mut self, _event_loop: &ActiveEventLoop) {
        if let Some(app) = &mut self.app {
            // Check if there's a pending model to load
            if let Some(path) = self.pending_model_path.take() {
                if let Err(e) = self.runtime.block_on(app.load_model(&path)) {
                    eprintln!("Failed to load model '{}': {}", path, e);
                }
            }

            if let Err(e) = app.render() {
                eprintln!("Render error: {:?}", e);
            }
            if let Some(window) = &self.window {
                window.request_redraw();
            }
        }
    }
}

impl Drop for AppHandler {
    fn drop(&mut self) {
        // Unregister global pointer on drop to avoid dangling pointer usage.
        handler_registry::unregister();
    }
}
