use crate::model::Model;
use crate::settings::Settings;

pub struct Ui {
    show_geosets: Vec<bool>,
    selected_sequence: usize,
    animation_time: f32,
    is_playing: bool,
}

impl Ui {
    pub fn new() -> Self {
        Self {
            show_geosets: Vec::new(),
            selected_sequence: 0,
            animation_time: 0.0,
            is_playing: false,
        }
    }

    pub fn show(
        &mut self,
        ctx: &egui::Context,
        model: &Option<Model>,
        camera_yaw: f32,
        camera_pitch: f32,
        settings: &mut Settings,
        _texture_panel: &mut crate::texture::TexturePanel,
    ) -> (bool, f32, Vec<bool>, bool, bool) {
        let mut reset_camera = false;
        let mut colors_changed = false;
        let mut open_model = false;

        // Main menu bar at the top
        egui::TopBottomPanel::top("menu_bar").show(ctx, |ui| {
            ui.horizontal_wrapped(|ui| {
                // Open Model button
                if ui.button("📁 Open Model").clicked() {
                    open_model = true;
                }
                
                ui.separator();
                ui.label("📋 Windows:");
                
                if ui.button(if settings.ui.show_texture_panel { "✅ Textures" } else { "⬜ Textures" }).clicked() {
                    settings.ui.show_texture_panel = !settings.ui.show_texture_panel;
                    settings.ui.save();
                }
                
                if ui.button(if settings.ui.show_display_settings { "✅ Display" } else { "⬜ Display" }).clicked() {
                    settings.ui.show_display_settings = !settings.ui.show_display_settings;
                    settings.ui.save();
                }
                
                if ui.button(if settings.ui.show_colors { "✅ Colors" } else { "⬜ Colors" }).clicked() {
                    settings.ui.show_colors = !settings.ui.show_colors;
                    settings.ui.save();
                }
                
                if ui.button(if settings.ui.show_model_info { "✅ Model Info" } else { "⬜ Model Info" }).clicked() {
                    settings.ui.show_model_info = !settings.ui.show_model_info;
                    settings.ui.save();
                }
                
                if ui.button(if settings.ui.show_geosets { "✅ Geosets" } else { "⬜ Geosets" }).clicked() {
                    settings.ui.show_geosets = !settings.ui.show_geosets;
                    settings.ui.save();
                }
                
                if ui.button(if settings.ui.show_materials { "✅ Materials" } else { "⬜ Materials" }).clicked() {
                    settings.ui.show_materials = !settings.ui.show_materials;
                    settings.ui.save();
                }
                
                if ui.button(if settings.ui.show_animation { "✅ Animation" } else { "⬜ Animation" }).clicked() {
                    settings.ui.show_animation = !settings.ui.show_animation;
                    settings.ui.save();
                }
            });
        });

        // Show windows based on UI settings
        if settings.ui.show_display_settings {
            reset_camera = self.show_display_settings_window(ctx, settings);
        }
        
        if settings.ui.show_colors {
            colors_changed = self.show_colors_window(ctx, settings);
        }
        
        if settings.ui.show_model_info {
            self.show_model_info_window(ctx, model, &mut settings.ui);
        }
        
        if settings.ui.show_geosets {
            self.show_geosets_window(ctx, model, &mut settings.ui);
        }
        
        if settings.ui.show_materials {
            self.show_materials_window(ctx, model, &mut settings.ui);
        }
        
        if settings.ui.show_animation {
            self.show_animation_window(ctx, model, &mut settings.ui);
        }

        // Draw axis gizmo in bottom-right corner
        let gizmo_size = 80.0;
        let gizmo_margin = 20.0;

        // Get screen size - use available_rect which gives actual rendering area
        let screen_rect = ctx.viewport_rect();

        // Calculate bottom-right corner position
        let gizmo_x = screen_rect.max.x - gizmo_size - gizmo_margin;
        let gizmo_y = screen_rect.max.y - gizmo_size - gizmo_margin;
        let center = egui::pos2(gizmo_x + gizmo_size / 2.0, gizmo_y + gizmo_size / 2.0);
        let radius = gizmo_size / 2.5;

        // Calculate axis directions based on camera orientation
        let x_angle = -camera_yaw;
        let x_dir = egui::vec2(x_angle.cos(), -x_angle.sin()) * radius;
        let x_end = center + x_dir;

        let y_angle = -camera_yaw + std::f32::consts::FRAC_PI_2;
        let y_dir = egui::vec2(y_angle.cos(), -y_angle.sin()) * radius * camera_pitch.cos();
        let y_end = center + y_dir;

        let z_dir = egui::vec2(0.0, -camera_pitch.sin() * radius);
        let z_end = center + z_dir;

        // Get painter directly from ctx
        let painter = ctx.layer_painter(egui::LayerId::new(
            egui::Order::Foreground,
            egui::Id::new("axis_gizmo_painter"),
        ));
        let font_id = egui::FontId::proportional(16.0);

        // Draw circle background
        painter.circle_filled(
            center,
            gizmo_size / 2.0,
            egui::Color32::from_rgba_premultiplied(30, 30, 30, 200),
        );
        painter.circle_stroke(
            center,
            gizmo_size / 2.0,
            egui::Stroke::new(1.0, egui::Color32::from_gray(100)),
        );

        // Calculate depth
        let x_depth = (-camera_yaw).sin();
        let y_depth = (-camera_yaw - std::f32::consts::FRAC_PI_2).sin();
        let z_depth = camera_pitch.sin();

        // Sort and draw axes
        let mut axes = vec![
            (x_depth, egui::Color32::from_rgb(255, 80, 80), x_end, "X"),
            (y_depth, egui::Color32::from_rgb(80, 255, 80), y_end, "Y"),
            (z_depth, egui::Color32::from_rgb(100, 150, 255), z_end, "Z"),
        ];
        axes.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());

