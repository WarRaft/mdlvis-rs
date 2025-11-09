use crate::error::MdlError;
use crate::model::model::Model;
use crate::parser::load::load;
use crate::renderer::camera::{CameraController, CameraState};
use crate::renderer::renderer::Renderer;
use crate::settings::Settings;
use crate::texture::loader::{TextureLoadResult, load_texture};
use crate::texture::manager::{TextureManager, TextureStatus};
use crate::texture::panel::TexturePanel;
use crate::ui::Ui;
use egui_wgpu::ScreenDescriptor;
use egui_winit::State;
use std::fs::File;

/// Temporary helper to access the global AppHandler registered in `handler_registry`.
/// Unsafe: returns a mutable reference from a raw pointer. Use only in quick refactor.
pub fn get_global_handler_mut() -> Option<&'static mut crate::app::handler::AppHandler> {
    if let Some(raw) = crate::app::handler_registry::get_raw() {
        unsafe { Some(&mut *(raw as *mut crate::app::handler::AppHandler)) }
    } else {
        None
    }
}

pub struct EventResponse {
    pub repaint: bool,
    pub exit: bool,
}

pub struct App {
    ui: Ui,
    model: Option<Model>,
    model_path: Option<String>,
    pub pending_model_path: Option<String>, // Path to model that should be loaded
    renderer: Renderer,
    camera_controller: CameraController,
    animation_system: crate::animation::AnimationSystem,
    current_cursor_pos: Option<(f64, f64)>,
    egui_state: State,
    egui_wants_pointer: bool,
    texture_panel: TexturePanel,
    pub texture_manager: TextureManager,
    settings: Settings,
}

impl App {
    pub async fn new() -> Result<Self, MdlError> {
        // Initialize UI
        let ui = Ui::new();

        let handler = get_global_handler_mut().unwrap();

        let window = handler.window.as_ref().unwrap();

        // Initialize renderer
        let renderer = Renderer::new(&window).await?;

        // Initialize egui_winit state
        let egui_ctx = renderer.egui_context();

        // Enable egui persistence for collapsing headers, windows, etc.
        egui_ctx.options_mut(|options| {
            options.max_passes = std::num::NonZero::new(2).unwrap();
        });

        let egui_state = State::new(
            egui_ctx.clone(),
            egui::viewport::ViewportId::ROOT,
            &window,
            None,
            None,
            None,
        );

        // Load settings
        let settings = Settings::load();

        // Create camera controller with default state
        let camera_state = CameraState::default();
        let camera_controller = CameraController::new(camera_state);

        let mut app = Self {
            ui,
            texture_panel: TexturePanel::new(),
            texture_manager: TextureManager::new(),
            model: None,
            model_path: None,
            pending_model_path: None,
            renderer,
            camera_controller,
            animation_system: crate::animation::AnimationSystem::new(),
            current_cursor_pos: None,
            egui_state,
            egui_wants_pointer: false,
            settings,
        };

        // Initialize renderer colors from loaded settings
        app.renderer.update_colors(&app.settings, None);

        Ok(app)
    }

