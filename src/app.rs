use std::sync::Arc;
use winit::window::Window;
use tokio::sync::mpsc;

use crate::model::Model;
use crate::renderer::camera::CameraController;
use crate::renderer::renderer::Renderer;
use crate::texture::{TextureManager, TexturePanel};
use crate::ui::Ui;

pub enum TextureLoadResult {
    Success { texture_id: usize, rgba_data: Vec<u8>, width: u32, height: u32 },
    Error { texture_id: usize, error: String },
}

pub struct App {
    pub window: Arc<Window>,
    ui: Ui,
    texture_panel: TexturePanel,
    texture_manager: TextureManager,
    model: Option<Model>,
    model_path: Option<String>,
    pending_model_path: Option<String>, // Path to model that should be loaded
    renderer: Renderer,
    camera_controller: CameraController,
    current_cursor_pos: Option<(f64, f64)>,
    egui_state: egui_winit::State,
    egui_wants_pointer: bool, // Track if egui is using the pointer
    texture_receiver: mpsc::UnboundedReceiver<TextureLoadResult>,
    texture_sender: mpsc::UnboundedSender<TextureLoadResult>,
    runtime_handle: tokio::runtime::Handle,
    settings: crate::settings::Settings,
}

pub struct EventResponse {
    pub repaint: bool,
    pub exit: bool,
}

impl App {
    pub async fn new(window: Arc<Window>, runtime_handle: tokio::runtime::Handle) -> Result<Self, Box<dyn std::error::Error>> {
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

        // Create camera controller with default state
        let camera_state = crate::renderer::camera::CameraState::default();
        let camera_controller = CameraController::new(camera_state);

        let mut app = Self {
            window,
            ui,
            texture_panel: TexturePanel::new(),
            texture_manager: TextureManager::new(),
            model: None,
            model_path: None,
            pending_model_path: None,
            renderer,
            camera_controller,
            current_cursor_pos: None,
            egui_state,
            egui_wants_pointer: false,
            texture_receiver,
            texture_sender,
            runtime_handle,
            settings,
        };

        // Initialize renderer colors from loaded settings
        app.renderer.update_colors(&app.settings, None);

        Ok(app)
    }