        for (depth, color, end, label) in axes {
            if depth > 0.0 {
                painter.line_segment([center, end], egui::Stroke::new(3.0, color));
                painter.text(
                    end,
                    egui::Align2::CENTER_CENTER,
                    label,
                    font_id.clone(),
                    color,
                );
            } else {
                let darker = egui::Color32::from_rgba_premultiplied(
                    (color.r() as f32 * 0.3) as u8,
                    (color.g() as f32 * 0.3) as u8,
                    (color.b() as f32 * 0.3) as u8,
                    150,
                );
                painter.line_segment([center, end], egui::Stroke::new(2.0, darker));
            }
        }

        (
            reset_camera,
            0.0, // No panel width anymore
            self.show_geosets.clone(),
            colors_changed,
            open_model,
        )
    }

    fn show_display_settings_window(
        &mut self,
        ctx: &egui::Context,
        settings: &mut Settings,
    ) -> bool {
        let mut reset_camera = false;
        
        egui::Window::new("🎨 Display Settings")
            .default_width(300.0)
            .resizable(true)
            .open(&mut settings.ui.show_display_settings)
            .show(ctx, |ui| {
                let mut changed = false;
                
                changed |= ui.checkbox(&mut settings.display.show_skeleton, "Show Skeleton").changed();
                changed |= ui.checkbox(&mut settings.display.wireframe_mode, "Wireframe Mode").changed();
                changed |= ui.checkbox(&mut settings.display.show_grid, "Show Grid").changed();
                changed |= ui.checkbox(&mut settings.display.show_bounding_box, "Show Bounding Box").changed();

                ui.separator();
                ui.label("Far Plane (View Distance):");
                changed |= ui
                    .add(
                        egui::Slider::new(&mut settings.display.far_plane, 100.0..=5000.0)
                            .suffix(" units")
                            .logarithmic(true),
                    )
                    .changed();

                if changed {
                    settings.display.save();
                }

                ui.separator();

                if ui.button("Reset Camera").clicked() {
                    reset_camera = true;
                }
            });
        
        if !settings.ui.show_display_settings {
            settings.ui.save();
        }
        
        reset_camera
    }

    fn show_colors_window(
        &mut self,
        ctx: &egui::Context,
        settings: &mut Settings,
    ) -> bool {
        let mut colors_changed = false;
        
        egui::Window::new("🌈 Colors")
            .default_width(300.0)
            .resizable(true)
            .open(&mut settings.ui.show_colors)
            .show(ctx, |ui| {
                let mut changed = false;
                
                ui.label("Team Color:");
                changed |= ui.color_edit_button_rgb(&mut settings.colors.team_color).changed();
                
                ui.label("Skybox Color:");
                changed |= ui.color_edit_button_rgb(&mut settings.colors.skybox_color).changed();
                
                ui.label("Grid Major Lines:");
                changed |= ui.color_edit_button_rgb(&mut settings.colors.grid_major_color).changed();
                
                ui.label("Grid Minor Lines:");
                changed |= ui.color_edit_button_rgb(&mut settings.colors.grid_minor_color).changed();
                
                ui.label("Bounding Box Color:");
                changed |= ui.color_edit_button_rgb(&mut settings.colors.bounding_box_color).changed();
                
                ui.separator();
                
                if ui.button("Reset to Defaults").clicked() {
                    settings.colors = crate::settings::ColorSettings::default();
                    changed = true;
                }
                
                if changed {
                    settings.colors.save();
                    colors_changed = true;
                }
            });
        
        if !settings.ui.show_colors {
            settings.ui.save();
        }
        
        colors_changed
    }

    fn show_model_info_window(
        &mut self,
        ctx: &egui::Context,
        model: &Option<Model>,
        ui_settings: &mut crate::settings::UiSettings,
    ) {
        egui::Window::new("ℹ️ Model Info")
            .default_width(300.0)
            .resizable(true)
            .open(&mut ui_settings.show_model_info)
            .show(ctx, |ui| {
                if let Some(model) = model {
                ui.label(format!("Name: {}", model.name));
                ui.separator();

                ui.label(format!("Geosets: {}", model.geosets.len()));
                let total_verts: usize = model.geosets.iter().map(|g| g.vertices.len()).sum();
                let total_faces: usize = model.geosets.iter().map(|g| g.faces.len()).sum();
                let total_uvs: usize = model.geosets.iter().map(|g| g.tex_coords.len()).sum();
                ui.label(format!("  Total vertices: {}", total_verts));
                ui.label(format!("  Total faces: {}", total_faces));
                ui.label(format!("  Total UVs: {}", total_uvs));

                ui.separator();
                ui.label(format!("Materials: {}", model.materials.len()));
                ui.label(format!("Textures: {}", model.textures.len()));
                ui.label(format!("Sequences: {}", model.sequences.len()));
                ui.label(format!("Bones: {}", model.bones.len()));
                ui.label(format!("Helpers: {}", model.helpers.len()));
                } else {
                    ui.label("No model loaded");
                    if ui.button("Load Model").clicked() {
                        // TODO: Implement file dialog
                    }
                }
            });
        
        if !ui_settings.show_model_info {
            ui_settings.save();
        }
    }

    fn show_geosets_window(
        &mut self,
        ctx: &egui::Context,
        model: &Option<Model>,
        ui_settings: &mut crate::settings::UiSettings,
    ) {
        egui::Window::new("📦 Geosets")
            .default_width(300.0)
            .resizable(true)
            .open(&mut ui_settings.show_geosets)
            .show(ctx, |ui| {
                if let Some(model) = model {
                    egui::ScrollArea::vertical()
                        .show(ui, |ui| {
                            for (i, geoset) in model.geosets.iter().enumerate() {
                                if self.show_geosets.len() <= i {
                                    self.show_geosets.push(true);
                                }

                                ui.horizontal(|ui| {
                                    ui.checkbox(&mut self.show_geosets[i], format!("#{}", i));
                                    ui.label(format!(
                                        "{} verts, {} faces",
                                        geoset.vertices.len(),
                                        geoset.faces.len()
                                    ));
                                });
                            }
                        });
                } else {
                    ui.label("No model loaded");
                }
            });
        
        if !ui_settings.show_geosets {
            ui_settings.save();
        }
    }

    fn show_materials_window(
        &mut self,
        ctx: &egui::Context,
        model: &Option<Model>,
        ui_settings: &mut crate::settings::UiSettings,
    ) {
        egui::Window::new("🎨 Materials")
            .default_width(400.0)
            .resizable(true)
            .open(&mut ui_settings.show_materials)
            .show(ctx, |ui| {
                if let Some(model) = model {
                    egui::ScrollArea::vertical()
                        .show(ui, |ui| {
                            for (mat_id, material) in model.materials.iter().enumerate() {
                                ui.group(|ui| {
                                    ui.set_min_width(ui.available_width());
                                    
                                    ui.heading(format!("Material #{}", mat_id));
                                    
                                    ui.label(format!("Layers: {}", material.layers.len()));
                                    
                                    for (layer_id, layer) in material.layers.iter().enumerate() {
                                        ui.separator();
                                        ui.label(format!("  Layer #{}", layer_id));
                                        
                                        if let Some(tex_id) = layer.texture_id {
                                            ui.label(format!("    Texture ID: {}", tex_id));
                                        } else {
                                            ui.label("    Texture ID: None");
                                        }
                                        
                                        ui.label(format!("    Filter Mode: {:?}", layer.filter_mode));
                                        ui.label(format!("    Alpha: {:.2}", layer.alpha));
                                    }
                                });
                                ui.add_space(4.0);
                            }
                        });
                } else {
                    ui.label("No model loaded");
                }
            });
        
        if !ui_settings.show_materials {
            ui_settings.save();
        }
    }

    fn show_animation_window(
        &mut self,
        ctx: &egui::Context,
        model: &Option<Model>,
        ui_settings: &mut crate::settings::UiSettings,
    ) {
        egui::Window::new("🎬 Animation")
            .default_width(300.0)
            .resizable(true)
            .open(&mut ui_settings.show_animation)
            .show(ctx, |ui| {
                if let Some(model) = model {
                    if !model.sequences.is_empty() {
                        egui::ComboBox::from_label("Sequence")
                            .selected_text(&model.sequences[self.selected_sequence].name)
                            .show_ui(ui, |ui| {
                                for (i, seq) in model.sequences.iter().enumerate() {
                                    ui.selectable_value(&mut self.selected_sequence, i, &seq.name);
                                }
                            });

                        // Show sequence details
                        let seq = &model.sequences[self.selected_sequence];
                        ui.label(format!("Frames: {} - {}", seq.start_frame, seq.end_frame));
                        ui.label(format!(
                            "Duration: {} frames",
                            seq.end_frame - seq.start_frame
                        ));
                        ui.label(format!("Non-looping: {}", seq.non_looping));
                        if let Some(rarity) = seq.rarity {
                            ui.label(format!("Rarity: {}", rarity));
                        }

                        ui.separator();

                        ui.horizontal(|ui| {
                            if ui.button(if self.is_playing { "⏸" } else { "▶" }).clicked() {
                                self.is_playing = !self.is_playing;
                            }
                            ui.add(egui::Slider::new(&mut self.animation_time, 0.0..=1.0).text("Time"));
                        });
                    } else {
                        ui.label("No animations in model");
                    }
                } else {
                    ui.label("No model loaded");
                }
            });
        
        if !ui_settings.show_animation {
            ui_settings.save();
        }
    }
}
