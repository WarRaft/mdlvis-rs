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
    egui_state: egui_winit::State,
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

        // Initialize egui_winit state
        let egui_ctx = renderer.egui_context();
        let egui_state = egui_winit::State::new(
            egui_ctx.clone(),
            egui::viewport::ViewportId::ROOT,
            &*window,
            None,
            None,
            None,
        );

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
            egui_state,
        })
    }

    pub fn handle_event(&mut self, event: &winit::event::WindowEvent) -> EventResponse {
        // Let egui handle the event first
        let egui_response = self.egui_state.on_window_event(&self.window, event);
        
        // If egui consumed the event, don't process it further
        if egui_response.consumed {
            return EventResponse { repaint: egui_response.repaint, exit: false };
        }

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
        let raw_input = self.egui_state.take_egui_input(&self.window);
        let egui_ctx = self.renderer.egui_context();
        
        let full_output = egui_ctx.run(raw_input, |ctx| {
            self.ui.show(ctx, &self.model);
        });

        self.egui_state.handle_platform_output(&self.window, full_output.platform_output);

        let paint_jobs = egui_ctx.tessellate(full_output.shapes, full_output.pixels_per_point);
        
        let screen_descriptor = egui_wgpu::ScreenDescriptor {
            size_in_pixels: [self.window.inner_size().width, self.window.inner_size().height],
            pixels_per_point: self.window.scale_factor() as f32,
        };

        self.renderer.render(paint_jobs, full_output.textures_delta, screen_descriptor)
    }
}