    pub fn handle_event(&mut self, event: &winit::event::WindowEvent) -> EventResponse {
        // Let egui handle the event first
        let egui_response = self.egui_state.on_window_event(&self.window, event);
        
        // For keyboard and some events, if egui consumed it, don't process further
        let egui_wants_input = egui_response.consumed;

        // Handle window events
        match event {
            winit::event::WindowEvent::CloseRequested => {
                return EventResponse {
                    repaint: false,
                    exit: true,
                };
            }
            winit::event::WindowEvent::KeyboardInput { event, .. } => {
                if egui_wants_input {
                    return EventResponse { repaint: egui_response.repaint, exit: false };
                }
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
                self.camera_controller.on_mouse_button(*button, is_pressed);
            }
            winit::event::WindowEvent::ModifiersChanged(modifiers) => {
                let shift = modifiers.state().shift_key();
                let alt = modifiers.state().alt_key();
                self.camera_controller.on_modifiers(shift, alt);
            }
            winit::event::WindowEvent::CursorMoved { position, .. } => {
                self.current_cursor_pos = Some((position.x, position.y));
                self.camera_controller.on_mouse_move((position.x, position.y));
            }
            winit::event::WindowEvent::MouseWheel { delta, .. } => {
                let window_size = self.window.inner_size();
                let aspect = window_size.width as f32 / window_size.height as f32;
                
                match delta {
                    winit::event::MouseScrollDelta::LineDelta(_, y) => {
                        let scroll_delta = *y;
                        let cursor_ndc = self.get_cursor_ndc();
                        self.camera_controller.zoom(scroll_delta, cursor_ndc, aspect);
                    }
                    winit::event::MouseScrollDelta::PixelDelta(pos) => {
                        let scroll_delta = pos.y as f32 * 0.05;
                        let cursor_ndc = self.get_cursor_ndc();
                        self.camera_controller.zoom(scroll_delta, cursor_ndc, aspect);
                    }
                }
            }
            winit::event::WindowEvent::PinchGesture { delta, .. } => {
                let window_size = self.window.inner_size();
                let aspect = window_size.width as f32 / window_size.height as f32;
                let zoom_delta = *delta as f32 * 100.0;
                let cursor_ndc = self.get_cursor_ndc();
                self.camera_controller.zoom(zoom_delta, cursor_ndc, aspect);
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

    fn get_cursor_ndc(&self) -> Option<[f32; 2]> {
        if let Some((cx, cy)) = self.current_cursor_pos {
            let window_size = self.window.inner_size();
            let viewport_width = window_size.width as f32;
            let viewport_height = window_size.height as f32;
            
            if cx >= 0.0 && (cx as f32) < viewport_width && cy >= 0.0 && (cy as f32) < viewport_height {
                let ndc_x = (cx as f32 / viewport_width) * 2.0 - 1.0;
                let ndc_y = 1.0 - (cy as f32 / viewport_height) * 2.0;
                return Some([ndc_x, ndc_y]);
            }
        }
        None
    }

    pub fn render(&mut self) -> Result<(), wgpu::SurfaceError> {
        // Process any textures that finished loading
        while let Ok(result) = self.texture_receiver.try_recv() {
            match result {
                TextureLoadResult::Success { texture_id, rgba_data, width, height } => {
                    println!("Applying loaded texture {} to renderer", texture_id);
                    self.renderer.load_texture_from_rgba(&rgba_data, width, height, texture_id);
                    
                    // Update texture manager status
                    if let Some(texture_info) = self.texture_manager.get_texture_mut(texture_id) {
                        texture_info.status = crate::texture::TextureStatus::Loaded;
                        texture_info.width = width;
                        texture_info.height = height;
                        texture_info.progress = 1.0;
                    }
                }
                TextureLoadResult::Error { texture_id, error } => {
                    eprintln!("Texture {} failed to load: {}", texture_id, error);
                    
                    // Update texture manager status to error
                    if let Some(texture_info) = self.texture_manager.get_texture_mut(texture_id) {
                        texture_info.status = crate::texture::TextureStatus::ErrorLocal(error);
                        texture_info.progress = 0.0;
                    }
                }
            }
        }
        
        let raw_input = self.egui_state.take_egui_input(&self.window);
        let egui_ctx = self.renderer.egui_context();
        
        // Get camera orientation for axis gizmo
        let (camera_yaw, camera_pitch) = self.renderer.get_camera_orientation();
        
        let mut reset_camera = false;
        let mut panel_width = 0.0; // No left panel anymore
        let mut show_geosets = Vec::new();
        let mut colors_changed = false;
        let mut open_model = false;
        let mut texture_load_requests: Vec<usize> = Vec::new();
        
        let full_output = egui_ctx.run(raw_input, |ctx| {
            (reset_camera, panel_width, show_geosets, colors_changed, open_model) = self.ui.show(
                ctx, 
                &self.model, 
                camera_yaw, 
                camera_pitch, 
                &mut self.settings,
                &mut self.texture_panel,
            );
            
            // Show texture panel
            if let Some(requests) = self.texture_panel.show(ctx, &self.texture_manager, &mut self.renderer, &mut self.settings.ui.show_texture_panel) {
                texture_load_requests = requests;
            }
        });
        
        // Update egui pointer state for next frame
        self.egui_wants_pointer = egui_ctx.wants_pointer_input();
        
        // Process texture load requests
        for texture_id in texture_load_requests {
            self.start_texture_load(texture_id);
        }
        
        // Handle Open Model button
        if open_model {
            if let Some(path) = rfd::FileDialog::new()
                .add_filter("MDX Model", &["mdx"])
                .add_filter("MDL Model", &["mdl"])
                .pick_file()
            {
                if let Some(path_str) = path.to_str() {
                    self.pending_model_path = Some(path_str.to_string());
                }
            }
        }
        
        // Handle reset camera button
        if reset_camera {
            self.camera_controller.reset();
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

        let show_skeleton = self.settings.display.show_skeleton;
        let show_grid = self.settings.display.show_grid;
        let show_bounding_box = self.settings.display.show_bounding_box;
        let wireframe_mode = self.settings.display.wireframe_mode;
        let far_plane = self.settings.display.far_plane;

        // Sync camera state to renderer
        self.renderer.update_camera_state(self.camera_controller.state());

        self.renderer.render(show_skeleton, show_grid, show_bounding_box, wireframe_mode, far_plane, panel_width, &show_geosets, paint_jobs, full_output.textures_delta, screen_descriptor)
    }

    pub fn take_pending_model_path(&mut self) -> Option<String> {
        self.pending_model_path.take()
    }

    pub async fn load_model(&mut self, path: &str) -> Result<(), Box<dyn std::error::Error>> {
        println!("Loading model: {}", path);
        
        let model = crate::parser::load_mdl(path)?;
        
        // Initialize texture manager with model path and textures
        self.model_path = Some(path.to_string());
        self.texture_manager.set_model_path(std::path::Path::new(path));
        self.texture_manager.init_from_model(&model);
        self.renderer.update_model(&model);
        
        // First, create RID textures (they are generated, not loaded)
        for (texture_id, texture) in model.textures.iter().enumerate() {
            if texture.replaceable_id == 1 {
                // Team color (RID 1) - create solid color texture
                println!("Creating team color texture for texture {}", texture_id);
                self.renderer.create_team_color_texture(texture_id);
                // Mark as loaded immediately
                if let Some(info) = self.texture_manager.get_texture_mut(texture_id) {
                    info.status = crate::texture::TextureStatus::Loaded;
                    info.width = 4;
                    info.height = 4;
                }
            } else if texture.replaceable_id == 2 {
                // Team glow (RID 2) - create 32x32 glow texture with alpha map
                println!("Creating team glow texture for texture {}", texture_id);
                self.renderer.create_team_glow_texture(texture_id);
                // Mark as loaded immediately
                if let Some(info) = self.texture_manager.get_texture_mut(texture_id) {
                    info.status = crate::texture::TextureStatus::Loaded;
                    info.width = 32;
                    info.height = 32;
                }
            }
        }
        
        // Search for local textures (collect paths first to avoid borrow issues)
        // Only search for non-RID textures (replaceable_id == 0)
        let local_paths: Vec<(usize, Option<std::path::PathBuf>)> = self.texture_manager.textures
            .iter()
            .enumerate()
            .map(|(id, texture_info)| {
                let path = if texture_info.replaceable_id == 0 && !texture_info.filename.is_empty() {
                    self.texture_manager.find_local_path(&texture_info.filename)
                } else {
                    None
                };
                (id, path)
            })
            .collect();
        
        // Apply found paths and auto-load local textures
        for (id, path) in local_paths {
            if let Some(local_path) = path {
                println!("Found local texture: {}", local_path.display());
                if let Some(texture_info) = self.texture_manager.get_texture_mut(id) {
                    texture_info.local_path = Some(local_path);
                    // Auto-load only if not already loaded
                    if !texture_info.is_loaded() {
                        // Start loading in next iteration to avoid borrow issues
                    }
                }
            }
        }
        
        // Auto-load found textures that are not yet loaded
        // Skip RID textures (replaceable_id > 0) - they are generated, not loaded
        let textures_to_load: Vec<usize> = self.texture_manager.textures
            .iter()
            .filter(|t| t.local_path.is_some() && !t.is_loaded() && t.replaceable_id == 0)
            .map(|t| t.texture_id)
            .collect();
        
        for texture_id in textures_to_load {
            self.start_texture_load(texture_id);
        }
        
        // Start background texture loading tasks for non-RID textures
        for (texture_id, texture) in model.textures.iter().enumerate() {
            // Skip all RID textures (replaceable_id > 0) - they are already created above
            if texture.replaceable_id > 0 {
                continue;
            }
            
            let texture_path = texture.filename.clone();
            
            if texture_path.is_empty() {
                continue; // Skip if no texture to load
            }
            
            let sender = self.texture_sender.clone();
            
            // Spawn background task
            tokio::spawn(async move {
                println!("Background loading texture {}: {}", texture_id, texture_path);
                match crate::texture::load_texture(&texture_path).await {
                    Ok((rgba_data, width, height)) => {
                        println!("Successfully loaded texture {} ({}x{}) in background", texture_id, width, height);
                        let _ = sender.send(TextureLoadResult::Success { 
                            texture_id, 
                            rgba_data, 
                            width, 
                            height 
                        });
                    }
                    Err(e) => {
                        eprintln!("Failed to load texture {} ({}): {}", texture_id, texture_path, e);
                        let _ = sender.send(TextureLoadResult::Error { 
                            texture_id, 
                            error: e.to_string() 
                        });
                    }
                }
            });
        }
        
        self.model = Some(model);
        println!("Model loaded successfully");
        
        Ok(())
    }
    
    fn start_texture_load(&mut self, texture_id: usize) {
        if let Some(texture_info) = self.texture_manager.get_texture(texture_id) {
            // Skip RID textures - they are generated, not loaded
            if texture_info.replaceable_id > 0 {
                println!("Skipping texture {} - RID {} textures are generated, not loaded", 
                    texture_id, texture_info.replaceable_id);
                return;
            }
            
            let filename = texture_info.filename.clone();
            let local_path = texture_info.local_path.clone();
            let sender = self.texture_sender.clone();
            
            // Update status to loading
            if let Some(info) = self.texture_manager.get_texture_mut(texture_id) {
                info.status = if local_path.is_some() {
                    crate::texture::TextureStatus::LoadingLocal
                } else {
                    crate::texture::TextureStatus::LoadingRemote
                };
                info.progress = 0.0;
            }
            
            // Spawn background task using runtime handle
            self.runtime_handle.spawn(async move {
                println!("Loading texture {}: {}", texture_id, filename);
                
                let result = if let Some(path) = local_path {
                    // Try local first
                    match crate::texture::load_from_file(&path).await {
                        Ok(data) => crate::texture::decode_blp(&data),
                        Err(local_err) => {
                            println!("Local load failed ({}), trying remote", local_err);
                            crate::texture::load_texture(&filename).await
                        }
                    }
                } else {
                    // Load from remote
                    crate::texture::load_texture(&filename).await
                };
                
                match result {
                    Ok((rgba_data, width, height)) => {
                        println!("Successfully loaded texture {} ({}x{})", texture_id, width, height);
                        let _ = sender.send(TextureLoadResult::Success { 
                            texture_id, 
                            rgba_data, 
                            width, 
                            height 
                        });
                    }
                    Err(e) => {
                        eprintln!("Failed to load texture {} ({}): {}", texture_id, filename, e);
                        let _ = sender.send(TextureLoadResult::Error { 
                            texture_id, 
                            error: e.to_string() 
                        });
                    }
                }
            });
        }
    }
}