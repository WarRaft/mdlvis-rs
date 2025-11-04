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
        
        // Enable egui persistence for collapsing headers, windows, etc.
        egui_ctx.options_mut(|options| {
            options.max_passes = std::num::NonZero::new(2).unwrap();
        });
        
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
                
                // Try to load first non-empty texture asynchronously
                if let Some(texture) = model.textures.iter().find(|t| !t.filename.is_empty() && t.replaceable_id == 0) {
                    let texture_path = &texture.filename;
                    println!("Attempting to load texture: {}", texture_path);
                    
                    match crate::texture_loader::load_texture(texture_path).await {
                        Ok((rgba_data, width, height)) => {
                            println!("Successfully downloaded and decoded texture: {}x{}", width, height);
                            renderer.load_texture_from_rgba(&rgba_data, width, height);
                        }
                        Err(e) => {
                            eprintln!("Failed to load texture {}: {}", texture_path, e);
                            eprintln!("Continuing with default white texture...");
                        }
                    }
                }
                
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
        
        // Get axis label positions before UI render (uses previous frame's matrix)
        let axis_labels = self.renderer.get_axis_label_positions();
        let team_color = self.renderer.get_team_color();
        
        let mut reset_camera = false;
        let mut new_team_color: Option<[f32; 3]> = None;
        let full_output = egui_ctx.run(raw_input, |ctx| {
            (reset_camera, new_team_color) = self.ui.show(ctx, &self.model, axis_labels, team_color);
        });
        
        // Handle reset camera button
        if reset_camera {
            self.renderer.reset_camera();
        }
        
        // Handle team color change
        if let Some(color) = new_team_color {
            self.renderer.set_team_color(color);
        }

        self.egui_state.handle_platform_output(&self.window, full_output.platform_output);

        let paint_jobs = egui_ctx.tessellate(full_output.shapes, full_output.pixels_per_point);
        
        let screen_descriptor = egui_wgpu::ScreenDescriptor {
            size_in_pixels: [self.window.inner_size().width, self.window.inner_size().height],
            pixels_per_point: self.window.scale_factor() as f32,
        };

        let show_skeleton = self.ui.settings.show_skeleton;
        let show_grid = self.ui.settings.show_grid;
        let wireframe_mode = self.ui.settings.wireframe_mode;
        let far_plane = self.ui.settings.far_plane;

        self.renderer.render(show_skeleton, show_grid, wireframe_mode, far_plane, paint_jobs, full_output.textures_delta, screen_descriptor)
    }
}