use crate::model::Model;
use crate::settings::Settings;

pub struct Ui {
    show_geosets: Vec<bool>,
    selected_sequence: usize,
    animation_time: f32,
    is_playing: bool,
    panel_width: f32,
}

impl Ui {
    pub fn new() -> Self {
        Self {
            show_geosets: Vec::new(),
            selected_sequence: 0,
            animation_time: 0.0,
            is_playing: false,
            panel_width: 300.0, // Default width
        }
    }

    pub fn get_panel_width(&self) -> f32 {
        self.panel_width
    }

    pub fn show(
        &mut self,
        ctx: &egui::Context,
        model: &Option<Model>,
        camera_yaw: f32,
        camera_pitch: f32,
        settings: &mut Settings,
    ) -> (bool, f32, Vec<bool>, bool) {
        let mut reset_camera = false;
        let mut colors_changed = false;

        // Draw left panel first to establish layout
        let panel_response = egui::SidePanel::left("left_panel")
            .default_width(250.0)
            .resizable(true)
            .show(ctx, |ui| {
                colors_changed = self.show_settings(ui, settings, &mut reset_camera);
                self.show_model_info(ui, model);
                self.show_geosets(ui, model);
                self.show_textures(ui, model);
                self.show_animation(ui, model);
            });

        // Get panel width for viewport adjustment
        let panel_width = panel_response.response.rect.width();
        self.panel_width = panel_width; // Store for later use

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
            panel_width,
            self.show_geosets.clone(),
            colors_changed,
        )
    }

    fn show_settings(&mut self, ui: &mut egui::Ui, settings: &mut Settings, reset_camera: &mut bool) -> bool {
        ui.collapsing("Display Settings", |ui| {
            let mut changed = false;
            
            changed |= ui.checkbox(&mut settings.show_skeleton, "Show Skeleton").changed();
            changed |= ui.checkbox(&mut settings.wireframe_mode, "Wireframe Mode").changed();
            changed |= ui.checkbox(&mut settings.show_grid, "Show Grid").changed();
            changed |= ui.checkbox(&mut settings.show_bounding_box, "Show Bounding Box").changed();

            ui.separator();
            ui.label("Far Plane (View Distance):");
            changed |= ui
                .add(
                    egui::Slider::new(&mut settings.far_plane, 100.0..=5000.0)
                        .suffix(" units")
                        .logarithmic(true),
                )
                .changed();

            if changed {
                settings.save();
            }

            ui.separator();

            if ui.button("Reset Camera").clicked() {
                *reset_camera = true;
            }
        });
        
        // Colors tab
        let mut colors_changed = false;
        ui.collapsing("Colors", |ui| {
            let mut changed = false;
            
            ui.label("Team Color:");
            changed |= ui.color_edit_button_rgb(&mut settings.team_color).changed();
            
            ui.label("Skybox Color:");
            changed |= ui.color_edit_button_rgb(&mut settings.skybox_color).changed();
            
            ui.label("Grid Major Lines:");
            changed |= ui.color_edit_button_rgb(&mut settings.grid_major_color).changed();
            
            ui.label("Grid Minor Lines:");
            changed |= ui.color_edit_button_rgb(&mut settings.grid_minor_color).changed();
            
            ui.label("Bounding Box Color:");
            changed |= ui.color_edit_button_rgb(&mut settings.bounding_box_color).changed();
            
            ui.separator();
            
            if ui.button("Reset Colors to Default").clicked() {
                let default_settings = Settings::default();
                settings.team_color = default_settings.team_color;
                settings.skybox_color = default_settings.skybox_color;
                settings.grid_major_color = default_settings.grid_major_color;
                settings.grid_minor_color = default_settings.grid_minor_color;
                settings.bounding_box_color = default_settings.bounding_box_color;
                changed = true;
            }
            
            if changed {
                settings.save();
                colors_changed = true;
            }
        });
        
        colors_changed
    }



    fn show_model_info(&mut self, ui: &mut egui::Ui, model: &Option<Model>) {
        if let Some(model) = model {
            ui.collapsing("Model Info", |ui| {
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
            });
        } else {
            ui.label("No model loaded");
            if ui.button("Load Model").clicked() {
                // TODO: Implement file dialog
            }
        }
    }

    fn show_geosets(&mut self, ui: &mut egui::Ui, model: &Option<Model>) {
        if let Some(model) = model {
            ui.collapsing("Geosets", |ui| {
                egui::ScrollArea::vertical()
                    .max_height(150.0)
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
            });
        }
    }

    fn show_textures(&self, ui: &mut egui::Ui, model: &Option<Model>) {
        if let Some(model) = model {
            ui.collapsing("Textures", |ui| {
                if model.textures.is_empty() {
                    ui.label("No textures");
                } else {
                    ui.label(format!("{} textures", model.textures.len()));
                    ui.separator();

                    egui::ScrollArea::vertical()
                        .max_height(200.0)
                        .show(ui, |ui| {
                            for (i, texture) in model.textures.iter().enumerate() {
                                ui.horizontal(|ui| {
                                    ui.label(format!("#{}", i));

                                    if texture.replaceable_id == 1 {
                                        ui.colored_label(
                                            egui::Color32::from_rgb(255, 100, 100),
                                            "Team Color",
                                        );
                                    } else if texture.replaceable_id == 2 {
                                        ui.colored_label(
                                            egui::Color32::from_rgb(255, 150, 150),
                                            "Team Glow",
                                        );
                                    } else if texture.replaceable_id > 0 {
                                        ui.colored_label(
                                            egui::Color32::from_rgb(255, 180, 100),
                                            format!("Replaceable ID {}", texture.replaceable_id),
                                        );
                                    } else if !texture.filename.is_empty() {
                                        ui.label(&texture.filename);
                                        if texture.image_data.is_some() {
                                            ui.colored_label(egui::Color32::GREEN, "✓");
                                        }
                                    } else {
                                        ui.colored_label(egui::Color32::GRAY, "(empty)");
                                    }
                                });
                            }
                        });
                }
            });
        }
    }

    fn show_animation(&mut self, ui: &mut egui::Ui, model: &Option<Model>) {
        if let Some(model) = model {
            if model.sequences.is_empty() {
                return;
            }

            ui.collapsing("Animation", |ui| {
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
            });
        }
    }
}
