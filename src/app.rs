use std::sync::Arc;
use winit::window::Window;
use tokio::sync::mpsc;

use crate::model::Model;
use crate::renderer::renderer::Renderer;
use crate::ui::Ui;

pub struct App {
    pub window: Arc<Window>,
    ui: Ui,
    model: Option<Model>,
    renderer: Renderer,
    left_mouse_pressed: bool,
    middle_mouse_pressed: bool,
    shift_pressed: bool,
    trackpad_pressed: bool, // Track if trackpad is physically pressed during gesture
    current_cursor_pos: Option<(f64, f64)>,
    last_mouse_pos: Option<(f64, f64)>,
    egui_state: egui_winit::State,
    texture_receiver: mpsc::UnboundedReceiver<(usize, Vec<u8>, u32, u32)>, // (texture_id, rgba_data, width, height)
    texture_sender: mpsc::UnboundedSender<(usize, Vec<u8>, u32, u32)>, // For loading textures
    settings: crate::settings::Settings,
}

pub struct EventResponse {
    pub repaint: bool,
    pub exit: bool,
}

impl App {
    pub async fn new(window: Arc<Window>) -> Result<Self, Box<dyn std::error::Error>> {
        // Initialize UI
        let ui = Ui::new();

        // Initialize renderer
        let renderer = Renderer::new(&window).await?;

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

        // Create channel for background texture loading
        let (texture_sender, texture_receiver) = mpsc::unbounded_channel();

        // Load settings
        let settings = crate::settings::Settings::load();

        let mut app = Self {
            window,
            ui,
            model: None,
            renderer,
            left_mouse_pressed: false,
            middle_mouse_pressed: false,
            shift_pressed: false,
            trackpad_pressed: false,
            current_cursor_pos: None,
            last_mouse_pos: None,
            egui_state,
            texture_receiver,
            texture_sender,
            settings,
        };

        // Initialize renderer colors from loaded settings
        app.renderer.update_colors(&app.settings, None);

        Ok(app)
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
                let is_pressed = *state == winit::event::ElementState::Pressed;
                match button {
                    winit::event::MouseButton::Left => {
                        self.left_mouse_pressed = is_pressed;
                        // Track trackpad press (left click during gesture)
                        self.trackpad_pressed = is_pressed;
                        if !self.left_mouse_pressed {
                            self.last_mouse_pos = None;
                        }
                    }
                    winit::event::MouseButton::Middle => {
                        self.middle_mouse_pressed = is_pressed;
                        if !self.middle_mouse_pressed {
                            self.last_mouse_pos = None;
                        }
                    }
                    _ => {}
                }
            }
            winit::event::WindowEvent::ModifiersChanged(modifiers) => {
                self.shift_pressed = modifiers.state().shift_key();
            }
            winit::event::WindowEvent::CursorMoved { position, .. } => {
                self.current_cursor_pos = Some((position.x, position.y));
                
                if self.left_mouse_pressed && self.shift_pressed {
                    // Pan camera with Shift+LMB (for trackpad users)
                    if let Some(last_pos) = self.last_mouse_pos {
                        let delta_x = position.x - last_pos.0;
                        let delta_y = position.y - last_pos.1;
                        self.renderer.pan_camera(delta_x as f32, delta_y as f32);
                    }
                    self.last_mouse_pos = Some((position.x, position.y));
                } else if self.left_mouse_pressed {
                    // Orbit camera
                    if let Some(last_pos) = self.last_mouse_pos {
                        let delta_x = position.x - last_pos.0;
                        let delta_y = position.y - last_pos.1;
                        self.renderer.rotate_camera(delta_x as f32, delta_y as f32);
                    }
                    self.last_mouse_pos = Some((position.x, position.y));
                } else if self.middle_mouse_pressed {
                    // Pan camera with middle mouse button
                    if let Some(last_pos) = self.last_mouse_pos {
                        let delta_x = position.x - last_pos.0;
                        let delta_y = position.y - last_pos.1;
                        self.renderer.pan_camera(delta_x as f32, -delta_y as f32);
                    }
                    self.last_mouse_pos = Some((position.x, position.y));
                }
            }
            winit::event::WindowEvent::MouseWheel { delta, phase, .. } => {
                match delta {
                    winit::event::MouseScrollDelta::LineDelta(_, y) => {
                        // Mouse wheel - zoom
                        let scroll_delta = *y;
                        
                        // Convert cursor position to NDC for zoom-to-cursor
                        let cursor_ndc = if let Some((cx, cy)) = self.current_cursor_pos {
                            let window_size = self.window.inner_size();
                            let panel_width = self.ui.get_panel_width();
                            let panel_width_pixels = panel_width * window_size.width as f32;
                            
                            // Viewport is to the right of the panel
                            let viewport_x = cx as f32 - panel_width_pixels;
                            let viewport_width = window_size.width as f32 - panel_width_pixels;
                            let viewport_height = window_size.height as f32;
                            
                            if viewport_x >= 0.0 && viewport_x < viewport_width && cy >= 0.0 && (cy as f32) < viewport_height {
                                // Convert to NDC [-1, 1]
                                let ndc_x = (viewport_x / viewport_width) * 2.0 - 1.0;
                                let ndc_y = 1.0 - (cy as f32 / viewport_height) * 2.0;
                                Some([ndc_x, ndc_y])
                            } else {
                                None
                            }
                        } else {
                            None
                        };
                        
                        self.renderer.zoom_camera(scroll_delta, cursor_ndc);
                    }
                    winit::event::MouseScrollDelta::PixelDelta(pos) => {
                        // Trackpad - two finger gesture
                        use winit::event::TouchPhase;
                        
                        if matches!(phase, TouchPhase::Moved) {
                            if self.trackpad_pressed {
                                // Trackpad physically pressed + two fingers = pan camera
                                let pan_speed = 1.0;
                                self.renderer.pan_camera(pos.x as f32 * pan_speed, pos.y as f32 * pan_speed);
                            } else {
                                // Two finger drag = rotate camera
                                let rotation_speed = 0.5;
                                self.renderer.rotate_camera(pos.x as f32 * rotation_speed, pos.y as f32 * rotation_speed);
                            }
                        }
                    }
                }
            }
            winit::event::WindowEvent::PinchGesture { delta, .. } => {
                // Pinch gesture for zoom
                let zoom_delta = *delta as f32 * 100.0; // Scale for appropriate zoom speed
                
                // Convert cursor position to NDC for zoom-to-cursor
                let cursor_ndc = if let Some((cx, cy)) = self.current_cursor_pos {
                    let window_size = self.window.inner_size();
                    let panel_width = self.ui.get_panel_width();
                    let panel_width_pixels = panel_width * window_size.width as f32;
                    
                    let viewport_x = cx as f32 - panel_width_pixels;
                    let viewport_width = window_size.width as f32 - panel_width_pixels;
                    let viewport_height = window_size.height as f32;
                    
                    if viewport_x >= 0.0 && viewport_x < viewport_width && cy >= 0.0 && (cy as f32) < viewport_height {
                        let ndc_x = (viewport_x / viewport_width) * 2.0 - 1.0;
                        let ndc_y = 1.0 - (cy as f32 / viewport_height) * 2.0;
                        Some([ndc_x, ndc_y])
                    } else {
                        None
                    }
                } else {
                    None
                };
                
                self.renderer.zoom_camera(zoom_delta, cursor_ndc);
            }
            winit::event::WindowEvent::RotationGesture { delta, .. } => {
                // Two-finger rotation gesture for camera rotation
                let rotation_speed = 2.0;
                self.renderer.rotate_camera(*delta * rotation_speed, 0.0);
            }
            winit::event::WindowEvent::PanGesture { delta, phase, .. } => {
                // Two-finger drag gesture for camera rotation
                use winit::event::TouchPhase;
                if matches!(phase, TouchPhase::Moved) {
                    let rotation_speed = 0.5;
                    self.renderer.rotate_camera(delta.x * rotation_speed, -delta.y * rotation_speed);
                }
            }
            _ => {}
        }

        EventResponse { repaint: false, exit: false }
    }

    pub fn render(&mut self) -> Result<(), wgpu::SurfaceError> {
        // Process any textures that finished loading
        while let Ok((texture_id, rgba_data, width, height)) = self.texture_receiver.try_recv() {
            println!("Applying loaded texture {} to renderer", texture_id);
            self.renderer.load_texture_from_rgba(&rgba_data, width, height, texture_id);
        }
        
        let raw_input = self.egui_state.take_egui_input(&self.window);
        let egui_ctx = self.renderer.egui_context();
        
        // Get camera orientation for axis gizmo
        let (camera_yaw, camera_pitch) = self.renderer.get_camera_orientation();
        
        let mut reset_camera = false;
        let mut panel_width = 0.0;
        let mut show_geosets: Vec<bool> = Vec::new();
        let mut colors_changed = false;
        let full_output = egui_ctx.run(raw_input, |ctx| {
            (reset_camera, panel_width, show_geosets, colors_changed) = self.ui.show(ctx, &self.model, camera_yaw, camera_pitch, &mut self.settings);
        });
        
        // Handle reset camera button
        if reset_camera {
            self.renderer.reset_camera();
        }
        
        // Update renderer colors if they changed
        if colors_changed {
            self.renderer.update_colors(&self.settings, self.model.as_ref());
        }

        self.egui_state.handle_platform_output(&self.window, full_output.platform_output);

        let paint_jobs = egui_ctx.tessellate(full_output.shapes, full_output.pixels_per_point);
        
        let screen_descriptor = egui_wgpu::ScreenDescriptor {
            size_in_pixels: [self.window.inner_size().width, self.window.inner_size().height],
            pixels_per_point: self.window.scale_factor() as f32,
        };

        let show_skeleton = self.settings.show_skeleton;
        let show_grid = self.settings.show_grid;
        let show_bounding_box = self.settings.show_bounding_box;
        let wireframe_mode = self.settings.wireframe_mode;
        let far_plane = self.settings.far_plane;

        self.renderer.render(show_skeleton, show_grid, show_bounding_box, wireframe_mode, far_plane, panel_width, &show_geosets, paint_jobs, full_output.textures_delta, screen_descriptor)
    }

    pub async fn load_model(&mut self, path: &str) -> Result<(), Box<dyn std::error::Error>> {
        println!("Loading model: {}", path);
        
        let model = crate::parser::load_mdl(path)?;
        self.renderer.update_model(&model);
        
        // For replaceable textures, create appropriate textures
        for (texture_id, texture) in model.textures.iter().enumerate() {
            if texture.replaceable_id == 1 {
                // Team color (RID 1) - find first real texture to use
                println!("Texture {} is team color (RID 1) - will load texture", texture_id);
            } else if texture.replaceable_id == 2 {
                // Team glow (RID 2) - create 32x32 glow texture with alpha map
                println!("Creating team glow texture for texture {}", texture_id);
                self.renderer.create_team_glow_texture(texture_id);
            }
        }
        
        // Start background texture loading tasks
        for (texture_id, texture) in model.textures.iter().enumerate() {
            // Skip team glow (RID 2) - already created above
            if texture.replaceable_id == 2 {
                continue;
            }
            
            // For replaceable textures (team color RID 1), use first real texture
            // For normal textures, use their own filename
            let texture_path = if texture.replaceable_id == 1 {
                // For team color (RID 1), use first real texture as source
                model.textures.iter()
                    .find(|t| t.replaceable_id == 0 && !t.filename.is_empty())
                    .map(|t| t.filename.clone())
                    .unwrap_or_default()
            } else {
                // For normal textures, use their own filename
                texture.filename.clone()
            };
            
            if texture_path.is_empty() {
                continue; // Skip if no texture to load
            }
            
            let sender = self.texture_sender.clone();
            
            // Spawn background task
            tokio::spawn(async move {
                println!("Background loading texture {}: {}", texture_id, texture_path);
                match crate::texture_loader::load_texture(&texture_path).await {
                    Ok((rgba_data, width, height)) => {
                        println!("Successfully loaded texture {} ({}x{}) in background", texture_id, width, height);
                        let _ = sender.send((texture_id, rgba_data, width, height));
                    }
                    Err(e) => {
                        eprintln!("Failed to load texture {} ({}): {}", texture_id, texture_path, e);
                    }
                }
            });
        }
        
        self.model = Some(model);
        println!("Model loaded successfully");
        
        Ok(())
    }
}