    pub fn handle_event(&mut self, event: &winit::event::WindowEvent) -> EventResponse {
        let handler = get_global_handler_mut().unwrap();
        let window = handler.window.as_ref().unwrap();

        // Let egui handle the event first
        let egui_response = self.egui_state.on_window_event(&window, event);

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
                    return EventResponse {
                        repaint: egui_response.repaint,
                        exit: false,
                    };
                }
                if event.logical_key
                    == winit::keyboard::Key::Named(winit::keyboard::NamedKey::Escape)
                {
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
                // Don't handle mouse input if egui wants the pointer
                if self.egui_wants_pointer {
                    return EventResponse {
                        repaint: egui_response.repaint,
                        exit: false,
                    };
                }
                let is_pressed = *state == winit::event::ElementState::Pressed;
                self.camera_controller.on_mouse_button(*button, is_pressed);
            }
            winit::event::WindowEvent::ModifiersChanged(modifiers) => {
                let shift = modifiers.state().shift_key();
                let alt = modifiers.state().alt_key();
                let control = modifiers.state().control_key();
                self.camera_controller.on_modifiers(shift, alt, control);
            }
            winit::event::WindowEvent::CursorMoved { position, .. } => {
                // Don't handle mouse movement if egui wants the pointer
                if self.egui_wants_pointer {
                    return EventResponse {
                        repaint: egui_response.repaint,
                        exit: false,
                    };
                }
                self.current_cursor_pos = Some((position.x, position.y));
                self.camera_controller
                    .on_mouse_move((position.x, position.y));
            }
            winit::event::WindowEvent::MouseWheel { delta, .. } => {
                // Don't handle mouse wheel if egui wants the pointer
                if self.egui_wants_pointer {
                    return EventResponse {
                        repaint: egui_response.repaint,
                        exit: false,
                    };
                }
                match delta {
                    winit::event::MouseScrollDelta::LineDelta(_, y) => {
                        // Real mouse wheel - simple zoom
                        self.camera_controller.simple_zoom(*y);
                    }
                    winit::event::MouseScrollDelta::PixelDelta(pos) => {
                        // Trackpad scroll (two fingers) - handle like PanGesture
                        let control = self.camera_controller.is_control_pressed();
                        let shift = self.camera_controller.is_shift_pressed();
                        self.camera_controller.on_pan_gesture(
                            pos.x as f32 * 0.05,
                            -pos.y as f32 * 0.05,
                            control,
                            shift,
                        );
                    }
                }
            }
            winit::event::WindowEvent::PanGesture { delta, phase, .. } => {
                // Don't handle pan gesture if egui wants the pointer
                if self.egui_wants_pointer {
                    return EventResponse {
                        repaint: egui_response.repaint,
                        exit: false,
                    };
                }
                // Two-finger swipe gesture - ONLY WAY to control camera with trackpad:
                // - No modifiers: rotate around grid center (0,0,0)
                // - Shift: pan (move target)
                // - Control: zoom (change distance)
                use winit::event::TouchPhase;
                if matches!(phase, TouchPhase::Moved) {
                    let control = self.camera_controller.is_control_pressed();
                    let shift = self.camera_controller.is_shift_pressed();
                    self.camera_controller
                        .on_pan_gesture(delta.x, -delta.y, control, shift);
                }
            }
            _ => {}
        }

        EventResponse {
            repaint: false,
            exit: false,
        }
    }

    pub fn render(&mut self) -> Result<(), wgpu::SurfaceError> {
        let handler = get_global_handler_mut().unwrap();

        while let Ok(result) = handler.texture_receiver.try_recv() {
            match result {
                TextureLoadResult::Success {
                    texture_id,
                    rgba_data,
                    width,
                    height,
                } => {
                    self.renderer
                        .load_texture_from_rgba(&rgba_data, width, height, texture_id);

                    // Update texture manager status
                    if let Some(texture_info) = self.texture_manager.get_texture_mut(texture_id) {
                        texture_info.status = TextureStatus::Loaded;
                        texture_info.width = width;
                        texture_info.height = height;
                        texture_info.progress = 1.0;
                    }
                }
                TextureLoadResult::Error { texture_id, error } => {
                    // Update texture manager status to error ONLY if not already loaded
                    if let Some(texture_info) = self.texture_manager.get_texture_mut(texture_id) {
                        // Don't overwrite successful load with error from background task
                        if !texture_info.is_loaded() {
                            texture_info.status = TextureStatus::Error(error);
                            texture_info.progress = 0.0;
                        } else {
                            println!(
                                "Ignoring error for texture {} - already loaded successfully",
                                texture_id
                            );
                        }
                    }
                }
            }
        }

        let handler = get_global_handler_mut().unwrap();
        let window = handler.window.as_ref().unwrap();

        let raw_input = self.egui_state.take_egui_input(&window);
        let egui_ctx = self.renderer.egui_context();

        // Get camera orientation for axis gizmo
        let (camera_yaw, camera_pitch) = self.renderer.camera.get_orientation();

        // Update animation playback BEFORE UI (so current_frame is up-to-date)
        let current_time = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs_f64();
        self.ui.animate(&self.model, current_time);

        let mut reset_camera = false;
        let mut current_frame = 0.0;
        let mut show_geosets = Vec::new();
        let mut colors_changed = false;
        let mut open_model = false;
        let mut texture_load_requests: Vec<usize> = Vec::new();
        let mut use_animation = false;

        let full_output = egui_ctx.run(raw_input, |ctx| {
            let (
                reset_camera_ui,
                current_frame_ui,
                show_geosets_ui,
                colors_changed_ui,
                open_model_ui,
                use_animation_ui,
            ) = self.ui.show(
                ctx,
                &mut self.model,
                camera_yaw,
                camera_pitch,
                &mut self.settings,
                &mut self.renderer,
            );

            reset_camera = reset_camera_ui;
            current_frame = current_frame_ui;
            show_geosets = show_geosets_ui;
            colors_changed = colors_changed_ui;
            open_model = open_model_ui;
            use_animation = use_animation_ui;

            // Show texture panel
            if let Some(requests) = self.texture_panel.show(
                ctx,
                &self.texture_manager,
                &mut self.renderer,
                &mut self.settings.ui.show_texture_panel,
            ) {
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
            self.renderer
                .update_colors(&self.settings, self.model.as_ref());
        }

        self.egui_state
            .handle_platform_output(&window, full_output.platform_output);

        let paint_jobs = egui_ctx.tessellate(full_output.shapes, full_output.pixels_per_point);

        let screen_descriptor = ScreenDescriptor {
            size_in_pixels: [window.inner_size().width, window.inner_size().height],
            pixels_per_point: window.scale_factor() as f32,
        };

        let show_skeleton = self.settings.display.show_skeleton;
        let show_grid = self.settings.display.show_grid;
        let show_bounding_box = self.settings.display.show_bounding_box;
        let wireframe_mode = self.settings.display.wireframe_mode;
        let far_plane = self.settings.display.far_plane;

        // Update animation ONLY if use_animation flag is enabled
        if use_animation && self.model.is_some() && !self.animation_system.bones.is_empty() {
            self.animation_system.update(current_frame);
            self.renderer.update_animation(&self.animation_system);
        } else {
            // Reset to original parsed vertices (no animation)
            self.renderer.reset_to_original_vertices();
        }

        // Sync camera state to renderer
        self.renderer.camera = self.camera_controller.state().clone();

        self.renderer.render(
            self.model.as_ref(),
            show_skeleton,
            show_grid,
            show_bounding_box,
            wireframe_mode,
            far_plane,
            &show_geosets,
            paint_jobs,
            full_output.textures_delta,
            screen_descriptor,
        )
    }

    pub async fn load_model(&mut self, path: &str) -> Result<(), MdlError> {
        println!("Loading model: {}", path);

        let handler = get_global_handler_mut().unwrap();

        let mut file = File::open(path)?;

        let model = load(&mut file)?;

        // Initialize texture manager with model path and textures
        self.model_path = Some(path.to_string());
        self.texture_manager
            .set_model_path(std::path::Path::new(path));
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
                    info.status = TextureStatus::Loaded;
                    info.width = 4;
                    info.height = 4;
                }
            } else if texture.replaceable_id == 2 {
                // Team glow (RID 2) - create 32x32 glow texture with alpha map
                println!("Creating team glow texture for texture {}", texture_id);
                self.renderer.create_team_glow_texture(texture_id);
                // Mark as loaded immediately
                if let Some(info) = self.texture_manager.get_texture_mut(texture_id) {
                    info.status = TextureStatus::Loaded;
                    info.width = 32;
                    info.height = 32;
                }
            }
        }

        // Search for local textures (collect paths first to avoid borrow issues)
        // Only search for non-RID textures (replaceable_id == 0)
        let local_paths: Vec<(usize, Option<std::path::PathBuf>)> = self
            .texture_manager
            .textures
            .iter()
            .enumerate()
            .map(|(id, texture_info)| {
                let path = if texture_info.replaceable_id == 0 && !texture_info.filename.is_empty()
                {
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
        let textures_to_load: Vec<usize> = self
            .texture_manager
            .textures
            .iter()
            .filter(|t| t.local_path.is_some() && !t.is_loaded() && t.replaceable_id == 0)
            .map(|t| t.texture_id)
            .collect();

        for texture_id in textures_to_load {
            self.start_texture_load(texture_id);
        }

        // Start background texture loading tasks for non-RID textures
        // BUT: Skip textures that were found locally (they're already loading via start_texture_load)
        for (texture_id, texture) in model.textures.iter().enumerate() {
            // Skip all RID textures (replaceable_id > 0) - they are already created above
            if texture.replaceable_id > 0 {
                continue;
            }

            // Skip textures that were found locally - they're already being loaded
            if let Some(texture_info) = self.texture_manager.get_texture(texture_id) {
                if texture_info.local_path.is_some() {
                    println!(
                        "Skipping background load for texture {} - found locally",
                        texture_id
                    );
                    continue;
                }
            }

            let texture_path = texture.filename.clone();

            if texture_path.is_empty() {
                continue; // Skip if no texture to load
            }

            let sender = handler.texture_sender.clone();

            // Spawn background task to download from internet
            tokio::spawn(async move {
                match load_texture(&texture_path).await {
                    Ok((rgba_data, width, height)) => {
                        let _ = sender.send(TextureLoadResult::Success {
                            texture_id,
                            rgba_data,
                            width,
                            height,
                        });
                    }
                    Err(e) => {
                        let _ = sender.send(TextureLoadResult::Error {
                            texture_id,
                            error: e.to_string(),
                        });
                    }
                }
            });
        }

        self.model = Some(model.clone());

        // Initialize animation system with bones
        println!("Initializing animation system...");
        self.animation_system.init_from_model(&model);
        println!("Animation system initialized");

        // Reset animation state for new model
        println!("Resetting UI animation state...");
        self.ui.reset_animation(&self.model);
        println!("UI animation state reset");

        println!("Model loaded successfully");

        Ok(())
    }
}
