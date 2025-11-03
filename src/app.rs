use std::sync::Arc;
use winit::window::Window;

use crate::model::Model;
use crate::ui::Ui;
use crate::renderer::Renderer;

pub struct App {
    pub window: Arc<Window>,
    ui: Ui,
    model: Option<Model>,
    renderer: Renderer,
    mouse_pressed: bool,
    last_mouse_pos: Option<(f64, f64)>,
}

pub struct EventResponse {
    pub repaint: bool,
    pub exit: bool,
}

impl App {
    pub async fn new(window: Window) -> Result<Self, Box<dyn std::error::Error>> {
        let window = Arc::new(window);
        // Initialize UI
        let ui = Ui::new();

        // Initialize renderer
        let mut renderer = Renderer::new(&window).await?;

        // Load test model
        let model = match crate::parser::load_mdl("test-data/Arthas.mdx") {
            Ok(model) => {
                renderer.update_model(&model);
                Some(model)
            }
            Err(e) => {
                eprintln!("Failed to load model: {}", e);
                None
            }
        };

        Ok(Self {
            window,
            ui,
            model,
            renderer,
            mouse_pressed: false,
            last_mouse_pos: None,
        })
    }

    pub fn handle_event(&mut self, event: &winit::event::WindowEvent) -> EventResponse {
        // Handle window events
        match event {
            winit::event::WindowEvent::CloseRequested => {
                return EventResponse {
                    repaint: false,
                    exit: true,
                };
            }
            winit::event::WindowEvent::KeyboardInput { event, .. } => {
                if event.logical_key == winit::keyboard::Key::Named(winit::keyboard::NamedKey::Escape) {
                    return EventResponse {
                        repaint: false,
                        exit: true,
                    };
                }
            }
            winit::event::WindowEvent::Resized(size) => {
                self.renderer.resize(*size);
            }
            winit::event::WindowEvent::MouseInput { state, button, .. } => {
                if *button == winit::event::MouseButton::Left {
                    self.mouse_pressed = *state == winit::event::ElementState::Pressed;
                    if !self.mouse_pressed {
                        self.last_mouse_pos = None;
                    }
                }
            }
            winit::event::WindowEvent::CursorMoved { position, .. } => {
                if self.mouse_pressed {
                    if let Some(last_pos) = self.last_mouse_pos {
                        let delta_x = position.x - last_pos.0;
                        let delta_y = position.y - last_pos.1;
                        self.renderer.rotate_camera(delta_x as f32, delta_y as f32);
                    }
                    self.last_mouse_pos = Some((position.x, position.y));
                }
            }
            winit::event::WindowEvent::MouseWheel { delta, .. } => {
                let scroll_delta = match delta {
                    winit::event::MouseScrollDelta::LineDelta(_, y) => *y,
                    winit::event::MouseScrollDelta::PixelDelta(pos) => pos.y as f32 * 0.1,
                };
                self.renderer.zoom_camera(scroll_delta);
            }
            _ => {}
        }

        EventResponse { repaint: false, exit: false }
    }

    pub fn render(&mut self) -> Result<(), wgpu::SurfaceError> {
        self.renderer.render()
    }
}